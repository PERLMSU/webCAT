module Page.Draft exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Classrooms exposing (..)
import API.Drafts exposing (..)
import API.Feedback exposing (..)
import API.Users exposing (..)
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.ListGroup as ListGroup
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Table as Table
import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (RemoteData(..))
import Route
import Session as Session exposing (Session)
import Task
import Time
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , draftId : DraftId
    , timezone : Time.Zone

    -- Remote data
    , rotationGroup : APIData RotationGroup
    , groupDraft : APIData GroupDraft
    , studentDrafts : APIData (List StudentDraft)
    , students : APIData (List User)
    , categories : APIData (List Category)
    , observations : APIData (List Observation)
    , feedback : APIData (List Feedback)
    , explanations : APIData (List Explanation)
    , studentFeedback : APIData (List StudentFeedback)
    , studentExplanations : APIData (List StudentExplanation)
    , grades : APIData (List Grade)
    , comments : APIData (List Comment)

    -- Forms
    , groupDraftForm : GroupDraftForm
    }


type alias GroupDraftForm =
    { content : String
    , notes : String
    }


initGroupDraftForm : Maybe GroupDraft -> GroupDraftForm
initGroupDraftForm maybeDraft =
    case maybeDraft of
        Just draft ->
            { content = draft.content
            , notes = Maybe.withDefault "" draft.notes
            }

        Nothing ->
            { content = "", notes = "" }


type Msg
    = GotSession Session
    | GotTimezone Time.Zone
    | GotRotationGroup (APIData RotationGroup)
    | GotCategories (APIData (List Category))
    | GotObservations (APIData (List Observation))
    | GotFeedback (APIData (List Feedback))
    | GotExplanations (APIData (List Explanation))
    | GotStudentFeedback (APIData (List StudentFeedback))
    | GotStudentExplanations (APIData (List StudentExplanation))
    | GotDraft (APIData GroupDraft)
    | GotStudentDrafts (APIData (List StudentDraft))
    | GotGrades (APIData (List Grade))
    | GotComments (APIData (List Comment))
    | GotStudent (APIData User)
    | GotCreatedStudentDraft (APIData StudentDraft)


init : DraftId -> Session -> ( Model, Cmd Msg )
init draftId session =
    if Session.isAuthenticated session then
        ( { session = session
          , groupDraft = Loading
          , rotationGroup = Loading
          , studentDrafts = Loading
          , students = Loading
          , categories = Loading
          , observations = Loading
          , feedback = Loading
          , explanations = Loading
          , studentFeedback = Loading
          , studentExplanations = Loading
          , grades = Loading
          , comments = Loading
          , draftId = draftId
          , timezone = Time.utc
          , groupDraftForm = initGroupDraftForm Nothing
          }
        , Cmd.batch
            [ studentDrafts session (Just draftId) GotStudentDrafts
            , categories session Nothing GotCategories
            , observations session Nothing GotObservations
            , feedback session Nothing GotFeedback
            , explanations session Nothing GotExplanations
            , Task.perform GotTimezone Time.here
            ]
        )

    else
        ( { session = session
          , groupDraft = NotAsked
          , rotationGroup = NotAsked
          , draftId = draftId
          , studentDrafts = NotAsked
          , students = NotAsked
          , categories = NotAsked
          , observations = NotAsked
          , feedback = NotAsked
          , explanations = NotAsked
          , studentFeedback = NotAsked
          , studentExplanations = NotAsked
          , grades = NotAsked
          , comments = NotAsked
          , timezone = Time.utc
          , groupDraftForm = initGroupDraftForm Nothing
          }
        , Route.replaceUrl (Session.navKey session) Route.Login
        )


toSession : Model -> Session
toSession model =
    model.session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init model.draftId session

        GotDraft result ->
            case result of
                Success draft ->
                    ( { model | groupDraft = result }, Cmd.batch <| getRotationGroup model.session draft.rotationGroupId GotRotationGroup :: List.map (\id -> user model.session id GotStudent) draft.users )

                _ ->
                    API.handleRemoteError result { model | groupDraft = result } Cmd.none

        GotTimezone zone ->
            ( { model | timezone = zone }, Cmd.none )

        GotStudentDrafts result ->
            API.handleRemoteError result { model | studentDrafts = result } <| groupDraft model.session model.draftId GotDraft

        GotRotationGroup result ->
            API.handleRemoteError result { model | rotationGroup = result } Cmd.none

        GotCategories result ->
            API.handleRemoteError result { model | categories = result } Cmd.none

        GotObservations result ->
            API.handleRemoteError result { model | observations = result } Cmd.none

        GotFeedback result ->
            API.handleRemoteError result { model | feedback = result } Cmd.none

        GotExplanations result ->
            API.handleRemoteError result { model | explanations = result } Cmd.none

        GotGrades result ->
            case result of
                Success grades ->
                    ( { model
                        | grades =
                            RemoteData.map
                                (\l ->
                                    if List.isEmpty l then
                                        grades

                                    else
                                        l ++ grades
                                )
                                model.grades
                      }
                    , Cmd.none
                    )

                _ ->
                    API.handleRemoteError result { model | grades = result } Cmd.none

        GotComments result ->
            case result of
                Success comments ->
                    ( { model
                        | comments =
                            RemoteData.map
                                (\l ->
                                    if List.isEmpty l then
                                        comments

                                    else
                                        l ++ comments
                                )
                                model.comments
                      }
                    , Cmd.none
                    )

                _ ->
                    API.handleRemoteError result { model | comments = result } Cmd.none

        GotStudentFeedback result ->
            case result of
                Success studentFeedback ->
                    ( { model
                        | studentFeedback =
                            RemoteData.map
                                (\l ->
                                    if List.isEmpty l then
                                        studentFeedback

                                    else
                                        l ++ studentFeedback
                                )
                                model.studentFeedback
                      }
                    , Cmd.none
                    )

                _ ->
                    API.handleRemoteError result { model | studentFeedback = result } Cmd.none

        GotStudentExplanations result ->
            case result of
                Success studentExplanations ->
                    ( { model
                        | studentExplanations =
                            RemoteData.map
                                (\l ->
                                    if List.isEmpty l then
                                        studentExplanations

                                    else
                                        l ++ studentExplanations
                                )
                                model.studentExplanations
                      }
                    , Cmd.none
                    )

                _ ->
                    API.handleRemoteError result { model | studentExplanations = result } Cmd.none

        GotStudent result ->
            let
                mapped =
                    case model.students of
                        Success students ->
                            RemoteData.map
                                (\student ->
                                    if student.role == Student then
                                        student :: students

                                    else
                                        students
                                )
                                result

                        Loading ->
                            RemoteData.map
                                (\student ->
                                    if student.role == Student then
                                        [ student ]

                                    else
                                        []
                                )
                                result

                        _ ->
                            model.students

                command =
                    case result of
                        Success student ->
                            if student.role == Student then
                                case model.studentDrafts of
                                    Success drafts ->
                                        if List.any (\draft -> draft.studentId == student.id) drafts then
                                            Cmd.none

                                        else
                                            createStudentDraft model.session { content = "Insert content here", status = Unreviewed, studentId = student.id, parentDraftId = model.draftId } GotCreatedStudentDraft

                                    _ ->
                                        Cmd.none

                            else
                                Cmd.none

                        _ ->
                            Cmd.none
            in
            API.handleRemoteError result { model | students = mapped } command

        GotCreatedStudentDraft result ->
            case result of
                Success draft ->
                    ( { model | studentDrafts = RemoteData.map ((::) draft) model.studentDrafts }, Cmd.none )

                _ ->
                    API.handleRemoteError result model Cmd.none


viewGroupDraft : Model -> Html Msg
viewGroupDraft model =
    Grid.simpleRow
        [ case model.rotationGroup of
            Success rotationGroup ->
                Grid.col []
                    [ Grid.simpleRow
                        [ Grid.col [ Col.md10 ] [ h3 [] [ text <| "Group " ++ String.fromInt rotationGroup.number ] ]
                        , Grid.col [ Col.md2 ] [ Button.button [ Button.info, Button.disabled True ] [ text "Submit for Review" ] ]
                        ]
                    ]

            Failure error ->
                Grid.col [] [ h5 [ class "text-danger" ] [ (API.getErrorBody >> API.errorBodyToString >> text) error ] ]

            _ ->
                Grid.col [] [ Common.loading ]
        , Grid.col [ Col.md12 ]
            [ Grid.simpleRow
                [ Grid.col [ Col.md6 ]
                    []
                , Grid.col [ Col.md6 ]
                    []
                ]
            ]
        ]


viewStudentDraft : Model -> StudentDraft -> Html Msg
viewStudentDraft model draft =
    Grid.simpleRow []


view : Model -> { title : String, content : Html Msg }
view model =
    { title =
        case model.groupDraft of
            Success draft ->
                "Edit Draft"

            _ ->
                "Loading Draft"
    , content =
        Grid.container [] <|
            viewGroupDraft model
                :: (case model.studentDrafts of
                        Success drafts ->
                            List.map (viewStudentDraft model) drafts

                        Failure error ->
                            [ Grid.simpleRow [ Grid.col [] [ h3 [ class "text-danger" ] [ (API.getErrorBody >> API.errorBodyToString >> text) error ] ] ] ]

                        _ ->
                            [ Grid.simpleRow [ Grid.col [] [ Common.loading ] ] ]
                   )
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
