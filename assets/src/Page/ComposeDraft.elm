module Page.ComposeDraft exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Classrooms exposing (..)
import API.Drafts exposing (..)
import API.Feedback exposing (..)
import API.Users exposing (..)
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.MDEditor as MDEditor
import Components.Modal as Modal
import Components.Table as Table
import Either exposing (..)
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
    , student : APIData User
    , group : APIData RotationGroup
    , draftForm : DraftForm
    , draftFormErrors : List ( FormField, String )
    , draft : APIData Draft
    , studentFeedback : APIData (List Category)
    , gradeCategories : APIData (List Category)
    , grades : APIData (List Grade)
    , either : Either DraftId ( RotationGroupId, UserId )
    }


type Msg
    = GotSession Session
    | GotStudent (APIData User)
    | GotRotationGroup (APIData RotationGroup)
    | GotDraft (APIData Draft)
    | GotDraftUpdate (APIData Draft)
    | GotDraftCreate (APIData Draft)
    | GotStudentFeedback (APIData (List Category))
    | GotGradeCategories (APIData (List Category))
    | GotGrades (APIData (List Grade))
    | GotEditorInput String
    | SubmitDraftForm


type FormField
    = Content


validator : Validator ( FormField, String ) DraftForm
validator =
    Validate.all
        [ ifBlank .content ( Content, "Please enter some content" )
        ]


initForm : Maybe Draft -> DraftForm
initForm maybeDraft =
    case maybeDraft of
        Just draft ->
            draftToForm draft

        Nothing ->
            { content = ""
            , status = Unreviewed
            , studentId = Nothing
            , reviewerId = Nothing
            , rotationGroupId = Nothing
            , authors = []
            }


init : Either DraftId ( RotationGroupId, UserId ) -> Session -> ( Model, Cmd Msg )
init either session =
    case Session.credential session of
        Just cred ->
            case either of
                Left draftId ->
                    ( { session = session
                      , student = Loading
                      , group = Loading
                      , draftForm = initForm Nothing
                      , draft = Loading
                      , draftFormErrors = []
                      , studentFeedback = Loading
                      , gradeCategories = Loading
                      , grades = Loading
                      , either = either
                      }
                    , Cmd.batch
                        [ draft session draftId GotDraft
                        , grades session draftId GotGrades
                        ]
                    )

                Right ( groupId, studentId ) ->
                    ( { session = session
                      , student = Loading
                      , group = Loading
                      , draftForm =
                            { content = ""
                            , status = Unreviewed
                            , studentId = Just studentId
                            , reviewerId = Nothing
                            , rotationGroupId = Just groupId
                            , authors = List.singleton (.id <| API.credentialUser cred)
                            }
                      , draftFormErrors = []
                      , draft = NotAsked
                      , studentFeedback = Loading
                      , gradeCategories = Loading
                      , grades = NotAsked
                      , either = either
                      }
                    , Cmd.batch
                        [ rotationGroupClassroomCategories session groupId GotGradeCategories
                        , feedbackByCategory session groupId studentId GotStudentFeedback
                        , user session studentId GotStudent
                        , API.Classrooms.rotationGroup session groupId GotRotationGroup
                        ]
                    )

        Nothing ->
            ( { session = session
              , draftForm = initForm Nothing
              , student = NotAsked
              , group = NotAsked
              , draft = NotAsked
              , draftFormErrors = []
              , studentFeedback = NotAsked
              , gradeCategories = NotAsked
              , grades = NotAsked
              , either = either
              }
            , Route.replaceUrl (Session.navKey session) (Route.Login Nothing)
            )


toSession : Model -> Session
toSession model =
    model.session


updateForm : (DraftForm -> DraftForm) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | draftForm = transform model.draftForm }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init model.either session

        GotStudent result ->
            API.handleRemoteError result { model | student = result } Cmd.none

        GotRotationGroup result ->
            API.handleRemoteError result { model | group = result } Cmd.none

        GotDraft result ->
            let
                cmd =
                    case result of
                        Success draft ->
                            Cmd.batch
                                [ rotationGroupClassroomCategories model.session draft.rotationGroupId GotGradeCategories
                                , feedbackByCategory model.session draft.rotationGroupId draft.studentId GotStudentFeedback
                                , user model.session draft.studentId GotStudent
                                , API.Classrooms.rotationGroup model.session draft.rotationGroupId GotRotationGroup
                                ]

                        _ ->
                            Cmd.none

                updatedModel =
                    case result of
                        Success draft ->
                            { model | draft = result, draftForm = initForm <| Just draft }

                        _ ->
                            { model | draft = result }
            in
            API.handleRemoteError result updatedModel cmd

        GotDraftUpdate result ->
            API.handleRemoteError result { model | draft = result } Cmd.none

        GotDraftCreate result ->
            case result of
                Success draft ->
                    ( model, Route.replaceUrl (Session.navKey model.session) (Route.EditDraft draft.id) )

                _ ->
                    API.handleRemoteError result { model | draft = result } Cmd.none

        GotStudentFeedback result ->
            API.handleRemoteError result { model | studentFeedback = result } Cmd.none

        GotGrades result ->
            API.handleRemoteError result { model | grades = result } Cmd.none

        GotGradeCategories result ->
            API.handleRemoteError result { model | gradeCategories = result } Cmd.none

        GotEditorInput content ->
            updateForm (\form -> { form | content = content }) model

        SubmitDraftForm ->
            case validate validator model.draftForm of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    case model.draft of
                        Success draft ->
                            ( { model | draftFormErrors = [] }, editDraft model.session draft.id form GotDraftUpdate )

                        _ ->
                            ( { model | draftFormErrors = [] }, newDraft model.session form GotDraftCreate )

                Err errors ->
                    ( { model | draftFormErrors = errors }, Cmd.none )


viewFeedback : APIData (List Category) -> Html Msg
viewFeedback data =
    let
        viewExplanation explanation =
            li [ class "ml-4 my-1" ]
                [ text explanation.content
                ]

        viewFeedbackItem feedback =
            li [ class "ml-4 my-1" ]
                [ text feedback.content
                , ul [] <| List.map viewExplanation (Maybe.withDefault [] <| Maybe.map unwrapExplanations feedback.explanations)
                ]

        viewObservation observation =
            li [ class "ml-4 my-1 pl-2 border-l" ]
                [ text observation.content
                , ul [] <| List.map viewFeedbackItem (Maybe.withDefault [] <| Maybe.map unwrapFeedback observation.feedback)
                ]

        viewCategory category =
            li [ class "my-1 text-gray-400" ]
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


renderGrades : List Category -> List Grade -> Html Msg
renderGrades categories grades =
    Html.form [] <|
        List.map
            (\cat ->
                div []
                    [ label [] [ text cat.name ]
                    , input [] []
                    ]
            )
            categories


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Compose Draft"
    , content =
        let
            editorConf =
                { onInput = GotEditorInput, placeholder = "Compose the draft here." }
        in
        div []
            [ Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ case ( model.student, model.group ) of
                        ( Success student, Success group ) ->
                            Common.header <| String.join " " [ student.firstName, student.lastName, "- Rotation Group", String.fromInt group.number ]

                        ( Loading, _ ) ->
                            Common.loading

                        ( _, Loading ) ->
                            Common.loading

                        ( Failure e, _ ) ->
                            div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ]

                        ( _, Failure e ) ->
                            div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ]

                        _ ->
                            text ""
                    ]
                ]
            , Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ Common.header "Feedback" ]
                , div [ class "mx-4 my-2" ]
                    [ viewFeedback model.studentFeedback ]
                ]
            , Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ h1 [ class "text-4xl text-gray-400 font-display" ] [ text "Edit Draft" ]
                    ]
                , case model.draft of
                    NotAsked ->
                        MDEditor.render editorConf ""

                    Loading ->
                        Common.loading

                    Success draft ->
                        MDEditor.render editorConf draft.content

                    Failure e ->
                        MDEditor.render editorConf "Problem loading draft"
                , div [ class "mx-4 mb-2" ] [ Common.primaryButton "Submit" SubmitDraftForm ]
                ]
            , let
                panel inner =
                    Common.panel
                        [ div [ class "flex justify-between items-center mx-4" ]
                            [ h1 [ class "text-4xl text-gray-400 font-display" ] [ text "Edit Grades" ]
                            ]
                        , inner
                        ]
              in
              case ( model.grades, model.gradeCategories ) of
                ( Success grades, Success gradeCategories ) ->
                    panel <| renderGrades gradeCategories grades

                ( Failure e, _ ) ->
                    panel <| div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ]

                ( _, Failure e ) ->
                    panel <| div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ]

                ( Loading, _ ) ->
                    panel <| Common.loading

                ( _, Loading ) ->
                    panel <| Common.loading

                _ ->
                    text ""
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
