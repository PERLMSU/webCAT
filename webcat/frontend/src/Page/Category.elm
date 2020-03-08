module Page.Category exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

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
    | CategoryFormVisible (Maybe CategoryId) CategoryForm (APIData Category) Modal.Visibility
    | ObservationFormVisible (Maybe ObservationId) ObservationForm (APIData Observation) Modal.Visibility
    | CategoryDeleteVisible Category (APIData ()) Modal.Visibility
    | ObservationDeleteVisible Observation (APIData ()) Modal.Visibility


type alias Model =
    { session : Session
    , categoryId : CategoryId
    , timezone : Time.Zone
    , time : Maybe Time.Posix

    -- Remote data
    , category : APIData Category
    , observations : APIData (List Observation)
    , semesters : APIData (List Semester)
    , categories : APIData (List Category)

    -- Modals
    , modalState : ModalState
    , categoryFormErrors : List ( CategoryFormField, String )
    , observationFormErrors : List ( ObservationFormField, String )
    }


type CategoryFormField
    = CategoryName String
    | CategoryDescription String
    | CategoryParentCategoryId (Maybe CategoryId)


type ObservationFormField
    = ObservationContent String
    | ObservationObservationType ObservationType
    | ObservationCategoryId (Maybe CategoryId)


type Msg
    = GotSession Session
      -- Remote data
    | GotCategory (APIData Category)
    | GotSemesters (APIData (List Semester))
    | GotObservations (APIData (List Observation))
    | GotCategories (APIData (List Category))
      -- Category buttons
    | CategoryClicked Category
    | CategoryNewClicked
    | CategoryEditClicked Category
    | CategoryDeleteClicked Category
      -- Observation table
    | ObservationClicked Observation
    | ObservationNewClicked
    | ObservationEditClicked Observation
    | ObservationDeleteClicked Observation
      -- Modal and form
    | ModalAnimate Modal.Visibility
    | ModalClose
    | CategoryFormUpdate CategoryFormField
    | ObservationFormUpdate ObservationFormField
    | FormSubmitClicked
    | DeleteSubmitClicked
      -- Form results
    | GotCategoryFormResult (APIData Category)
    | GotCategoryDeleteResult (APIData ())
    | GotObservationFormResult (APIData Observation)
    | GotObservationDeleteResult (APIData ())
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> CategoryId -> ( Model, Cmd Msg )
init session categoryId =
    let
        model =
            { session = session
            , category = Loading
            , categoryId = categoryId
            , observations = Loading
            , semesters = Loading
            , categories = Loading
            , timezone = Time.utc
            , time = Nothing
            , modalState = Hidden
            , categoryFormErrors = []
            , observationFormErrors = []
            }
    in
    case Session.credential session of
        Nothing ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Login )

        Just _ ->
            ( model
            , Cmd.batch
                [ getCategory session categoryId GotCategory
                , semesters session GotSemesters
                , observations session (Just categoryId) GotObservations
                , categories session Nothing GotCategories
                , Task.perform GotTimezone Time.here
                , Task.perform GotTime Time.now
                ]
            )


toSession : Model -> Session
toSession model =
    model.session


viewObservations : Model -> Html Msg
viewObservations model =
    let
        tableConfig =
            { render = \item -> [ item.content ]
            , headers = [ "Content" ]
            , onClick = ObservationClicked
            , onEdit = ObservationEditClicked
            , onDelete = ObservationDeleteClicked
            }
    in
    div [ class "p-2" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-11" ]
                [ h4 [ class "" ] [ text "Observations" ]
                ]
            , div [ class "col-lg-1" ] [ Button.button [ Button.success, Button.onClick ObservationNewClicked ] [ text "New" ] ]
            ]
        , hr [] []
        , case model.observations of
            Success observations ->
                Table.view tableConfig observations

            Failure e ->
                text <| (API.getErrorBody >> API.errorBodyToString) e

            _ ->
                Common.loading
        ]


viewCategoryModal : Model -> Either ( Maybe CategoryId, CategoryForm, APIData Category ) ( Category, APIData () ) -> Modal.Visibility -> Html Msg
viewCategoryModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                selectConfig : Select.Model Category CategoryId Msg
                selectConfig =
                    { id = "parentCategoryId"
                    , itemId = .id
                    , unwrapId = unwrapCategoryId
                    , toItemId = CategoryId
                    , selection =
                        case form.parentCategoryId of
                            Just id ->
                                RemoteData.unwrap Nothing (ListExtra.find (.id >> (==) id)) model.categories

                            Nothing ->
                                Nothing
                    , options = RemoteData.withDefault [] model.categories
                    , onSelectionChanged = CategoryParentCategoryId >> CategoryFormUpdate
                    , render = .name
                    }

                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.categoryFormErrors of
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
                            text "New Category"

                        Just _ ->
                            text "Edit Category"
                    ]
                |> Modal.body []
                    [ case remote of
                        Loading ->
                            Common.loading

                        _ ->
                            Form.form []
                                [ Form.group []
                                    [ Form.label [ for "name" ] [ text "Name" ]
                                    , Input.text
                                        [ Input.id "name"
                                        , Input.value form.name
                                        , Input.onInput (CategoryName >> CategoryFormUpdate)
                                        ]
                                    , feedback (CategoryName form.name)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "description" ] [ text "Description" ]
                                    , Textarea.textarea
                                        [ Textarea.rows 3
                                        , Textarea.id "description"
                                        , Textarea.value form.description
                                        , Textarea.onInput (CategoryDescription >> CategoryFormUpdate)
                                        ]
                                    , Form.help [] [ text "Optional description for the category" ]
                                    ]
                                , Form.group []
                                    [ Form.label [ for "parentCategoryId" ] [ text "Parent Category" ]
                                    , Select.view selectConfig
                                    , Form.help [] [ text "What category is this category a sub category of?" ]
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

        Right ( category, remote ) ->
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.small
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 [] [ text "Delete Category" ]
                |> Modal.body []
                    [ p [] [ text <| "Are you sure you want to delete category '" ++ category.name ++ "' ?" ]
                    , p [] [ text "Deleting this category will also delete its observations, feedback items, and explanations" ]
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
                selectConfig : Select.Model Category CategoryId Msg
                selectConfig =
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
                                    , Select.view selectConfig
                                    , Form.help [] [ text "What type of observation is this?" ]
                                    , feedback (ObservationObservationType form.type_)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "categoryId" ] [ text "Category" ]
                                    , FormSelect.select
                                        [ FormSelect.onChange (parseType >> ObservationObservationType >> ObservationFormUpdate)
                                        , FormSelect.attrs [ value <| observationTypeToString form.type_ ]
                                        ]
                                        [ FormSelect.item [ value "positive" ] [ text "Positive" ]
                                        , FormSelect.item [ value "neutral" ] [ text "Neutral" ]
                                        , FormSelect.item [ value "negative" ] [ text "Negative" ]
                                        ]
                                    , Form.help [] [ text "What category does this observation belong to?" ]
                                    , feedback (ObservationCategoryId <| Just form.categoryId)
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
                    [ p [] [ text <| "Are you sure you want to delete observation '" ++ String.slice 0 10 (observation.content) ++ "' ?" ]
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


viewCategory : Model -> Html Msg
viewCategory model =
    let
        name =
            RemoteData.unwrap "" .name model.category

        description =
            RemoteData.unwrap "" (.description >> Maybe.withDefault "") model.category
    in
    Card.config []
        |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
            [ h3 [] [ text <| "Category: " ++ name ]
            , RemoteData.unwrap (text "") (\category -> Button.button [ Button.success, Button.onClick (CategoryEditClicked category) ] [ text "Edit" ]) model.category
            ]
        |> Card.listGroup
            [ ListGroup.li [] [ text <| "Name: " ++ name ]
            , ListGroup.li [] [ text <| "Description: " ++ description ]
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
            [ card <| viewCategory model
            , card <| viewObservations model
            , case model.modalState of
                CategoryFormVisible maybeId form remote visibility ->
                    viewCategoryModal model (Left ( maybeId, form, remote )) visibility

                CategoryDeleteVisible category remote visibility ->
                    viewCategoryModal model (Right ( category, remote )) visibility

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
            init session model.categoryId

        GotCategory response ->
            API.handleRemoteError response { model | category = response } Cmd.none

        GotSemesters response ->
            API.handleRemoteError response { model | semesters = response } Cmd.none

        GotObservations response ->
            API.handleRemoteError response { model | observations = RemoteData.map (List.sortBy .content) response } Cmd.none

        GotCategories response ->
            API.handleRemoteError response { model | categories = response } Cmd.none

        GotTimezone tz ->
            ( { model | timezone = tz }, Cmd.none )

        GotTime time ->
            ( { model | time = Just time }, Cmd.none )
        CategoryClicked category ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Category category.id) )

        CategoryNewClicked ->
            ( { model | modalState = CategoryFormVisible Nothing (initCategoryForm Nothing) NotAsked Modal.shown }, Cmd.none )

        CategoryEditClicked category ->
            ( { model | modalState = CategoryFormVisible (Just category.id) (initCategoryForm <| Just category) NotAsked Modal.shown }, Cmd.none )

        CategoryDeleteClicked category ->
            ( { model | modalState = CategoryDeleteVisible category NotAsked Modal.shown }, Cmd.none )

        ModalClose ->
            case model.modalState of
                CategoryFormVisible id form category _ ->
                    ( { model | modalState = CategoryFormVisible id form category Modal.hidden }, Cmd.none )

                CategoryDeleteVisible id result _ ->
                    ( { model | modalState = CategoryDeleteVisible id result Modal.hidden }, Cmd.none )

                ObservationFormVisible id form observation _ ->
                    ( { model | modalState = ObservationFormVisible id form observation Modal.hidden }, Cmd.none )

                ObservationDeleteVisible id result _ ->
                    ( { model | modalState = ObservationDeleteVisible id result Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                CategoryFormVisible id form category _ ->
                    ( { model | modalState = CategoryFormVisible id form category visibility }, Cmd.none )

                CategoryDeleteVisible id result _ ->
                    ( { model | modalState = CategoryDeleteVisible id result visibility }, Cmd.none )

                ObservationFormVisible id form observation _ ->
                    ( { model | modalState = ObservationFormVisible id form observation visibility }, Cmd.none )

                ObservationDeleteVisible id result _ ->
                    ( { model | modalState = ObservationDeleteVisible id result visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        CategoryFormUpdate field ->
            case model.modalState of
                CategoryFormVisible id form category visibility ->
                    let
                        updatedForm =
                            case field of
                                CategoryName data ->
                                    { form | name = data }

                                CategoryDescription data ->
                                    { form | description = data }

                                CategoryParentCategoryId data ->
                                    { form | parentCategoryId = data }

                    in
                    ( { model | modalState = CategoryFormVisible id updatedForm category visibility }, Cmd.none )

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
                                        Just data -> { form | categoryId = data }
                                        Nothing -> form
                    in
                    ( { model | modalState = ObservationFormVisible id updatedForm observation visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ObservationClicked observation ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Observation observation.id) )

        ObservationNewClicked ->
            ( { model | modalState = ObservationFormVisible Nothing (initObservationForm <| Right model.categoryId) NotAsked Modal.shown }, Cmd.none )

        ObservationEditClicked observation ->
            ( { model | modalState = ObservationFormVisible (Just observation.id) (initObservationForm <| Left observation) NotAsked Modal.shown }, Cmd.none )

        ObservationDeleteClicked observation ->
            ( { model | modalState = ObservationDeleteVisible observation NotAsked Modal.shown }, Cmd.none )

        FormSubmitClicked ->
            case model.modalState of
                CategoryFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all [ ifBlank .name ( CategoryName form.name, "Name cannot be blank" ) ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | categoryFormErrors = [], modalState = CategoryFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateCategory model.session id form GotCategoryFormResult )

                                Nothing ->
                                    ( updatedModel, createCategory model.session form GotCategoryFormResult )

                        Err errors ->
                            ( { model | categoryFormErrors = errors }, Cmd.none )

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

        GotCategoryFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        CategoryFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = CategoryFormVisible maybeId form result Modal.hidden }, getCategory model.session model.categoryId GotCategory )

                                _ ->
                                    ( { model | modalState = CategoryFormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotCategoryDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        CategoryDeleteVisible category _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = CategoryDeleteVisible category result Modal.hidden }, getCategory model.session model.categoryId GotCategory )

                                _ ->
                                    ( { model | modalState = CategoryDeleteVisible category result visibility }, Cmd.none )

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
                                Success _ ->
                                    ( { model | modalState = ObservationFormVisible maybeId form result Modal.hidden }, observations model.session (Just model.categoryId) GotObservations )

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
                                    ( { model | modalState = ObservationDeleteVisible observation result Modal.hidden }, observations model.session (Just model.categoryId) GotObservations )

                                _ ->
                                    ( { model | modalState = ObservationDeleteVisible observation result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        DeleteSubmitClicked ->
            case model.modalState of
                CategoryDeleteVisible data _ visibility ->
                    ( { model | modalState = CategoryDeleteVisible data Loading visibility }, deleteCategory model.session data.id GotCategoryDeleteResult )

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
            CategoryFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            CategoryDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            ObservationFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            ObservationDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]
