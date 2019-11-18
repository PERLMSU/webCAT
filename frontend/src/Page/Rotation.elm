module Page.Rotation exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (..)
import API.Classrooms exposing (..)
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
import Validate exposing (Validator, ifBlank, ifInvalidEmail, ifNotInt, ifNothing, validate)


type ModalState
    = Hidden
    | RotationFormVisible (Maybe RotationId) RotationForm (APIData Rotation) Modal.Visibility
    | RotationGroupFormVisible (Maybe RotationGroupId) RotationGroupForm (APIData RotationGroup) Modal.Visibility
    | RotationDeleteVisible Rotation (APIData ()) Modal.Visibility
    | RotationGroupDeleteVisible RotationGroup (APIData ()) Modal.Visibility


type alias Model =
    { session : Session
    , rotationId : RotationId
    , timezone : Time.Zone
    , time : Maybe Time.Posix

    -- Remote data
    , rotation : APIData Rotation
    , sections : APIData (List Section)
    , rotations : APIData (List Rotation)
    , rotationGroups : APIData (List RotationGroup)
    , users : APIData (List User)

    -- Modals
    , modalState : ModalState
    , rotationFormErrors : List ( RotationFormField, String )
    , rotationGroupFormErrors : List ( RotationGroupFormField, String )
    }


type RotationFormField
    = RotationNumber String
    | RotationDescription String
    | RotationSectionId (Maybe SectionId)


type RotationGroupFormField
    = RotationGroupNumber String
    | RotationGroupDescription String
    | RotationGroupRotationId (Maybe RotationId)
    | Users (List UserId)


type Msg
    = GotSession Session
      -- Remote data
    | GotRotation (APIData Rotation)
    | GotRotations (APIData (List Rotation))
    | GotSections (APIData (List Section))
    | GotRotationGroups (APIData (List RotationGroup))
    | GotCategories (APIData (List Category))
    | GotUsers (APIData (List User))
      -- Rotation buttons
    | RotationEditClicked Rotation
    | RotationDeleteClicked Rotation
      -- RotationGroup table
    | RotationGroupClicked RotationGroup
    | RotationGroupNewClicked
    | RotationGroupEditClicked RotationGroup
    | RotationGroupDeleteClicked RotationGroup
      -- Modal and form
    | ModalAnimate Modal.Visibility
    | ModalClose
    | RotationFormUpdate RotationFormField
    | RotationGroupFormUpdate RotationGroupFormField
    | FormSubmitClicked
    | DeleteSubmitClicked
      -- Form results
    | GotRotationFormResult (APIData Rotation)
    | GotRotationDeleteResult (APIData ())
    | GotRotationGroupFormResult (APIData RotationGroup)
    | GotRotationGroupDeleteResult (APIData ())
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> RotationId -> ( Model, Cmd Msg )
init session rotationId =
    let
        model =
            { session = session
            , rotation = Loading
            , rotationId = rotationId
            , rotationGroups = Loading
            , rotations = Loading
            , sections = Loading
            , users = Loading
            , timezone = Time.utc
            , time = Nothing
            , modalState = Hidden
            , rotationFormErrors = []
            , rotationGroupFormErrors = []
            }
    in
    case Session.credential session of
        Nothing ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Login )

        Just _ ->
            ( model
            , Cmd.batch
                [ getRotation session rotationId GotRotation
                , sections session Nothing Nothing GotSections
                , users session GotUsers
                , rotationGroups session (Just rotationId) GotRotationGroups
                , categories session Nothing GotCategories
                , Task.perform GotTimezone Time.here
                , Task.perform GotTime Time.now
                ]
            )


toSession : Model -> Session
toSession model =
    model.session


viewRotationGroups : Model -> Html Msg
viewRotationGroups model =
    let
        tableConfig =
            { render = \item -> [ String.fromInt item.number, Maybe.withDefault "" item.description ]
            , headers = [ "Name", "Description" ]
            , onClick = RotationGroupClicked
            , onEdit = RotationGroupEditClicked
            , onDelete = RotationGroupDeleteClicked
            }
    in
    div [ class "p-2" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-11" ]
                [ h4 [ class "" ] [ text "RotationGroups" ]
                ]
            , div [ class "col-lg-1" ] [ Button.button [ Button.success, Button.onClick RotationGroupNewClicked ] [ text "New" ] ]
            ]
        , hr [] []
        , case model.rotationGroups of
            Success rotationGroups ->
                Table.view tableConfig rotationGroups

            Failure e ->
                text <| (API.getErrorBody >> API.errorBodyToString) e

            _ ->
                Common.loading
        ]


viewRotationModal : Model -> Either ( Maybe RotationId, RotationForm, APIData Rotation ) ( Rotation, APIData () ) -> Modal.Visibility -> Html Msg
viewRotationModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                selectConfig : Select.Model Section SectionId Msg
                selectConfig =
                    { id = "sectionId"
                    , itemId = .id
                    , unwrapId = unwrapSectionId
                    , toItemId = SectionId
                    , selection = RemoteData.unwrap Nothing (ListExtra.find (.id >> (==) form.sectionId)) model.sections
                    , options = RemoteData.withDefault [] model.sections
                    , onSelectionChanged = RotationSectionId >> RotationFormUpdate
                    , render = .number
                    }

                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.rotationFormErrors of
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
                            text "New Rotation"

                        Just _ ->
                            text "Edit Rotation"
                    ]
                |> Modal.body []
                    [ case remote of
                        Loading ->
                            Common.loading

                        _ ->
                            Form.form []
                                [ Form.group []
                                    [ Form.label [ for "number" ] [ text "Number" ]
                                    , Input.text
                                        [ Input.id "number"
                                        , Input.value <| String.fromInt form.number
                                        , Input.onInput (RotationNumber >> RotationFormUpdate)
                                        ]
                                    , feedback (RotationNumber <| String.fromInt form.number)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "description" ] [ text "Description" ]
                                    , Textarea.textarea
                                        [ Textarea.rows 3
                                        , Textarea.id "description"
                                        , Textarea.value form.description
                                        , Textarea.onInput (RotationDescription >> RotationFormUpdate)
                                        ]
                                    , Form.help [] [ text "Optional description for the rotation" ]
                                    ]
                                , Form.group []
                                    [ Form.label [ for "sectionId" ] [ text "Section" ]
                                    , Select.view selectConfig
                                    , Form.help [] [ text "What Section does this rotation belong to?" ]
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

        Right ( rotation, remote ) ->
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.small
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 [] [ text "Delete Rotation" ]
                |> Modal.body []
                    [ p [] [ text <| "Are you sure you want to delete rotation '" ++ (String.fromInt rotation.number) ++ "' ?" ]
                    , p [] [ text "Deleting this rotation will also delete its rotationGroups, their rotations, and their rotation groups." ]
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


viewRotationGroupModal : Model -> Either ( Maybe RotationGroupId, RotationGroupForm, APIData RotationGroup ) ( RotationGroup, APIData () ) -> Modal.Visibility -> Html Msg
viewRotationGroupModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                selectConfig : Select.Model Rotation RotationId Msg
                selectConfig =
                    { id = "rotationId"
                    , itemId = .id
                    , unwrapId = unwrapRotationId
                    , toItemId = RotationId
                    , selection = RemoteData.unwrap Nothing (ListExtra.find (.id >> (==) form.rotationId)) model.rotations
                    , options = RemoteData.withDefault [] model.rotations
                    , onSelectionChanged = RotationGroupRotationId >> RotationGroupFormUpdate
                    , render = .number >> String.fromInt
                    }

                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.rotationGroupFormErrors of
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
                            text "New RotationGroup"

                        Just _ ->
                            text "Edit RotationGroup"
                    ]
                |> Modal.body []
                    [ case remote of
                        Loading ->
                            Common.loading

                        _ ->
                            Form.form []
                                [ Form.group []
                                    [ Form.label [ for "number" ] [ text "Number" ]
                                    , Input.text
                                        [ Input.id "number"
                                        , Input.value <| String.fromInt form.number
                                        , Input.onInput (RotationGroupNumber >> RotationGroupFormUpdate)
                                        ]
                                    , feedback (RotationGroupNumber <| String.fromInt form.number)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "description" ] [ text "Description" ]
                                    , Textarea.textarea
                                        [ Textarea.rows 3
                                        , Textarea.id "description"
                                        , Textarea.value form.description
                                        , Textarea.onInput (RotationGroupDescription >> RotationGroupFormUpdate)
                                        ]
                                    , Form.help [] [ text "Optional description for the rotationGroup" ]
                                    , feedback (RotationGroupDescription form.description)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "rotationId" ] [ text "Rotation" ]
                                    , Select.view selectConfig
                                    , Form.help [] [ text "What Rotation does this Rotation Group belong to?" ]
                                    , feedback (RotationGroupRotationId <| Just form.rotationId)
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

        Right ( rotationGroup, remote ) ->
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.small
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 [] [ text "Delete RotationGroup" ]
                |> Modal.body []
                    [ p [] [ text <| "Are you sure you want to delete rotationGroup '" ++ (String.fromInt rotationGroup.number) ++ "' ?" ]
                    , p [] [ text "Deleting this rotationGroup will also delete its rotationGroups, their rotations, and their rotation groups." ]
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


viewRotation : Model -> Html Msg
viewRotation model =
    let
        number =
            RemoteData.unwrap "" (.number >> String.fromInt) model.rotation

        description =
            RemoteData.unwrap "" (.description >> Maybe.withDefault "") model.rotation
    in
    Card.config []
        |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
            [ h3 [] [ text <| "Rotation: " ++ number ]
            , RemoteData.unwrap (text "") (\rotation -> Button.button [ Button.success, Button.onClick (RotationEditClicked rotation) ] [ text "Edit" ]) model.rotation
            ]
        |> Card.listGroup
            [ ListGroup.li [] [ text <| "Number: " ++ number ]
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
            [ card <| viewRotation model
            , card <| viewRotationGroups model
            , case model.modalState of
                RotationFormVisible maybeId form remote visibility ->
                    viewRotationModal model (Left ( maybeId, form, remote )) visibility

                RotationDeleteVisible rotation remote visibility ->
                    viewRotationModal model (Right ( rotation, remote )) visibility

                RotationGroupFormVisible maybeId form remote visibility ->
                    viewRotationGroupModal model (Left ( maybeId, form, remote )) visibility

                RotationGroupDeleteVisible rotationGroup remote visibility ->
                    viewRotationGroupModal model (Right ( rotationGroup, remote )) visibility

                _ ->
                    text ""
            ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.rotationId

        GotRotation response ->
            API.handleRemoteError response { model | rotation = response } Cmd.none

        GotRotations response ->
            API.handleRemoteError response { model | rotations = response } Cmd.none

        GotUsers response ->
            API.handleRemoteError response { model | users = response } Cmd.none

        GotRotationGroups response ->
            API.handleRemoteError response { model | rotationGroups = RemoteData.map (List.sortBy .number) response } Cmd.none

        GotTimezone tz ->
            ( { model | timezone = tz }, Cmd.none )

        GotTime time ->
            ( { model | time = Just time }, Cmd.none )

        RotationEditClicked rotation ->
            ( { model | modalState = RotationFormVisible (Just rotation.id) (nitRotationForm <| Just rotation) NotAsked Modal.shown }, Cmd.none )

        RotationDeleteClicked rotation ->
            ( { model | modalState = RotationDeleteVisible rotation NotAsked Modal.shown }, Cmd.none )

        ModalClose ->
            case model.modalState of
                RotationFormVisible id form rotation _ ->
                    ( { model | modalState = RotationFormVisible id form rotation Modal.hidden }, Cmd.none )

                RotationDeleteVisible id result _ ->
                    ( { model | modalState = RotationDeleteVisible id result Modal.hidden }, Cmd.none )

                RotationGroupFormVisible id form rotationGroup _ ->
                    ( { model | modalState = RotationGroupFormVisible id form rotationGroup Modal.hidden }, Cmd.none )

                RotationGroupDeleteVisible id result _ ->
                    ( { model | modalState = RotationGroupDeleteVisible id result Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                RotationFormVisible id form rotation _ ->
                    ( { model | modalState = RotationFormVisible id form rotation visibility }, Cmd.none )

                RotationDeleteVisible id result _ ->
                    ( { model | modalState = RotationDeleteVisible id result visibility }, Cmd.none )

                RotationGroupFormVisible id form rotationGroup _ ->
                    ( { model | modalState = RotationGroupFormVisible id form rotationGroup visibility }, Cmd.none )

                RotationGroupDeleteVisible id result _ ->
                    ( { model | modalState = RotationGroupDeleteVisible id result visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        RotationFormUpdate field ->
            case model.modalState of
                RotationFormVisible id form rotation visibility ->
                    let
                        updatedForm =
                            case field of
                                RotationNumber data ->
                                    { form | number = (String.toInt >> Maybe.withDefault 0) data }

                                RotationDescription description ->
                                    { form | description = description }

                                SectionId maybeId ->
                                    case maybeId of
                                        Just data ->
                                            { form | sectionId = data }

                                        Nothing ->
                                            form
                    in
                    ( { model | modalState = RotationFormVisible id updatedForm rotation visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        RotationGroupFormUpdate field ->
            case model.modalState of
                RotationGroupFormVisible id form rotationGroup visibility ->
                    let
                        updatedForm =
                            case field of
                                RotationGroupNumber data ->
                                    { form | number = (String.toInt >> Maybe.withDefault 0) data }

                                RotationGroupDescription description ->
                                    { form | description = description }

                                RotationId maybeId ->
                                    case maybeId of
                                        Just data ->
                                            { form | rotationId = data }

                                        Nothing ->
                                            form
                    in
                    ( { model | modalState = RotationGroupFormVisible id updatedForm rotationGroup visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        RotationGroupClicked rotationGroup ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.RotationGroup rotationGroup.id) )

        RotationGroupNewClicked ->
            ( { model | modalState = RotationGroupFormVisible Nothing (initRotationGroupForm <| Right model.rotationId) NotAsked Modal.shown }, Cmd.none )

        RotationGroupEditClicked rotationGroup ->
            ( { model | modalState = RotationGroupFormVisible (Just rotationGroup.id) (initRotationGroupForm <| Left rotationGroup) NotAsked Modal.shown }, Cmd.none )

        RotationGroupDeleteClicked rotationGroup ->
            ( { model | modalState = RotationGroupDeleteVisible rotationGroup NotAsked Modal.shown }, Cmd.none )

        FormSubmitClicked ->
            case model.modalState of
                RotationFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all [ ifNotInt .name ( RotationNumber form.name, "Number must be an integer" ) ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | rotationFormErrors = [], modalState = RotationFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateRotation model.session id form GotRotationFormResult )

                                Nothing ->
                                    ( updatedModel, createRotation model.session form GotRotationFormResult )

                        Err errors ->
                            ( { model | rotationFormErrors = errors }, Cmd.none )

                RotationGroupFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all
                                []
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | rotationGroupFormErrors = [], modalState = RotationGroupFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateRotationGroup model.session id form GotRotationGroupFormResult )

                                Nothing ->
                                    ( updatedModel, createRotationGroup model.session form GotRotationGroupFormResult )

                        Err errors ->
                            ( { model | rotationGroupFormErrors = errors }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotRotationFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        RotationFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = RotationFormVisible maybeId form result Modal.hidden }, getRotation model.session model.rotationId GotRotation )

                                _ ->
                                    ( { model | modalState = RotationFormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotRotationDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        RotationDeleteVisible rotation _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = RotationDeleteVisible rotation result Modal.hidden }, getRotation model.session model.rotationId GotRotation )

                                _ ->
                                    ( { model | modalState = RotationDeleteVisible rotation result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotRotationGroupFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        RotationGroupFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = RotationGroupFormVisible maybeId form result Modal.hidden }, rotationGroups model.session (Just model.rotationId) GotRotationGroups )

                                _ ->
                                    ( { model | modalState = RotationGroupFormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotRotationGroupDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        RotationGroupDeleteVisible rotationGroup _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = RotationGroupDeleteVisible rotationGroup result Modal.hidden }, rotationGroups model.session (Just model.rotationId) GotRotationGroups )

                                _ ->
                                    ( { model | modalState = RotationGroupDeleteVisible rotationGroup result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        DeleteSubmitClicked ->
            case model.modalState of
                RotationDeleteVisible data _ visibility ->
                    ( { model | modalState = RotationDeleteVisible data Loading visibility }, deleteRotation model.session data.id GotRotationDeleteResult )

                RotationGroupDeleteVisible data _ visibility ->
                    ( { model | modalState = RotationGroupDeleteVisible data Loading visibility }, deleteRotationGroup model.session data.id GotRotationGroupDeleteResult )

                _ ->
                    ( model, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (Session.navKey model.session)
        , case model.modalState of
            RotationFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            RotationDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            RotationGroupFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            RotationGroupDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]
