module Page.Draft exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Classrooms exposing (..)
import API.Drafts exposing (..)
import API.Feedback exposing (..)
import API.Users exposing (..)
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Utilities.Flex as Flex
import Bootstrap.Utilities.Size as Size
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Table as Table
import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as ListExtra
import RemoteData exposing (RemoteData(..))
import RemoteData.Extra exposing (priorityApply, priorityMap)
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
            let
                commands =
                    [ groupDraft model.session model.draftId GotDraft
                    , studentFeedback model.session model.draftId GotStudentFeedback
                    , studentExplanations model.session model.draftId Nothing GotStudentExplanations
                    ]
                        ++ RemoteData.unwrap [] (List.map (\draft -> grades model.session draft.id GotGrades)) result
                        ++ RemoteData.unwrap [] (List.map (\draft -> comments model.session draft.id GotComments)) result
                        ++ RemoteData.unwrap [] (List.map (\draft -> studentFeedback model.session draft.id GotStudentFeedback)) result
                        ++ RemoteData.unwrap [] (List.map (\draft -> studentExplanations model.session draft.id Nothing GotStudentExplanations)) result
            in
            API.handleRemoteError result { model | studentDrafts = result } <| Cmd.batch commands

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
            API.handleRemoteError result { model | grades = priorityApply (\grades modelGrades -> grades ++ modelGrades) result model.grades } Cmd.none

        GotComments result ->
            API.handleRemoteError result { model | comments = priorityApply (\comments modelComments -> comments ++ modelComments) result model.comments } Cmd.none

        GotStudentFeedback result ->
            API.handleRemoteError result { model | studentFeedback = priorityApply (\feedback modelFeedback -> feedback ++ modelFeedback) result model.studentFeedback } Cmd.none

        GotStudentExplanations result ->
            API.handleRemoteError result { model | studentExplanations = priorityApply (\explanations modelExplanations -> explanations ++ modelExplanations) result model.studentExplanations } Cmd.none

        GotStudent result ->
            let
                mapped =
                    priorityMap List.singleton
                        (\student students ->
                            if student.role == Student then
                                student :: students

                            else
                                students
                        )
                        result
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
            API.handleRemoteError result { model | studentDrafts = priorityMap List.singleton (::) result model.studentDrafts } Cmd.none


viewFeedback : Model -> DraftId -> Html Msg
viewFeedback model draftId =
    let
        renderExplanation explanation =
            ListGroup.li []
                [ div [ Flex.block, Flex.row, Flex.justifyBetween ]
                    [ p [] [ text explanation.content ]
                    , case RemoteData.unwrap Nothing (ListExtra.find (\studentExplanation -> studentExplanation.explanationId == explanation.id)) model.studentExplanations of
                        Nothing ->
                            span [ class "text-danger" ] [ text "Unknown Time" ]

                        Just studentFeedback ->
                            span [ class "text-info" ] [ text <| Date.posixToDate model.timezone studentFeedback.insertedAt ++ " @ " ++ Date.posixToClockTime model.timezone studentFeedback.insertedAt ]
                    ]
                ]

        renderFeedback feedback =
            ListGroup.li []
                [ div [ Flex.row, Flex.block, Flex.justifyBetween ]
                    [ p [] [ text feedback.content ]
                    , case RemoteData.unwrap Nothing (ListExtra.find (\studentFeedback -> studentFeedback.feedbackId == feedback.id)) model.studentFeedback of
                        Nothing ->
                            span [ class "text-danger" ] [ text "Unknown Time" ]

                        Just studentFeedback ->
                            span [ class "text-info" ] [ text <| Date.posixToDate model.timezone studentFeedback.insertedAt ++ " @ " ++ Date.posixToClockTime model.timezone studentFeedback.insertedAt ]
                    ]
                , case model.explanations of
                    Success explanations ->
                        ListGroup.ul <| List.map renderExplanation <| RemoteData.unwrap [] (\studentExplanation -> List.filter (\explanation -> List.any (\item -> item.explanationId == explanation.id && item.draftId == draftId && item.feedbackId == feedback.id) studentExplanation) explanations) model.studentExplanations

                    Failure error ->
                        (API.getErrorBody >> API.errorBodyToString >> text) error

                    _ ->
                        Common.loading
                ]

        renderObservation observation =
            ListGroup.li []
                [ text observation.content
                , case model.feedback of
                    Success feedback ->
                        ListGroup.ul <| List.map renderFeedback <| RemoteData.unwrap [] (\studentFeedback -> List.filter (\feedbackItem -> List.any (\item -> item.feedbackId == feedbackItem.id && item.draftId == draftId && item.observation == observation.id) studentFeedback) feedback) model.studentFeedback

                    Failure error ->
                        (API.getErrorBody >> API.errorBodyToString >> text) error

                    _ ->
                        Common.loading
                ]

        renderCategory category =
            ListGroup.li []
                [ text category.name
                , case model.observations of
                    Success observations ->
                        ListGroup.ul <| List.map renderObservation <| RemoteData.unwrap [] (\studentFeedback -> List.filter (\observation -> List.any (\item -> item.observation == observation.id && item.draftId == draftId) studentFeedback) observations) model.studentFeedback

                    Failure error ->
                        (API.getErrorBody >> API.errorBodyToString >> text) error

                    _ ->
                        Common.loading
                ]
    in
    Card.config [ Card.attrs [ Size.h100 ] ]
        |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
            [ h3 []
                [ text "Feedback "
                , Common.iconTooltip "question-circle" "Record feedback about the group here"
                ]
            , Button.linkButton [ Button.success, Button.attrs [ Route.href (Route.EditFeedback draftId Nothing) ] ] [ text "Edit Feedback" ]
            ]
        |> (case model.categories of
                Success categories ->
                    Card.listGroup <| List.map renderCategory <| RemoteData.unwrap [] (\feedback -> List.filter (\category -> List.any (\item -> item.category == category.id && item.draftId == draftId) feedback) categories) model.studentFeedback

                Failure error ->
                    Card.block [] [ Block.text [] <| (API.getErrorBody >> API.errorBodyToString >> text >> List.singleton) error ]

                _ ->
                    Card.block [] [ Block.custom Common.loading ]
           )
        |> Card.view


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
                    [ viewFeedback model model.draftId ]
                , Grid.col [ Col.md6 ]
                    [ Grid.simpleRow
                        [ Grid.col [ Col.md12 ]
                            [ Card.config []
                                |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
                                    [ h3 []
                                        [ text "Group Draft"
                                        ]
                                    , h5 []
                                        [ Common.iconTooltip "question-circle" "Record feedback about the group here"
                                        ]
                                    ]
                                |> Card.block []
                                    [ Block.custom <|
                                        Form.form []
                                            [ Form.group []
                                                [ Textarea.textarea
                                                    [ Textarea.id "groupDraftContent"
                                                    , Textarea.rows 8
                                                    , Textarea.value model.groupDraftForm.content
                                                    , Textarea.attrs [ placeholder "Write the feedback for the whole group here." ]
                                                    ]
                                                ]
                                            ]
                                    ]
                                |> Card.view
                            ]
                        ]
                    , Grid.simpleRow
                        [ Grid.col [ Col.md12 ]
                            [ Card.config []
                                |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
                                    [ h3 []
                                        [ text "Group Notes"
                                        ]
                                    , h5 []
                                        [ Common.iconTooltip "question-circle" "Record your notes about the group here"
                                        ]
                                    ]
                                |> Card.block []
                                    [ Block.custom <|
                                        Form.form []
                                            [ Form.group []
                                                [ Textarea.textarea
                                                    [ Textarea.id "groupDraftNotes"
                                                    , Textarea.rows 8
                                                    , Textarea.value model.groupDraftForm.notes
                                                    , Textarea.attrs [ placeholder "Write the notes for the whole group here. Nothing in these notes will be present in the draft the group sees." ]
                                                    , if True then
                                                          Textarea.success
                                                      else
                                                          Textarea.danger
                                                    ]
                                                ]
                                            ]
                                    ]
                                |> Card.view
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewStudentDraft : Model -> StudentDraft -> Html Msg
viewStudentDraft model draft =
    Grid.simpleRow
        [ Grid.col [ Col.md6 ]
            [ viewFeedback model draft.id ]
        ]


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
