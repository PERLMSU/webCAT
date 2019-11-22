module Page.RotationGroup exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

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
    | RotationGroupFormVisible (Maybe RotationGroupId) RotationGroupForm (APIData RotationGroup) Modal.Visibility
    | RotationGroupDeleteVisible RotationGroup (APIData ()) Modal.Visibility


type alias Model =
    { session : Session
    , rotationGroupId : RotationGroupId
    , timezone : Time.Zone
    , time : Maybe Time.Posix

    -- Remote data
    , rotations : APIData (List Rotation)
    , rotationGroup : APIData RotationGroup
    , users : APIData (List User)

    -- Modals
    , modalState : ModalState
    , rotationGroupFormErrors : List ( RotationGroupFormField, String )
    }


type RotationGroupFormField
    = RotationGroupNumber String
    | RotationGroupDescription String
    | RotationGroupRotationId (Maybe RotationId)
    | RotationGroupUsers (List UserId)


type Msg
    = GotSession Session
      -- Remote data
    | GotRotations (APIData (List Rotation))
    | GotRotationGroup (APIData RotationGroup)
    | GotUsers (APIData (List User))
      -- RotationGroup table
    | RotationGroupEditClicked RotationGroup
    | RotationGroupDeleteClicked RotationGroup
      -- Modal and form
    | ModalAnimate Modal.Visibility
    | ModalClose
    | RotationGroupFormUpdate RotationGroupFormField
    | FormSubmitClicked
    | DeleteSubmitClicked
      -- Form results
    | GotRotationGroupFormResult (APIData RotationGroup)
    | GotRotationGroupDeleteResult (APIData ())
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> RotationGroupId -> ( Model, Cmd Msg )
init session rotationGroupId =
    let
        model =
            { session = session
            , rotationGroupId = rotationGroupId
            , rotationGroup = Loading
            , rotations = Loading
            , users = Loading
            , timezone = Time.utc
            , time = Nothing
            , modalState = Hidden
            , rotationGroupFormErrors = []
            }
    in
    case Session.credential session of
        Nothing ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Login )

        Just _ ->
            ( model
            , Cmd.batch
                [ getRotationGroup session rotationGroupId GotRotationGroup
                , rotations session Nothing GotRotations
                , users session GotUsers
                , Task.perform GotTimezone Time.here
                , Task.perform GotTime Time.now
                ]
            )


toSession : Model -> Session
toSession model =
    model.session


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

                multiSelectConfig : Multiselect.Model User UserId Msg
                multiSelectConfig =
                    { id = "users"
                    , itemId = .id
                    , unwrapId = unwrapUserId
                    , toItemId = UserId
                    , selection = RemoteData.unwrap [] (List.filter (\u-> List.member u.id form.users)) model.users
                    , options = RemoteData.withDefault [] model.users
                    , onSelectionChanged = RotationGroupUsers >> RotationGroupFormUpdate
                    , render = (\user-> user.firstName ++ " " ++ user.lastName ++ " - " ++ (roleToReadableString user.role))
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
                            text "New Rotation Group"

                        Just _ ->
                            text "Edit Rotation Group"
                    ]
                |> Modal.body []
                    [ case remote of
                        Loading ->
                            Common.loading

                        _ ->
                            Form.form []
                                [ Form.group []
                                    [ Form.label [ for "number" ] [ text "Number" ]
                                    , Input.number
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
                                , Form.group []
                                    [ Form.label [ for "users" ] [ text "Users" ]
                                    , Multiselect.view multiSelectConfig
                                    , Form.help [] [ text "What users are in the rotation group?" ]
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
                    [ p [] [ text <| "Are you sure you want to delete rotationGroup '" ++ String.fromInt rotationGroup.number ++ "' ?" ]
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


viewRotationGroup : Model -> Html Msg
viewRotationGroup model =
    let
        number =
            RemoteData.unwrap "" (.number >> String.fromInt) model.rotationGroup

        description =
            RemoteData.unwrap "" (.description >> Maybe.withDefault "") model.rotationGroup
    in
    Card.config []
        |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
            [ h3 [] [ text <| "Rotation Group: " ++ number ]
            , RemoteData.unwrap (text "") (\rotationGroup -> Button.button [ Button.success, Button.onClick (RotationGroupEditClicked rotationGroup) ] [ text "Edit" ]) model.rotationGroup
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
            [ card <| viewRotationGroup model
            , case model.modalState of
                RotationGroupFormVisible maybeId form remote visibility ->
                    viewRotationGroupModal model (Left ( maybeId, form, remote )) visibility

                RotationGroupDeleteVisible rotationGroup remote visibility ->
                    viewRotationGroupModal model (Right ( rotationGroup, remote )) visibility

                Hidden ->
                    text ""
            ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.rotationGroupId

        GotRotationGroup response ->
            API.handleRemoteError response { model | rotationGroup = response } Cmd.none

        GotRotations response ->
            API.handleRemoteError response { model | rotations = response } Cmd.none

        GotUsers response ->
            API.handleRemoteError response { model | users = response } Cmd.none

        GotTimezone tz ->
            ( { model | timezone = tz }, Cmd.none )

        GotTime time ->
            ( { model | time = Just time }, Cmd.none )

        ModalClose ->
            case model.modalState of
                RotationGroupFormVisible id form rotationGroup _ ->
                    ( { model | modalState = RotationGroupFormVisible id form rotationGroup Modal.hidden }, Cmd.none )

                RotationGroupDeleteVisible id result _ ->
                    ( { model | modalState = RotationGroupDeleteVisible id result Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                RotationGroupFormVisible id form rotationGroup _ ->
                    ( { model | modalState = RotationGroupFormVisible id form rotationGroup visibility }, Cmd.none )

                RotationGroupDeleteVisible id result _ ->
                    ( { model | modalState = RotationGroupDeleteVisible id result visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        RotationGroupFormUpdate field ->
            case model.modalState of
                RotationGroupFormVisible id form rotationGroup visibility ->
                    let
                        updatedForm =
                            case field of
                                RotationGroupNumber data ->
                                    case String.toInt data of
                                        Just number ->
                                            { form | number = number }

                                        Nothing ->
                                            form

                                RotationGroupDescription description ->
                                    { form | description = description }

                                RotationGroupRotationId maybeId ->
                                    case maybeId of
                                        Just data ->
                                            { form | rotationId = data }

                                        Nothing ->
                                            form

                                RotationGroupUsers data ->
                                    { form | users = data }
                    in
                    ( { model | modalState = RotationGroupFormVisible id updatedForm rotationGroup visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        RotationGroupEditClicked rotationGroup ->
            ( { model | modalState = RotationGroupFormVisible (Just rotationGroup.id) (initRotationGroupForm <| Left rotationGroup) NotAsked Modal.shown }, Cmd.none )

        RotationGroupDeleteClicked rotationGroup ->
            ( { model | modalState = RotationGroupDeleteVisible rotationGroup NotAsked Modal.shown }, Cmd.none )

        FormSubmitClicked ->
            case model.modalState of
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

        GotRotationGroupFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        RotationGroupFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = RotationGroupFormVisible maybeId form result Modal.hidden }, getRotationGroup model.session (model.rotationGroupId) GotRotationGroup )

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
                                    ( { model | modalState = RotationGroupDeleteVisible rotationGroup result Modal.hidden }, getRotationGroup model.session (rotationGroup.id) GotRotationGroup )

                                _ ->
                                    ( { model | modalState = RotationGroupDeleteVisible rotationGroup result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        DeleteSubmitClicked ->
            case model.modalState of
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
            RotationGroupFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            RotationGroupDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]
