module Page.Feedback.Classrooms exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Feedback exposing (..)
import API.Users as Users
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Modal as Modal
import Components.Table as Table
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (RemoteData(..))
import Route
import Session as Session exposing (Session)
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , editorState : EditorState
    }

type Msg
    = GotSession Session
    | GotRotationGroups (APIData (List RotationGroup))
    | GotStudentFeedback (APIData (List Category))
      -- Buttons
    | SelectedStudent RotationGroup User
    | ComposeDraft RotationGroup User
    | ResetRotationGroup
    | EditFeedback RotationGroup User


init : Session -> ( Model, Cmd Msg )
init session =
    case Session.credential session of
        Just cred ->
            let
                user =
                    API.credentialUser cred
            in
            ( { session = session
              , editorState = StudentSelection Loading
              }
            , Cmd.none
            )

        Nothing ->
            ( { session = session
              , editorState = StudentSelection NotAsked
              }
            , Route.replaceUrl (Session.navKey session) (Route.Login Nothing)
            )


toSession : Model -> Session
toSession model =
    model.session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session

        GotRotationGroups rotationGroups ->
            case model.editorState of
                StudentSelection _ ->
                    API.handleRemoteError rotationGroups { model | editorState = StudentSelection rotationGroups } Cmd.none

                _ ->
                    ( model, Cmd.none )

        GotStudentFeedback feedback ->
            case model.editorState of
                ViewStudent rotationGroups rotationGroup student _ ->
                    API.handleRemoteError feedback { model | editorState = ViewStudent rotationGroups rotationGroup student feedback } Cmd.none

                _ ->
                    ( model, Cmd.none )

        -- Buttons
        SelectedStudent rotationGroup student ->
            case model.editorState of
                StudentSelection rotationGroups ->
                    ( { model | editorState = ViewStudent rotationGroups rotationGroup student Loading }, feedbackByCategory model.session rotationGroup.id student.id GotStudentFeedback )

                _ ->
                    ( model, Cmd.none )

        ComposeDraft rotationGroup student ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.NewDraft rotationGroup.id student.id) )

        ResetRotationGroup ->
            case model.editorState of
                ViewStudent rotationGroups _ _ _ ->
                    ( { model | editorState = StudentSelection rotationGroups }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        EditFeedback rotationGroup student ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.EditFeedback rotationGroup.id student.id Nothing) )


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Feedback"
    , content =
        div []
            [ viewRotationGroups model
            , viewStudent model
            ]
    }


viewRotationGroups : Model -> Html Msg
viewRotationGroups model =
    case model.editorState of
        ViewStudent _ rotationGroup _ _ ->
            Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ Common.header <| "Rotation Group " ++ String.fromInt rotationGroup.number
                    , Common.dangerButton "Reset" ResetRotationGroup
                    ]
                ]

        StudentSelection rotationGroups ->
            case rotationGroups of
                NotAsked ->
                    text ""

                Loading ->
                    Common.panel [ Common.loading ]

                Success data ->
                    Common.panel
                        [ div [ class "flex justify-between items-center mx-4" ]
                            [ h1 [ class "text-4xl text-gray-400 font-display" ] [ text "Rotation Groups" ]
                            ]
                        , ul [ class "ml-8 list-disc" ] <| List.map viewRotationGroup data
                        ]

                Failure e ->
                    Common.panel
                        [ div [ class "flex justify-between items-center mx-4" ]
                            [ Common.header "Rotation Groups"
                            ]
                        , div []
                            [ div [ class "mx-4 my-2 flex" ] [ div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ] ]
                            ]
                        ]


viewRotationGroup : RotationGroup -> Html Msg
viewRotationGroup rotationGroup =
    let
        studentButton student =
            li [] [ button [ onClick <| SelectedStudent rotationGroup student ] [ text <| student.firstName ++ " " ++ student.lastName ] ]

        isStudent student =
            List.any (\role -> role.identifier == "student") (Maybe.withDefault [] student.roles)

        filterStudents =
            List.filter isStudent
    in
    li [ class "text-l text-gray-400 font-display" ]
        [ text <| "Rotation Group " ++ String.fromInt rotationGroup.number
        , ul [] <| Maybe.withDefault [ text "No Students " ] <| Maybe.map (unwrapUsers >> filterStudents >> List.map studentButton) rotationGroup.users
        ]


viewStudent : Model -> Html Msg
viewStudent model =
    case model.editorState of
        StudentSelection _ ->
            text ""

        ViewStudent _ rotationGroup student studentFeedback ->
            Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ Common.header <| student.firstName ++ " " ++ student.lastName
                    , div []
                        [ Common.primaryButton "Compose Draft" (ComposeDraft rotationGroup student)
                        , Common.successButton "Record Feedback" (EditFeedback rotationGroup student)
                        ]
                    ]
                , div [ class "mx-4 my-2" ] [ viewFeedback studentFeedback ]
                ]


viewFeedback : APIData (List Category) -> Html Msg
viewFeedback data =
    let
        viewExplanation explanation =
            li [ class "ml-4" ]
                [ text explanation.content
                ]

        viewFeedbackItem feedback =
            li [ class "ml-4" ]
                [ text feedback.content
                , ul [] <| List.map viewExplanation (Maybe.withDefault [] <| Maybe.map unwrapExplanations feedback.explanations)
                ]

        viewObservation observation =
            li [ class "ml-4 pl-2 border-l" ]
                [ text observation.content
                , ul [] <| List.map viewFeedbackItem (Maybe.withDefault [] <| Maybe.map unwrapFeedback observation.feedback)
                ]

        viewCategory category =
            li [ class "text-gray-400" ]
                [ text category.name
                , ul [] <| List.map viewObservation (Maybe.withDefault [] <| Maybe.map unwrapObservations category.observations)
                ]
    in
    case data of
        NotAsked ->
            text "Impossible state shouldn't be visible lol"

        Loading ->
            Common.loading

        Success categories ->
            ul [] <| List.map viewCategory categories

        Failure e ->
            div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
