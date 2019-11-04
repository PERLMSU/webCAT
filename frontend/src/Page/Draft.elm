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
import Bootstrap.Form.Input as Input
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
import Debounce exposing (..)
import Either exposing (Either(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as ListExtra
import RemoteData exposing (RemoteData(..))
import RemoteData.Extra exposing (priorityApply, priorityMap, priorityUnwrap)
import Route
import Session as Session exposing (Session)
import Task
import Time
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , draftId : DraftId
    , rotationGroupId : RotationGroupId

    -- Time and date
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
    , studentDraftForms : List ( DraftId, StudentDraftForm )
    , gradeForms : List ( GradeId, GradeForm )
    , commentForm : Maybe CommentForm

    -- Form debouncers
    , groupDraftFormDebounce : Debounce GroupDraftForm
    , studentDraftFormDebouncers : List ( DraftId, Debounce StudentDraftForm )
    , gradeFormDebouncers : List ( GradeId, Debounce GradeForm )

    -- Form results
    , groupDraftUpdate : APIData GroupDraft
    , commentResult : APIData Comment
    , studentDraftUpdates : List ( DraftId, APIData StudentDraft )
    , gradeUpdates : List ( GradeId, APIData Grade )
    }


type Msg
    = GotSession Session
      -- Time and date
    | GotTimezone Time.Zone
      -- Remote data
    | GotRotationGroup (APIData RotationGroup)
    | GotCategory (APIData Category)
    | GotObservations (APIData (List Observation))
    | GotFeedback (APIData (List Feedback))
    | GotExplanations (APIData (List Explanation))
    | GotStudentFeedback (APIData (List StudentFeedback))
    | GotStudentExplanations (APIData (List StudentExplanation))
    | GotDraft (APIData GroupDraft)
    | GotStudentDrafts (APIData (List StudentDraft))
    | GotGrades DraftId (APIData (List Grade))
    | GotComments (APIData (List Comment))
    | GotStudent (APIData User)
      -- Created data
    | GotCreatedStudentDraft (APIData StudentDraft)
      -- Debounce messages
    | GroupDraftFormDebounceMsg Debounce.Msg
    | StudentDraftFormDebounceMsg DraftId Debounce.Msg
    | GradeFormDebounceMsg GradeId Debounce.Msg
      -- Form input handlers
    | GroupDraftFormInput DraftFormField
    | StudentDraftFormInput DraftId DraftFormField
    | GradeFormInput GradeId GradeFormField
    | CommentFormInput CommentFormField
      -- Button handlers
    | CommentSubmitClicked
    | CommentDeleteClicked CommentId
      -- Form remote data handlers
    | GotGroupDraftUpdate (APIData GroupDraft)
    | GotStudentDraftUpdate DraftId (APIData StudentDraft)
    | GotGradeCreate (APIData Grade)
    | GotGradeUpdate GradeId (APIData Grade)
    | GotCommentCreate (APIData Comment)
    | GotCommentDelete CommentId (APIData ())


type DraftFormField
    = DraftNotes String
    | DraftContent String


type GradeFormField
    = Score Int
    | GradeNotes String


type CommentFormField
    = CommentContent String


init : RotationGroupId -> DraftId -> Session -> ( Model, Cmd Msg )
init rotationGroupId draftId session =
    let
        model =
            { session = session
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
            , rotationGroupId = rotationGroupId
            , timezone = Time.utc

            -- Forms
            , groupDraftForm = groupDraftToForm <| Right rotationGroupId
            , groupDraftFormDebounce = Debounce.init
            , studentDraftForms = []
            , studentDraftFormDebouncers = []
            , gradeForms = []
            , gradeFormDebouncers = []
            , commentForm = Nothing

            -- Form remote data
            , groupDraftUpdate = NotAsked
            , commentResult = NotAsked
            , studentDraftUpdates = []
            , gradeUpdates = []
            }
    in
    if Session.isAuthenticated session then
        ( model
        , Cmd.batch
            [ studentDrafts session (Just draftId) GotStudentDrafts
            , observations session Nothing GotObservations
            , feedback session Nothing GotFeedback
            , explanations session Nothing GotExplanations
            , Task.perform GotTimezone Time.here
            ]
        )

    else
        ( model, Route.replaceUrl (Session.navKey session) Route.Login )


toSession : Model -> Session
toSession model =
    model.session


gradeDebounceConfig : GradeId -> Debounce.Config Msg
gradeDebounceConfig id =
    { strategy = Debounce.later 1500
    , transform = GradeFormDebounceMsg id
    }


groupDraftDebounceConfig : Debounce.Config Msg
groupDraftDebounceConfig =
    { strategy = Debounce.later 1500
    , transform = GroupDraftFormDebounceMsg
    }


studentDraftDebounceConfig : DraftId -> Debounce.Config Msg
studentDraftDebounceConfig id =
    { strategy = Debounce.later 1500
    , transform = StudentDraftFormDebounceMsg id
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init model.rotationGroupId model.draftId session

        GotDraft result ->
            let
                updatedModel =
                    case result of
                        Success draft ->
                            { model | groupDraft = result, groupDraftForm = groupDraftToForm <| Left draft }

                        _ ->
                            { model | groupDraft = result }

                commands =
                    case result of
                        Success draft ->
                            getRotationGroup model.session draft.rotationGroupId GotRotationGroup
                                :: List.map (\id -> user model.session id GotStudent) draft.users
                                ++ List.map (\id -> category model.session id GotCategory) draft.categories

                        _ ->
                            []
            in
            API.handleRemoteError result updatedModel <| Cmd.batch commands

        GotTimezone zone ->
            ( { model | timezone = zone }, Cmd.none )

        GotStudentDrafts result ->
            let
                updatedModel =
                    case result of
                        Success drafts ->
                            { model
                                | studentDrafts = result
                                , studentDraftForms = List.map (\draft -> ( draft.id, studentDraftToForm <| Left draft )) drafts
                                , studentDraftFormDebouncers = List.map (\draft -> ( draft.id, Debounce.init )) drafts
                            }

                        _ ->
                            { model | studentDrafts = result }

                commands =
                    case result of
                        Success drafts ->
                            [ groupDraft model.session model.draftId GotDraft
                            , studentFeedback model.session model.draftId GotStudentFeedback
                            , studentExplanations model.session model.draftId Nothing GotStudentExplanations
                            ]
                                ++ List.map (\draft -> comments model.session draft.id GotComments) drafts
                                ++ List.map (\draft -> studentFeedback model.session draft.id GotStudentFeedback) drafts
                                ++ List.map (\draft -> studentExplanations model.session draft.id Nothing GotStudentExplanations) drafts

                        _ ->
                            []
            in
            API.handleRemoteError result updatedModel <| Cmd.batch commands

        GotRotationGroup result ->
            API.handleRemoteError result { model | rotationGroup = result } Cmd.none

        GotCategory result ->
            let
                commands =
                    RemoteData.unwrap [] (List.map (\draft -> grades model.session draft.id (GotGrades draft.id))) model.studentDrafts
            in
            API.handleRemoteError result { model | categories = priorityMap List.singleton (::) result model.categories } <| Cmd.batch commands

        GotObservations result ->
            API.handleRemoteError result { model | observations = result } Cmd.none

        GotFeedback result ->
            API.handleRemoteError result { model | feedback = result } Cmd.none

        GotExplanations result ->
            API.handleRemoteError result { model | explanations = result } Cmd.none

        GotGrades draftId result ->
            let
                categoriesWithoutGrades =
                    ListExtra.filterNot (\category -> List.any (.categoryId >> (==) category.id) (RemoteData.withDefault [] result)) (RemoteData.withDefault [] model.categories)

                updatedGrades =
                    priorityApply (++) result model.grades
            in
            API.handleRemoteError result
                { model
                    | grades = updatedGrades
                    , gradeForms = priorityUnwrap model.gradeForms (List.map <| tupleBiFunc .id (Left >> gradeToForm)) (\_ grades -> List.map (tupleBiFunc .id (Left >> gradeToForm)) grades) result updatedGrades
                    , gradeFormDebouncers = RemoteData.unwrap [] (List.map (\grade -> ( grade.id, Debounce.init ))) updatedGrades
                }
            <|
                Cmd.batch <|
                    List.map (\category -> createGrade model.session (gradeToForm <| Right ( category.id, draftId )) GotGradeCreate) categoriesWithoutGrades

        GotComments result ->
            API.handleRemoteError result { model | comments = priorityApply (++) result model.comments } Cmd.none

        GotStudentFeedback result ->
            API.handleRemoteError result { model | studentFeedback = priorityApply (++) result model.studentFeedback } Cmd.none

        GotStudentExplanations result ->
            API.handleRemoteError result { model | studentExplanations = priorityApply (++) result model.studentExplanations } Cmd.none

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
                                            createStudentDraft model.session { content = "Insert content here", notes = "", status = Unreviewed, studentId = student.id, parentDraftId = model.draftId } GotCreatedStudentDraft

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

        GroupDraftFormDebounceMsg subMsg ->
            let
                ( debounce, cmd ) =
                    Debounce.update groupDraftDebounceConfig (Debounce.takeLast (\form -> updateGroupDraft model.session model.draftId form GotGroupDraftUpdate)) subMsg model.groupDraftFormDebounce
            in
            ( { model | groupDraftFormDebounce = debounce }, cmd )

        StudentDraftFormDebounceMsg draftId subMsg ->
            case ListExtra.find (Tuple.first >> (==) draftId) model.studentDraftFormDebouncers of
                Just ( _, debouncer ) ->
                    let
                        ( debounce, cmd ) =
                            Debounce.update (studentDraftDebounceConfig draftId) (Debounce.takeLast (\form -> updateStudentDraft model.session draftId form (GotStudentDraftUpdate draftId))) subMsg debouncer
                    in
                    ( { model | studentDraftFormDebouncers = ListExtra.setIf (Tuple.first >> (==) draftId) ( draftId, debounce ) model.studentDraftFormDebouncers }, cmd )

                Nothing ->
                    ( model, Cmd.none )

        GradeFormDebounceMsg gradeId subMsg ->
            case ListExtra.find (Tuple.first >> (==) gradeId) model.gradeFormDebouncers of
                Just ( _, debouncer ) ->
                    let
                        ( debounce, cmd ) =
                            Debounce.update (gradeDebounceConfig gradeId) (Debounce.takeLast (\form -> updateGrade model.session gradeId form (GotGradeUpdate gradeId))) subMsg debouncer
                    in
                    ( { model | gradeFormDebouncers = ListExtra.setIf (Tuple.first >> (==) gradeId) ( gradeId, debounce ) model.gradeFormDebouncers }, cmd )

                Nothing ->
                    ( model, Cmd.none )

        GroupDraftFormInput field ->
            let
                groupDraftForm =
                    model.groupDraftForm

                form =
                    case field of
                        DraftContent value ->
                            { groupDraftForm | content = value }

                        DraftNotes value ->
                            { groupDraftForm | notes = value }

                ( debounce, cmd ) =
                    Debounce.push groupDraftDebounceConfig form model.groupDraftFormDebounce
            in
            ( { model | groupDraftForm = form, groupDraftFormDebounce = debounce }, cmd )

        StudentDraftFormInput draftId field ->
            let
                maybeForm =
                    ListExtra.find (Tuple.first >> (==) draftId) model.studentDraftForms
                        |> Maybe.map Tuple.second

                maybeDebounce =
                    ListExtra.find (Tuple.first >> (==) draftId) model.studentDraftFormDebouncers
                        |> Maybe.map Tuple.second
            in
            case ( maybeForm, maybeDebounce ) of
                ( Just form, Just debounce ) ->
                    let
                        updatedForm =
                            case field of
                                DraftContent value ->
                                    { form | content = value }

                                DraftNotes value ->
                                    { form | notes = value }

                        ( updatedDebounce, cmd ) =
                            Debounce.push (studentDraftDebounceConfig draftId) updatedForm debounce
                    in
                    ( { model | studentDraftForms = ListExtra.setIf (Tuple.first >> (==) draftId) ( draftId, updatedForm ) model.studentDraftForms, studentDraftFormDebouncers = ListExtra.setIf (Tuple.first >> (==) draftId) ( draftId, updatedDebounce ) model.studentDraftFormDebouncers }, cmd )

                _ ->
                    ( model, Cmd.none )

        GradeFormInput gradeId field ->
            let
                maybeForm =
                    ListExtra.find (Tuple.first >> (==) gradeId) model.gradeForms
                        |> Maybe.map Tuple.second

                maybeDebounce =
                    ListExtra.find (Tuple.first >> (==) gradeId) model.gradeFormDebouncers
                        |> Maybe.map Tuple.second
            in
            case ( maybeForm, maybeDebounce ) of
                ( Just form, Just debounce ) ->
                    let
                        updatedForm =
                            case field of
                                Score value ->
                                    { form | score = value }

                                GradeNotes value ->
                                    { form | note = value }

                        ( updatedDebounce, cmd ) =
                            Debounce.push (gradeDebounceConfig gradeId) updatedForm debounce
                    in
                    ( { model
                        | gradeForms = ListExtra.setIf (Tuple.first >> (==) gradeId) ( gradeId, updatedForm ) model.gradeForms
                        , gradeFormDebouncers = ListExtra.setIf (Tuple.first >> (==) gradeId) ( gradeId, updatedDebounce ) model.gradeFormDebouncers
                      }
                    , cmd
                    )

                _ ->
                    ( model, Cmd.none )

        CommentFormInput field ->
            let
                updatedForm =
                    case model.commentForm of
                        Just form ->
                            case field of
                                CommentContent value ->
                                    Just { form | content = value }

                        Nothing ->
                            Nothing
            in
            ( { model | commentForm = updatedForm }, Cmd.none )

        GotGroupDraftUpdate result ->
            ( { model | groupDraftUpdate = result }, Cmd.none )

        GotStudentDraftUpdate draftId result ->
            case ListExtra.find (Tuple.first >> (==) draftId) model.studentDraftUpdates of
                Just _ ->
                    ( { model | studentDraftUpdates = ListExtra.setIf (Tuple.first >> (==) draftId) ( draftId, result ) model.studentDraftUpdates }, Cmd.none )

                Nothing ->
                    ( { model | studentDraftUpdates = ( draftId, result ) :: model.studentDraftUpdates }, Cmd.none )

        CommentSubmitClicked ->
            case model.commentForm of
                Just form ->
                    ( model, createComment model.session form GotCommentCreate )

                Nothing ->
                    ( model, Cmd.none )

        CommentDeleteClicked id ->
            ( model, deleteComment model.session id (GotCommentDelete id) )

        GotGradeCreate result ->
            let
                updatedGrades =
                    priorityMap List.singleton (::) result model.grades
            in
            ( { model
                | grades = updatedGrades
                , gradeForms = priorityUnwrap model.gradeForms (tupleBiFunc .id (Left >> gradeToForm) >> List.singleton) (\_ grades -> List.map (tupleBiFunc .id (Left >> gradeToForm)) grades) result updatedGrades
                , gradeFormDebouncers = RemoteData.unwrap [] (List.map (\grade -> ( grade.id, Debounce.init ))) updatedGrades
              }
            , Cmd.none
            )

        GotGradeUpdate id result ->
            let
                updatedGrades =
                    priorityMap List.singleton (ListExtra.setIf (.id >> (==) id)) result model.grades
            in
            API.handleRemoteError result
                { model
                    | grades = updatedGrades
                    , gradeForms = priorityUnwrap model.gradeForms (tupleBiFunc .id (Left >> gradeToForm) >> List.singleton) (\_ grades -> List.map (tupleBiFunc .id (Left >> gradeToForm)) grades) result updatedGrades
                    , gradeFormDebouncers = RemoteData.unwrap [] (List.map (\grade -> ( grade.id, Debounce.init ))) updatedGrades
                }
                Cmd.none

        GotCommentCreate result ->
            case result of
                Success comment ->
                    ( { model
                        | comments = RemoteData.map ((::) comment) model.comments
                        , commentResult = NotAsked
                        , commentForm = Nothing
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model | commentResult = result }, Cmd.none )

        GotCommentDelete id result ->
            case result of
                Success _ ->
                    ( { model | comments = RemoteData.map (ListExtra.filterNot (.id >> (==) id)) model.comments }, Cmd.none )

                _ ->
                    {- TODO: Currently no ergonomic way to track comment delete errors -}
                    ( model, Cmd.none )


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
                                                    , Textarea.onInput (DraftContent >> GroupDraftFormInput)
                                                    , Textarea.attrs [ placeholder "Write the feedback for the whole group here." ]
                                                    , case model.groupDraftUpdate of
                                                        Success updatedDraft ->
                                                            if updatedDraft.content == model.groupDraftForm.content then
                                                                Textarea.success

                                                            else
                                                                Textarea.attrs []

                                                        Failure _ ->
                                                            Textarea.danger

                                                        _ ->
                                                            Textarea.attrs []
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
                                                    , Textarea.onInput (DraftNotes >> GroupDraftFormInput)
                                                    , Textarea.attrs [ placeholder "Write the notes for the whole group here. Nothing in these notes will be present in the draft the group sees." ]
                                                    , case model.groupDraftUpdate of
                                                        Success updatedDraft ->
                                                            if Maybe.withDefault "" updatedDraft.notes == model.groupDraftForm.notes then
                                                                Textarea.success

                                                            else
                                                                Textarea.attrs []

                                                        Failure _ ->
                                                            Textarea.danger

                                                        _ ->
                                                            Textarea.attrs []
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


viewCategoryGrade : Grade -> GradeForm -> Category -> ListGroup.Item Msg
viewCategoryGrade grade form category =
    ListGroup.li []
        [ Form.form []
            [ Form.row []
                [ Form.colLabel [ Col.md3 ] [ text category.name ]
                , Form.col [ Col.md4 ]
                    [ Input.number
                        [ Input.attrs [ placeholder "Score / 100" ]
                        , Input.value <| String.fromInt form.score
                        , Input.onInput (String.toInt >> Maybe.withDefault 0 >> Score >> GradeFormInput grade.id)
                        ]
                    ]
                , Form.col [ Col.md5 ]
                    [ Input.text
                        [ Input.attrs [ placeholder "Notes" ]
                        , Input.value form.note
                        , Input.onInput (GradeNotes >> GradeFormInput grade.id)
                        ]
                    ]
                ]
            ]
        ]


viewStudentDraft : Model -> StudentDraft -> List (Html Msg)
viewStudentDraft model draft =
    let
        form =
            case ListExtra.find (Tuple.first >> (==) draft.id) model.studentDraftForms of
                Just ( _, f ) ->
                    f

                Nothing ->
                    studentDraftToForm <| Left draft

        grades =
            RemoteData.withDefault [] model.grades

        viewCat category =
            let
                maybeGrade =
                    ListExtra.find (\grade -> grade.categoryId == category.id && grade.draftId == draft.id) grades

                maybeForm =
                    case maybeGrade of
                        Just grade ->
                            Maybe.map Tuple.second <| ListExtra.find (Tuple.first >> (==) grade.id) model.gradeForms

                        _ ->
                            Nothing
            in
            case ( maybeGrade, maybeForm ) of
                ( Just grade, Just gradeForm ) ->
                    Just <| viewCategoryGrade grade gradeForm category

                ( Just grade, Nothing ) ->
                    Just <| viewCategoryGrade grade (gradeToForm <| Left grade) category

                _ ->
                    Nothing

        categoryGradeList =
            RemoteData.unwrap [] (List.filterMap viewCat) model.categories
    in
    [ Grid.simpleRow
        [ Grid.col [ Col.md12 ]
            [ case ListExtra.find (.id >> (==) draft.studentId) (RemoteData.withDefault [] model.students) of
                Just student ->
                    h3 [] [ text <| student.firstName ++ " " ++ student.lastName ]

                Nothing ->
                    text ""
            ]
        ]
    , Grid.simpleRow
        [ Grid.col [ Col.md12 ]
            [ Grid.simpleRow
                [ Grid.col [ Col.md6 ]
                    [ viewFeedback model draft.id ]
                , Grid.col [ Col.md6 ]
                    [ Grid.simpleRow
                        [ Grid.col [ Col.md12 ]
                            [ Card.config []
                                |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
                                    [ h3 []
                                        [ text "Draft"
                                        ]
                                    , h5 []
                                        [ Common.iconTooltip "question-circle" "Record feedback about the student here"
                                        ]
                                    ]
                                |> Card.block []
                                    [ Block.custom <|
                                        Form.form []
                                            [ Form.group []
                                                [ Textarea.textarea
                                                    [ Textarea.rows 8
                                                    , Textarea.value form.content
                                                    , Textarea.onInput (DraftContent >> StudentDraftFormInput draft.id)
                                                    , Textarea.attrs [ placeholder "Write the feedback for the student here." ]
                                                    , case ListExtra.find (Tuple.first >> (==) draft.id) model.studentDraftUpdates of
                                                        Just ( _, result ) ->
                                                            case result of
                                                                Success updatedDraft ->
                                                                    if updatedDraft.content == form.content then
                                                                        Textarea.success

                                                                    else
                                                                        Textarea.attrs []

                                                                Failure _ ->
                                                                    Textarea.danger

                                                                _ ->
                                                                    Textarea.attrs []

                                                        Nothing ->
                                                            Textarea.attrs []
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
                                        [ text "Notes"
                                        ]
                                    , h5 []
                                        [ Common.iconTooltip "question-circle" "Record your notes about the student here"
                                        ]
                                    ]
                                |> Card.block []
                                    [ Block.custom <|
                                        Form.form []
                                            [ Form.group []
                                                [ Textarea.textarea
                                                    [ Textarea.rows 8
                                                    , Textarea.value form.notes
                                                    , Textarea.onInput (DraftNotes >> StudentDraftFormInput draft.id)
                                                    , Textarea.attrs [ placeholder "Write the notes for the student here." ]
                                                    , case ListExtra.find (Tuple.first >> (==) draft.id) model.studentDraftUpdates of
                                                        Just ( _, result ) ->
                                                            case result of
                                                                Success updatedDraft ->
                                                                    if Maybe.withDefault "" updatedDraft.notes == form.notes then
                                                                        Textarea.success

                                                                    else
                                                                        Textarea.attrs []

                                                                Failure _ ->
                                                                    Textarea.danger

                                                                _ ->
                                                                    Textarea.attrs []

                                                        Nothing ->
                                                            Textarea.attrs []
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
                                        [ text "Grades"
                                        ]
                                    , h5 []
                                        [ Common.iconTooltip "question-circle" "Grade the student according to each category here"
                                        ]
                                    ]
                                |> Card.listGroup categoryGradeList
                                |> Card.view
                            ]
                        ]
                    ]
                ]
            ]
        ]
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
                            List.concat <| List.map (viewStudentDraft model) <| List.sortBy (.id >> unwrapDraftId) drafts

                        Failure error ->
                            [ Grid.simpleRow [ Grid.col [] [ h3 [ class "text-danger" ] [ (API.getErrorBody >> API.errorBodyToString >> text) error ] ] ] ]

                        _ ->
                            [ Grid.simpleRow [ Grid.col [] [ Common.loading ] ] ]
                   )
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)


tupleBiFunc : (a -> b) -> (a -> c) -> a -> ( b, c )
tupleBiFunc fun1 fun2 val =
    ( fun1 val, fun2 val )
