module Page.Feedback exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (..)
import API.Classrooms exposing (..)
import API.Feedback exposing (..)
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as FormSelect
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Modal as Modal
import Bootstrap.Utilities.Flex as Flex
import Bootstrap.Utilities.Size as Size
import Components.Common as Common
import Components.Multiselect as Multiselect
import Components.Select as Select
import Components.Table as Table
import Date
import Either exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as ListExtra
import RemoteData exposing (..)
import RemoteData.Extra exposing (priorityApply, priorityMap, priorityUnwrap)
import Route
import Session exposing (Session)
import Task
import Time
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, ifNothing, validate)


type ModalState
    = Hidden
    | FeedbackFormVisible (Maybe FeedbackId) FeedbackForm (APIData Feedback) Modal.Visibility
    | FeedbackDeleteVisible Feedback (APIData ()) Modal.Visibility
    | ExplanationFormVisible (Maybe ExplanationId) ExplanationForm (APIData Explanation) Modal.Visibility
    | ExplanationDeleteVisible Explanation (APIData ()) Modal.Visibility


type alias Model =
    { session : Session
    , feedbackId : FeedbackId
    , timezone : Time.Zone
    , time : Maybe Time.Posix

    -- Remote data
    , feedbackItem : APIData Feedback
    , observations : APIData (List Observation)
    , explanations : APIData (List Explanation)
    , feedback : APIData (List Feedback)

    -- Modals
    , modalState : ModalState
    , feedbackFormErrors : List ( FeedbackFormField, String )
    , explanationFormErrors : List ( ExplanationFormField, String )
    }


type FeedbackFormField
    = FeedbackContent String
    | FeedbackObservationId (Maybe ObservationId)


type ExplanationFormField
    = ExplanationContent String
    | ExplanationFeedbackId (Maybe FeedbackId)


type Msg
    = GotSession Session
      -- Remote data
    | GotFeedbackItem (APIData (Feedback))
    | GotObservations (APIData (List Observation))
    | GotExplanations (APIData (List Explanation))
    | GotFeedback (APIData (List Feedback))
      -- Feedback buttons
    | FeedbackClicked Feedback
    | FeedbackNewClicked
    | FeedbackEditClicked Feedback
    | FeedbackDeleteClicked Feedback
      -- Explanation table
    | ExplanationClicked Explanation
    | ExplanationNewClicked
    | ExplanationEditClicked Explanation
    | ExplanationDeleteClicked Explanation
      -- Modal and form
    | ModalAnimate Modal.Visibility
    | ModalClose
    | FeedbackFormUpdate FeedbackFormField
    | ExplanationFormUpdate ExplanationFormField
    | FormSubmitClicked
    | DeleteSubmitClicked
      -- Form results
    | GotFeedbackFormResult (APIData Feedback)
    | GotFeedbackDeleteResult (APIData ())
    | GotExplanationFormResult (APIData Explanation)
    | GotExplanationDeleteResult (APIData ())
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> FeedbackId -> ( Model, Cmd Msg )
init session feedbackId =
    let
        model =
            { session = session
            , feedbackId = feedbackId
            , feedbackItem = Loading
            , observations = Loading
            , explanations = Loading
            , feedback = Loading
            , timezone = Time.utc
            , time = Nothing
            , modalState = Hidden
            , feedbackFormErrors = []
            , explanationFormErrors = []
            }
    in
    case Session.credential session of
        Nothing ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Login )

        Just _ ->
            ( model
            , Cmd.batch
                [ getFeedback session feedbackId GotFeedbackItem
                , explanations session (Just feedbackId) GotExplanations
                , Task.perform GotTimezone Time.here
                , Task.perform GotTime Time.now
                ]
            )


toSession : Model -> Session
toSession model =
    model.session


viewExplanations : Model -> Html Msg
viewExplanations model =
    let
        tableConfig =
            { render = \item -> [ item.content ]
            , headers = [ "Content" ]
            , onClick = ExplanationClicked
            , onEdit = ExplanationEditClicked
            , onDelete = ExplanationDeleteClicked
            }
    in
    div [ class "p-2" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-11" ]
                [ h4 [ class "" ] [ text "Explanations" ]
                ]
            , div [ class "col-lg-1" ] [ Button.button [ Button.success, Button.onClick ExplanationNewClicked ] [ text "New" ] ]
            ]
        , hr [] []
        , case model.explanations of
            Success explanations ->
                Table.view tableConfig explanations

            Failure e ->
                text <| (API.getErrorBody >> API.errorBodyToString) e

            _ ->
                Common.loading
        ]


viewFeedbackModal : Model -> Either ( Maybe FeedbackId, FeedbackForm, APIData Feedback ) ( Feedback, APIData () ) -> Modal.Visibility -> Html Msg
viewFeedbackModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                selectConfig : Select.Model Observation ObservationId Msg
                selectConfig =
                    { id = "observationId"
                    , itemId = .id
                    , unwrapId = unwrapObservationId
                    , toItemId = ObservationId
                    , selection = RemoteData.unwrap Nothing (ListExtra.find (.id >> (==) form.observationId)) model.observations
                    , options = RemoteData.withDefault [] model.observations
                    , onSelectionChanged = FeedbackObservationId >> FeedbackFormUpdate
                    , render = .content
                    }

                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.feedbackFormErrors of
                        Just ( _, message ) ->
                            Form.invalidFeedback [] [ text message ]

                        Nothing ->
                            text ""
            in
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.large
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 []
                    [ case maybeId of
                        Nothing ->
                            text "New Feedback"

                        Just _ ->
                            text "Edit Feedback"
                    ]
                |> Modal.body []
                    [ case remote of
                        Loading ->
                            Common.loading

                        _ ->
                            Form.form []
                                [ Form.group []
                                    [ Form.label [ for "content" ] [ text "Content" ]
                                    , Input.text
                                        [ Input.id "content"
                                        , Input.value form.content
                                        , Input.onInput (FeedbackContent >> FeedbackFormUpdate)
                                        ]
                                    , feedback (FeedbackContent form.content)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "parentObservationId" ] [ text "Parent Observation" ]
                                    , Select.view selectConfig
                                    , Form.help [] [ text "What observation does this feedback belong to?" ]
                                    ]
                                ]
                    ]
                |> Modal.footer []
                    [ Button.button
                        [ Button.outlinePrimary
                        , Button.attrs [ onClick FormSubmitClicked ]
                        ]
                        [ text "Submit" ]
                    , Button.button
                        [ Button.outlineSecondary
                        , Button.attrs [ onClick ModalClose ]
                        ]
                        [ text "Cancel" ]
                    ]
                |> Modal.view visibility

        Right ( feedback, remote ) ->
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.small
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 [] [ text "Delete Feedback" ]
                |> Modal.body []
                    [ p [] [ text <| "Are you sure you want to delete feedback '" ++ feedback.content ++ "' ?" ]
                    , p [] [ text "Deleting this category will also delete its explanations" ]
                    , p [ class "text-danger" ] [ text "This is not reversible." ]
                    ]
                |> Modal.footer []
                    [ Button.button
                        [ Button.outlineDanger
                        , Button.attrs [ onClick DeleteSubmitClicked ]
                        ]
                        [ text "Delete" ]
                    ]
                |> Modal.view visibility


viewExplanationModal : Model -> Either ( Maybe ExplanationId, ExplanationForm, APIData Explanation ) ( Explanation, APIData () ) -> Modal.Visibility -> Html Msg
viewExplanationModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                feedbackSelectConfig : Select.Model Feedback FeedbackId Msg
                feedbackSelectConfig =
                    { id = "feedbackId"
                    , itemId = .id
                    , unwrapId = unwrapFeedbackId
                    , toItemId = FeedbackId
                    , selection = RemoteData.unwrap Nothing (ListExtra.find (.id >> (==) form.feedbackId)) model.feedback
                    , options = RemoteData.withDefault [] model.feedback
                    , onSelectionChanged = ExplanationFeedbackId >> ExplanationFormUpdate
                    , render = .content
                    }


                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.explanationFormErrors of
                        Just ( _, message ) ->
                            Form.invalidFeedback [] [ text message ]

                        Nothing ->
                            text ""
            in
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.large
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 []
                    [ case maybeId of
                        Nothing ->
                            text "New Explanation"

                        Just _ ->
                            text "Edit Explanation"
                    ]
                |> Modal.body []
                    [ case remote of
                        Loading ->
                            Common.loading

                        _ ->
                            Form.form []
                                [ Form.group []
                                    [ Form.label [ for "content" ] [ text "Content" ]
                                    , Input.text
                                        [ Input.id "content"
                                        , Input.value form.content
                                        , Input.onInput (ExplanationContent >> ExplanationFormUpdate)
                                        ]
                                    , feedback (ExplanationContent form.content)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "type" ] [ text "Type" ]
                                    , Select.view feedbackSelectConfig
                                    , Form.help [] [ text "What feedback item does this explanation belong to?" ]
                                    , feedback (ExplanationFeedbackId <| Just form.feedbackId)
                                    ]
                                ]
                    ]
                |> Modal.footer []
                    [ Button.button
                        [ Button.outlinePrimary
                        , Button.attrs [ onClick FormSubmitClicked ]
                        ]
                        [ text "Submit" ]
                    , Button.button
                        [ Button.outlineSecondary
                        , Button.attrs [ onClick ModalClose ]
                        ]
                        [ text "Cancel" ]
                    ]
                |> Modal.view visibility

        Right ( explanation, remote ) ->
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.small
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 [] [ text "Delete Explanation" ]
                |> Modal.body []
                    [ p [] [ text <| "Are you sure you want to delete explanation '" ++ String.slice 0 10 explanation.content ++ "' ?" ]
                    , p [ class "text-danger" ] [ text "This is not reversible." ]
                    ]
                |> Modal.footer []
                    [ Button.button
                        [ Button.outlineDanger
                        , Button.onClick DeleteSubmitClicked
                        ]
                        [ text "Delete" ]
                    ]
                |> Modal.view visibility


viewFeedback : Model -> Html Msg
viewFeedback model =
    let
        content =
            RemoteData.unwrap "" .content model.feedbackItem
    in
    Card.config []
        |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
            [ h3 [] [ text <| "Feedback: " ++ content ]
            , RemoteData.unwrap (text "") (\observation -> Button.button [ Button.success, Button.onClick (FeedbackEditClicked observation) ] [ text "Edit" ]) model.feedbackItem
            ]
        |> Card.listGroup
            [ ListGroup.li [] [ text <| "content: " ++ content ]
            ]
        |> Card.view


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Dashboard"
    , content =
        let
            card inner =
                Grid.simpleRow [ Grid.col [] [ inner ] ]
        in
        Grid.container []
            [ card <| viewFeedback model
            , card <| viewExplanations model
            , case model.modalState of
                FeedbackFormVisible maybeId form remote visibility ->
                    viewFeedbackModal model (Left ( maybeId, form, remote )) visibility

                FeedbackDeleteVisible category remote visibility ->
                    viewFeedbackModal model (Right ( category, remote )) visibility

                ExplanationFormVisible maybeId form remote visibility ->
                    viewExplanationModal model (Left ( maybeId, form, remote )) visibility

                ExplanationDeleteVisible explanation remote visibility ->
                    viewExplanationModal model (Right ( explanation, remote )) visibility

                _ ->
                    text ""
            ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.feedbackId

        GotFeedbackItem response ->
            API.handleRemoteError response { model | feedbackItem = response } Cmd.none

        GotFeedback response ->
            API.handleRemoteError response { model | feedback = response } Cmd.none

        GotObservations response ->
            API.handleRemoteError response { model | observations = RemoteData.map (List.sortBy .content) response } Cmd.none

        GotExplanations response ->
            API.handleRemoteError response { model | explanations = RemoteData.map (List.sortBy .content) response } Cmd.none

        GotTimezone tz ->
            ( { model | timezone = tz }, Cmd.none )

        GotTime time ->
            ( { model | time = Just time }, Cmd.none )

        FeedbackClicked feedback ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.FeedbackItem feedback.id) )

        FeedbackNewClicked ->
            case model.feedbackItem of
                Success feedback ->
                    ( { model | modalState = FeedbackFormVisible Nothing (initFeedbackForm <| Right feedback.observationId) NotAsked Modal.shown }, Cmd.none )
                _ ->
                    ( model, Cmd.none )


        FeedbackEditClicked feedback ->
            ( { model | modalState = FeedbackFormVisible (Just feedback.id) (initFeedbackForm <| Left feedback) NotAsked Modal.shown }, Cmd.none )

        FeedbackDeleteClicked category ->
            ( { model | modalState = FeedbackDeleteVisible category NotAsked Modal.shown }, Cmd.none )

        ModalClose ->
            case model.modalState of
                FeedbackFormVisible id form category _ ->
                    ( { model | modalState = FeedbackFormVisible id form category Modal.hidden }, Cmd.none )

                FeedbackDeleteVisible id result _ ->
                    ( { model | modalState = FeedbackDeleteVisible id result Modal.hidden }, Cmd.none )

                ExplanationFormVisible id form explanation _ ->
                    ( { model | modalState = ExplanationFormVisible id form explanation Modal.hidden }, Cmd.none )

                ExplanationDeleteVisible id result _ ->
                    ( { model | modalState = ExplanationDeleteVisible id result Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                FeedbackFormVisible id form category _ ->
                    ( { model | modalState = FeedbackFormVisible id form category visibility }, Cmd.none )

                FeedbackDeleteVisible id result _ ->
                    ( { model | modalState = FeedbackDeleteVisible id result visibility }, Cmd.none )

                ExplanationFormVisible id form explanation _ ->
                    ( { model | modalState = ExplanationFormVisible id form explanation visibility }, Cmd.none )

                ExplanationDeleteVisible id result _ ->
                    ( { model | modalState = ExplanationDeleteVisible id result visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        FeedbackFormUpdate field ->
            case model.modalState of
                FeedbackFormVisible id form category visibility ->
                    let
                        updatedForm =
                            case field of
                                FeedbackContent data ->
                                    { form | content = data }

                                FeedbackObservationId maybeId ->
                                    case maybeId of
                                        Just data ->
                                            { form | observationId = data }

                                        Nothing ->
                                            form
                    in
                    ( { model | modalState = FeedbackFormVisible id updatedForm category visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ExplanationFormUpdate field ->
            case model.modalState of
                ExplanationFormVisible id form explanation visibility ->
                    let
                        updatedForm =
                            case field of
                                ExplanationContent data ->
                                    { form | content = data }

                                ExplanationFeedbackId maybeId ->
                                    case maybeId of
                                        Just data ->
                                            { form | feedbackId = data }

                                        Nothing ->
                                            form
                    in
                    ( { model | modalState = ExplanationFormVisible id updatedForm explanation visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ExplanationClicked explanation ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Explanation explanation.id) )

        ExplanationNewClicked ->
            ( { model | modalState = ExplanationFormVisible Nothing (initExplanationForm <| Right model.feedbackId) NotAsked Modal.shown }, Cmd.none )

        ExplanationEditClicked explanation ->
            ( { model | modalState = ExplanationFormVisible (Just explanation.id) (initExplanationForm <| Left explanation) NotAsked Modal.shown }, Cmd.none )

        ExplanationDeleteClicked explanation ->
            ( { model | modalState = ExplanationDeleteVisible explanation NotAsked Modal.shown }, Cmd.none )

        FormSubmitClicked ->
            case model.modalState of
                FeedbackFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all [ ifBlank .content ( FeedbackContent form.content, "Content cannot be blank" ) ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | feedbackFormErrors = [], modalState = FeedbackFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateFeedback model.session id form GotFeedbackFormResult )

                                Nothing ->
                                    ( updatedModel, createFeedback model.session form GotFeedbackFormResult )

                        Err errors ->
                            ( { model | feedbackFormErrors = errors }, Cmd.none )

                ExplanationFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all
                                [ ifBlank .content ( ExplanationContent form.content, "Content must not be blank" )
                                ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | explanationFormErrors = [], modalState = ExplanationFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateExplanation model.session id form GotExplanationFormResult )

                                Nothing ->
                                    ( updatedModel, createExplanation model.session form GotExplanationFormResult )

                        Err errors ->
                            ( { model | explanationFormErrors = errors }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotFeedbackFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        FeedbackFormVisible maybeId form _ visibility ->
                            case result of
                                Success item ->
                                    ( { model | modalState = FeedbackFormVisible maybeId form result Modal.hidden }, feedback model.session (Just item.observationId) GotFeedback )

                                _ ->
                                    ( { model | modalState = FeedbackFormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotFeedbackDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        FeedbackDeleteVisible item _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = FeedbackDeleteVisible item result Modal.hidden }, feedback model.session (Just item.observationId) GotFeedback )

                                _ ->
                                    ( { model | modalState = FeedbackDeleteVisible item result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotExplanationFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        ExplanationFormVisible maybeId form _ visibility ->
                            case result of
                                Success explanation ->
                                    ( { model | modalState = ExplanationFormVisible maybeId form result Modal.hidden }, explanations model.session (Just explanation.feedbackId) GotExplanations )

                                _ ->
                                    ( { model | modalState = ExplanationFormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotExplanationDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        ExplanationDeleteVisible explanation _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = ExplanationDeleteVisible explanation result Modal.hidden }, explanations model.session (Just explanation.feedbackId) GotExplanations )

                                _ ->
                                    ( { model | modalState = ExplanationDeleteVisible explanation result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        DeleteSubmitClicked ->
            case model.modalState of
                FeedbackDeleteVisible data _ visibility ->
                    ( { model | modalState = FeedbackDeleteVisible data Loading visibility }, deleteFeedback model.session data.id GotFeedbackDeleteResult )

                ExplanationDeleteVisible data _ visibility ->
                    ( { model | modalState = ExplanationDeleteVisible data Loading visibility }, deleteExplanation model.session data.id GotExplanationDeleteResult )

                _ ->
                    ( model, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (Session.navKey model.session)
        , case model.modalState of
            FeedbackFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            FeedbackDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            ExplanationFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            ExplanationDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]
