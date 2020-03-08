module Page.Observation exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

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
    | ObservationFormVisible (Maybe ObservationId) ObservationForm (APIData Observation) Modal.Visibility
    | ObservationDeleteVisible Observation (APIData ()) Modal.Visibility
    | FeedbackFormVisible (Maybe FeedbackId) FeedbackForm (APIData Feedback) Modal.Visibility
    | FeedbackDeleteVisible Feedback (APIData ()) Modal.Visibility


type alias Model =
    { session : Session
    , observationId : ObservationId
    , timezone : Time.Zone
    , time : Maybe Time.Posix

    -- Remote data
    , observation : APIData Observation
    , observations : APIData (List Observation)
    , categories : APIData (List Category)
    , feedback : APIData (List Feedback)

    -- Modals
    , modalState : ModalState
    , feedbackFormErrors : List ( FeedbackFormField, String )
    , observationFormErrors : List ( ObservationFormField, String )
    }


type FeedbackFormField
    = FeedbackContent String
    | FeedbackObservationId (Maybe ObservationId)


type ObservationFormField
    = ObservationContent String
    | ObservationObservationType ObservationType
    | ObservationCategoryId (Maybe CategoryId)


type Msg
    = GotSession Session
      -- Remote data
    | GotObservation (APIData Observation)
    | GotObservations (APIData (List Observation))
    | GotCategories (APIData (List Category))
    | GotFeedback (APIData (List Feedback))
      -- Category buttons
    | FeedbackClicked Feedback
    | FeedbackNewClicked
    | FeedbackEditClicked Feedback
    | FeedbackDeleteClicked Feedback
      -- Observation table
    | ObservationClicked Observation
    | ObservationNewClicked
    | ObservationEditClicked Observation
    | ObservationDeleteClicked Observation
      -- Modal and form
    | ModalAnimate Modal.Visibility
    | ModalClose
    | FeedbackFormUpdate FeedbackFormField
    | ObservationFormUpdate ObservationFormField
    | FormSubmitClicked
    | DeleteSubmitClicked
      -- Form results
    | GotFeedbackFormResult (APIData Feedback)
    | GotFeedbackDeleteResult (APIData ())
    | GotObservationFormResult (APIData Observation)
    | GotObservationDeleteResult (APIData ())
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> ObservationId -> ( Model, Cmd Msg )
init session observationId =
    let
        model =
            { session = session
            , observationId = observationId
            , observation = Loading
            , observations = Loading
            , categories = Loading
            , feedback = Loading
            , timezone = Time.utc
            , time = Nothing
            , modalState = Hidden
            , feedbackFormErrors = []
            , observationFormErrors = []
            }
    in
    case Session.credential session of
        Nothing ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Login )

        Just _ ->
            ( model
            , Cmd.batch
                [ getObservation session observationId GotObservation
                , feedback session (Just observationId) GotFeedback
                , Task.perform GotTimezone Time.here
                , Task.perform GotTime Time.now
                ]
            )


toSession : Model -> Session
toSession model =
    model.session


viewFeedback : Model -> Html Msg
viewFeedback model =
    let
        tableConfig =
            { render = \item -> [ item.content ]
            , headers = [ "Content" ]
            , onClick = FeedbackClicked
            , onEdit = FeedbackEditClicked
            , onDelete = FeedbackDeleteClicked
            }
    in
    div [ class "p-2" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-11" ]
                [ h4 [ class "" ] [ text "Feedback" ]
                ]
            , div [ class "col-lg-1" ] [ Button.button [ Button.success, Button.onClick FeedbackNewClicked ] [ text "New" ] ]
            ]
        , hr [] []
        , case model.feedback of
            Success feedback ->
                Table.view tableConfig feedback

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


viewObservationModal : Model -> Either ( Maybe ObservationId, ObservationForm, APIData Observation ) ( Observation, APIData () ) -> Modal.Visibility -> Html Msg
viewObservationModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                categorySelectConfig : Select.Model Category CategoryId Msg
                categorySelectConfig =
                    { id = "categoryId"
                    , itemId = .id
                    , unwrapId = unwrapCategoryId
                    , toItemId = CategoryId
                    , selection = RemoteData.unwrap Nothing (ListExtra.find (.id >> (==) form.categoryId)) model.categories
                    , options = RemoteData.withDefault [] model.categories
                    , onSelectionChanged = ObservationCategoryId >> ObservationFormUpdate
                    , render = .name
                    }

                parseType str =
                    case str of
                        "positive" ->
                            Positive

                        "negative" ->
                            Negative

                        _ ->
                            Neutral

                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.observationFormErrors of
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
                            text "New Observation"

                        Just _ ->
                            text "Edit Observation"
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
                                        [ Input.id "number"
                                        , Input.value form.content
                                        , Input.onInput (ObservationContent >> ObservationFormUpdate)
                                        ]
                                    , feedback (ObservationContent form.content)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "type" ] [ text "Type" ]
                                    , Select.view categorySelectConfig
                                    , Form.help [] [ text "What category does this observation belong to?" ]
                                    , feedback (ObservationCategoryId <| Just form.categoryId)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "categoryId" ] [ text "Feedback" ]
                                    , FormSelect.select
                                        [ FormSelect.onChange (parseType >> ObservationObservationType >> ObservationFormUpdate)
                                        , FormSelect.attrs [ value <| observationTypeToString form.type_ ]
                                        ]
                                        [ FormSelect.item [ value "positive" ] [ text "Positive" ]
                                        , FormSelect.item [ value "neutral" ] [ text "Neutral" ]
                                        , FormSelect.item [ value "negative" ] [ text "Negative" ]
                                        ]
                                    , Form.help [] [ text "What type of observation is this?" ]
                                    , feedback (ObservationObservationType form.type_)
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

        Right ( observation, remote ) ->
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.small
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 [] [ text "Delete Observation" ]
                |> Modal.body []
                    [ p [] [ text <| "Are you sure you want to delete observation '" ++ String.slice 0 10 observation.content ++ "' ?" ]
                    , p [] [ text "Deleting this observation will also delete its observations, their rotations, and their rotation groups." ]
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


viewObservation  : Model -> Html Msg
viewObservation model =
    let
        content =
            RemoteData.unwrap "" .content model.observation
    in
    Card.config []
        |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
            [ h3 [] [ text <| "Observation: " ++ content ]
            , RemoteData.unwrap (text "") (\observation -> Button.button [ Button.success, Button.onClick (ObservationEditClicked observation) ] [ text "Edit" ]) model.observation
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
            [ card <| viewObservation model
            , card <| viewFeedback model
            , case model.modalState of
                FeedbackFormVisible maybeId form remote visibility ->
                    viewFeedbackModal model (Left ( maybeId, form, remote )) visibility

                FeedbackDeleteVisible category remote visibility ->
                    viewFeedbackModal model (Right ( category, remote )) visibility

                ObservationFormVisible maybeId form remote visibility ->
                    viewObservationModal model (Left ( maybeId, form, remote )) visibility

                ObservationDeleteVisible observation remote visibility ->
                    viewObservationModal model (Right ( observation, remote )) visibility

                _ ->
                    text ""
            ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.observationId

        GotFeedback response ->
            API.handleRemoteError response { model | feedback = response } Cmd.none

        GotObservations response ->
            API.handleRemoteError response { model | observations = RemoteData.map (List.sortBy .content) response } Cmd.none
        
        GotCategories response ->
            API.handleRemoteError response { model | categories = RemoteData.map (List.sortBy .name) response } Cmd.none

        GotObservation response ->
            API.handleRemoteError response { model | observation = response } Cmd.none


        GotTimezone tz ->
            ( { model | timezone = tz }, Cmd.none )

        GotTime time ->
            ( { model | time = Just time }, Cmd.none )

        FeedbackClicked feedback ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.FeedbackItem feedback.id) )

        FeedbackNewClicked ->
            ( { model | modalState = FeedbackFormVisible Nothing (initFeedbackForm <| Right model.observationId) NotAsked Modal.shown }, Cmd.none )

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

                ObservationFormVisible id form observation _ ->
                    ( { model | modalState = ObservationFormVisible id form observation Modal.hidden }, Cmd.none )

                ObservationDeleteVisible id result _ ->
                    ( { model | modalState = ObservationDeleteVisible id result Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                FeedbackFormVisible id form category _ ->
                    ( { model | modalState = FeedbackFormVisible id form category visibility }, Cmd.none )

                FeedbackDeleteVisible id result _ ->
                    ( { model | modalState = FeedbackDeleteVisible id result visibility }, Cmd.none )

                ObservationFormVisible id form observation _ ->
                    ( { model | modalState = ObservationFormVisible id form observation visibility }, Cmd.none )

                ObservationDeleteVisible id result _ ->
                    ( { model | modalState = ObservationDeleteVisible id result visibility }, Cmd.none )

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

        ObservationFormUpdate field ->
            case model.modalState of
                ObservationFormVisible id form observation visibility ->
                    let
                        updatedForm =
                            case field of
                                ObservationContent data ->
                                    { form | content = data }

                                ObservationObservationType data ->
                                    { form | type_ = data }

                                ObservationCategoryId maybeId ->
                                    case maybeId of
                                        Just data ->
                                            { form | categoryId = data }

                                        Nothing ->
                                            form
                    in
                    ( { model | modalState = ObservationFormVisible id updatedForm observation visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ObservationClicked observation ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Observation observation.id) )

        ObservationNewClicked ->
            case model.observation of
                Success observation ->
                    ( { model | modalState = ObservationFormVisible Nothing (initObservationForm <| Right observation.categoryId) NotAsked Modal.shown }, Cmd.none )
                _ -> (model, Cmd.none)

        ObservationEditClicked observation ->
            ( { model | modalState = ObservationFormVisible (Just observation.id) (initObservationForm <| Left observation) NotAsked Modal.shown }, Cmd.none )

        ObservationDeleteClicked observation ->
            ( { model | modalState = ObservationDeleteVisible observation NotAsked Modal.shown }, Cmd.none )

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

                ObservationFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all
                                [ ifBlank .content ( ObservationContent form.content, "Content must not be blank" )
                                ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | observationFormErrors = [], modalState = ObservationFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateObservation model.session id form GotObservationFormResult )

                                Nothing ->
                                    ( updatedModel, createObservation model.session form GotObservationFormResult )

                        Err errors ->
                            ( { model | observationFormErrors = errors }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotFeedbackFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        FeedbackFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = FeedbackFormVisible maybeId form result Modal.hidden }, feedback model.session (Just model.observationId) GotFeedback )

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
                        FeedbackDeleteVisible category _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = FeedbackDeleteVisible category result Modal.hidden }, feedback model.session (Just model.observationId) GotFeedback )

                                _ ->
                                    ( { model | modalState = FeedbackDeleteVisible category result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotObservationFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        ObservationFormVisible maybeId form _ visibility ->
                            case result of
                                Success observation ->
                                    ( { model | modalState = ObservationFormVisible maybeId form result Modal.hidden }, observations model.session (Just observation.categoryId) GotObservations )

                                _ ->
                                    ( { model | modalState = ObservationFormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotObservationDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        ObservationDeleteVisible observation _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = ObservationDeleteVisible observation result Modal.hidden }, observations model.session (Just observation.categoryId) GotObservations )

                                _ ->
                                    ( { model | modalState = ObservationDeleteVisible observation result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        DeleteSubmitClicked ->
            case model.modalState of
                FeedbackDeleteVisible data _ visibility ->
                    ( { model | modalState = FeedbackDeleteVisible data Loading visibility }, deleteFeedback model.session data.id GotFeedbackDeleteResult )

                ObservationDeleteVisible data _ visibility ->
                    ( { model | modalState = ObservationDeleteVisible data Loading visibility }, deleteObservation model.session data.id GotObservationDeleteResult )

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

            ObservationFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            ObservationDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]
