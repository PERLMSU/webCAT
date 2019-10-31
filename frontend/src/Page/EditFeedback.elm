module Page.EditFeedback exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, APIResult, Error(..))
import API.Drafts exposing (..)
import API.Feedback exposing (..)
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checkbox
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
import Either exposing (Either(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as ListExtra
import RemoteData exposing (RemoteData(..))
import RemoteData.Extra exposing (priorityApply, priorityMap)
import Route
import Session as Session exposing (Session)
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , draftId : DraftId
    , parentCategoryId : Maybe CategoryId

    -- Remote data
    , draft : APIData (Either GroupDraft StudentDraft)
    , categories : APIData (List Category)
    , observations : APIData (List Observation)
    , feedback : APIData (List Feedback)
    , explanations : APIData (List Explanation)
    , studentFeedback : APIData (List StudentFeedback)
    , studentExplanations : APIData (List StudentExplanation)
    }


type Msg
    = GotSession Session
    | GotStudentFeedback (APIData (List StudentFeedback))
    | GotStudentExplanations (APIData (List StudentExplanation))
    | GotCategory (APIData Category)
    | GotCategories (APIData (List Category))
    | GotObservations (APIData (List Observation))
    | GotFeedback (APIData (List Feedback))
    | GotExplanations (APIData (List Explanation))
      -- Feedback change results
    | GotAddFeedbackResult (APIResult StudentFeedback)
    | GotDeleteFeedbackResult FeedbackId (APIResult ())
    | GotAddExplanationResult (APIResult StudentExplanation)
    | GotDeleteExplanationResult ExplanationId (APIResult ())
      -- Buttons
    | SubCategorySelected CategoryId
      -- Checkboxes
    | FeedbackChecked FeedbackId Bool
    | ExplanationChecked FeedbackId ExplanationId Bool
      -- Init stuff
    | GotDraft (APIData (Either GroupDraft StudentDraft))


init : Session -> DraftId -> Maybe CategoryId -> ( Model, Cmd Msg )
init session draftId maybeCategoryId =
    let
        model =
            { session = session
            , draftId = draftId
            , parentCategoryId = maybeCategoryId
            , draft = Loading
            , studentFeedback = Loading
            , studentExplanations = Loading
            , categories = Loading
            , observations = Loading
            , feedback = Loading
            , explanations = Loading
            }
    in
    if Session.isAuthenticated session then
        let
            feedbackCommands =
                [ studentFeedback session draftId GotStudentFeedback
                , studentExplanations session draftId Nothing GotStudentExplanations
                ]
        in
        case maybeCategoryId of
            Just parentCategoryId ->
                ( model
                , Cmd.batch <| category session parentCategoryId GotCategory :: feedbackCommands
                )

            Nothing ->
                ( model
                , Cmd.batch <| draft session draftId GotDraft :: feedbackCommands
                )

    else
        ( model
        , Route.replaceUrl (Session.navKey session) Route.Login
        )


toSession : Model -> Session
toSession model =
    model.session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.draftId model.parentCategoryId

        GotObservations result ->
            API.handleRemoteError result { model | observations = priorityApply (++) result model.observations } <| Cmd.batch <| RemoteData.unwrap [] (List.map (\observation -> feedback model.session (Just observation.id) GotFeedback)) result

        GotFeedback result ->
            API.handleRemoteError result { model | feedback = priorityApply (++) result model.feedback } <| Cmd.batch <| RemoteData.unwrap [] (List.map (\feedback -> explanations model.session (Just feedback.id) GotExplanations)) result

        GotExplanations result ->
            API.handleRemoteError result { model | explanations = priorityApply (++) result model.explanations } Cmd.none

        GotStudentFeedback feedback ->
            ( { model | studentFeedback = feedback }, Cmd.none )

        GotStudentExplanations explanations ->
            ( { model | studentExplanations = explanations }, Cmd.none )

        GotCategory result ->
            let
                newModel =
                    { model | categories = priorityMap List.singleton (::) result model.categories }

                commands =
                    [ RemoteData.unwrap Cmd.none (\category -> observations model.session (Just category.id) GotObservations) result
                    , RemoteData.unwrap Cmd.none (\category -> categories model.session (Just category.id) GotCategories) result
                    ]
            in
            API.handleRemoteError result newModel <| Cmd.batch commands

        GotCategories result ->
            API.handleRemoteError result { model | categories = priorityApply (++) result model.categories } <| Cmd.batch <| RemoteData.unwrap [] (List.map (\category -> observations model.session (Just category.id) GotObservations)) result

        SubCategorySelected id ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.EditFeedback model.draftId (Just id)) )

        FeedbackChecked feedbackId isChecked ->
            case model.studentFeedback of
                Success studentFeedback ->
                    case isChecked of
                        True ->
                            case ListExtra.find (.feedbackId >> (==) feedbackId) studentFeedback of
                                Just _ ->
                                    (model, Cmd.none)
                                Nothing ->
                                    ( model, createStudentFeedback model.session model.draftId feedbackId GotAddFeedbackResult )

                        False ->
                            case ListExtra.find (.feedbackId >> (==) feedbackId) studentFeedback of
                                Just item ->
                                    ( model, deleteStudentFeedback model.session item.id (GotDeleteFeedbackResult feedbackId) )

                                Nothing ->
                                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ExplanationChecked feedbackId explanationId isChecked ->
            case model.studentExplanations of
                Success studentExplanations ->
                    case isChecked of
                        True ->
                            case ListExtra.find (.explanationId >> (==) explanationId) studentExplanations of
                                Just _ ->
                                    (model, Cmd.none)
                                Nothing ->
                                    ( model, createStudentExplanation model.session model.draftId feedbackId explanationId GotAddExplanationResult )

                        False ->
                            case ListExtra.find (.explanationId >> (==) explanationId) studentExplanations of
                                Just item ->
                                    ( model, deleteStudentExplanation model.session item.id (GotDeleteExplanationResult explanationId) )

                                Nothing ->
                                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotAddFeedbackResult result ->
            case result of
                Ok value ->
                    ( { model | studentFeedback = RemoteData.map ((::) value) model.studentFeedback }, Cmd.none )

                Err error ->
                    let
                        _ =
                            Debug.log "err" error
                    in
                    -- TODO: Work out global message passing for errors to the main process
                    ( model, Cmd.none )

        GotDeleteFeedbackResult id result ->
            case result of
                Ok _ ->
                    ( { model
                        | studentFeedback = RemoteData.map (ListExtra.filterNot (.feedbackId >> (==) id)) model.studentFeedback
                        , studentExplanations = RemoteData.map (ListExtra.filterNot (.feedbackId >> (==) id)) model.studentExplanations
                      }
                    , Cmd.none
                    )

                Err error ->
                    -- TODO: Work out global message passing for errors to the main process
                    ( model, Cmd.none )

        GotAddExplanationResult result ->
            case result of
                Ok value ->
                    ( { model | studentExplanations = RemoteData.map ((::) value) model.studentExplanations }, Cmd.none )

                Err error ->
                    -- TODO: Work out global message passing for errors to the main process
                    ( model, Cmd.none )

        GotDeleteExplanationResult id result ->
            case result of
                Ok _ ->
                    ( { model | studentExplanations = RemoteData.map (ListExtra.filterNot (.explanationId >> (==) id)) model.studentExplanations }, Cmd.none )

                Err error ->
                    -- TODO: Work out global message passing for errors to the main process
                    ( model, Cmd.none )

        GotDraft result ->
            case result of
                Success draft ->
                    case draft of
                        Left groupDraft ->
                            ( model, Cmd.batch <| List.map (\id -> category model.session id GotCategory) groupDraft.categories )

                        Right studentDraft ->
                            ( model, Cmd.batch <| List.map (\id -> category model.session id GotCategory) studentDraft.categories )

                Failure error ->
                    -- TODO: Work out showing error states way better
                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


hasFeedbackItem : Model -> FeedbackId -> Bool
hasFeedbackItem model id =
    case model.studentFeedback of
        Success feedback ->
            List.any (\item -> item.feedbackId == id) feedback

        _ ->
            False


hasExplanation : Model -> ExplanationId -> Bool
hasExplanation model id =
    case model.studentExplanations of
        Success explanations ->
            List.any (\item -> item.explanationId == id) explanations

        _ ->
            False


viewCategories : Model -> List Category -> List (Grid.Column Msg)
viewCategories model categories =
    let
        viewExplanation explanation =
            ListGroup.li []
                [ Checkbox.checkbox
                        [ Checkbox.onCheck <| ExplanationChecked explanation.feedbackId explanation.id
                        , Checkbox.checked <| hasExplanation model explanation.id

                        -- Only enable if the parent feedback item is checked
                        , Checkbox.disabled <| not <| hasFeedbackItem model explanation.feedbackId
                        ] explanation.content
                    ]

        viewFeedback feedback =
            ListGroup.li []
                [ div []
                    [ Checkbox.checkbox
                        [ Checkbox.onCheck <| FeedbackChecked feedback.id
                        , Checkbox.checked <| hasFeedbackItem model feedback.id
                        ]
                        feedback.content
                    , ListGroup.ul <| List.map viewExplanation (List.sortBy .content <| RemoteData.unwrap [] (List.filter (.feedbackId >> (==) feedback.id)) model.explanations)
                    ]
                      
                ]

        viewObservation observation =
            Block.custom <|
                div [] <|
                    [ p [] [ text observation.content ]
                    , ListGroup.ul <| List.map viewFeedback (List.sortBy .content <| RemoteData.unwrap [] (List.filter (.observationId >> (==) observation.id)) model.feedback)
                    ]

        viewSubcategory category =
            Block.link [ Route.href (Route.EditFeedback model.draftId (Just category.id)) ] [ text category.name ]

        viewCategory category =
            Grid.col []
                [ Card.config []
                    |> Card.headerH2 [] [ text category.name ]
                    |> Card.block []
                        (Block.titleH4 [] [ text "Sub-Categories" ]
                            :: List.map viewSubcategory (List.sortBy .name <| RemoteData.unwrap [] (List.filter (.parentCategoryId >> (==) (Just category.id))) model.categories)
                        )
                    |> Card.block []
                        (Block.titleH4 [] [ text "Observations" ]
                            :: List.map viewObservation (List.sortBy .content <| RemoteData.unwrap [] (List.filter (.categoryId >> (==) category.id)) model.observations)
                        )
                    |> Card.view
                ]
    in
    case model.parentCategoryId of
        Just categoryId ->
            List.map viewCategory <| List.filter (.id >> (==) categoryId) categories

        Nothing ->
            List.map viewCategory <| List.sortBy .name <| List.filter (.parentCategoryId >> (==) Nothing) categories


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Edit Feedback"
    , content =
        Grid.container [] <|
            case model.categories of
                Success categories ->
                    [ Grid.simpleRow <| viewCategories model categories ]

                Failure error ->
                    [ Grid.simpleRow [ Grid.col [] [ h3 [ class "text-danger" ] [ (API.getErrorBody >> API.errorBodyToString >> text) error ] ] ] ]

                _ ->
                    [ Grid.simpleRow [ Grid.col [] [ Common.loading ] ] ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
