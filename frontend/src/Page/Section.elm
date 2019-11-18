module Page.Section exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (..)
import API.Classrooms exposing (..)
import API.Feedback exposing (..)
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
import Iso8601
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
    | SectionFormVisible (Maybe SectionId) SectionForm (APIData Section) Modal.Visibility
    | RotationFormVisible (Maybe RotationId) RotationForm (APIData Rotation) Modal.Visibility
    | SectionDeleteVisible Section (APIData ()) Modal.Visibility
    | RotationDeleteVisible Rotation (APIData ()) Modal.Visibility
    | SectionImportVisible SectionId (APIData (List User)) Modal.Visibility


type alias Model =
    { session : Session
    , sectionId : SectionId
    , timezone : Time.Zone
    , time : Maybe Time.Posix

    -- Remote data
    , section : APIData Section
    , rotations : APIData (List Rotation)
    , semesters : APIData (List Semester)
    , sections : APIData (List Section)

    -- Modals
    , modalState : ModalState
    , sectionFormErrors : List ( SectionFormField, String )
    , rotationFormErrors : List ( RotationFormField, String )
    }


type SectionFormField
    = SectionNumber String
    | SectionDescription String
    | SectionSemesterId (Maybe SemesterId)


type RotationFormField
    = RotationNumber Int
    | RotationDescription String
    | StartDate Time.Posix
    | EndDate Time.Posix
    | RotationSectionId (Maybe SectionId)


type Msg
    = GotSession Session
      -- Remote data
    | GotSection (APIData Section)
    | GotRotations (APIData (List Rotation))
    | GotSemesters (APIData (List Semester))
    | GotSections (APIData (List Section))
      -- Section buttons
    | SectionEditClicked Section
    | SectionDeleteClicked Section
      -- Rotation table
    | RotationClicked Rotation
    | RotationNewClicked
    | RotationEditClicked Rotation
    | RotationDeleteClicked Rotation
      -- Modal and form
    | ModalAnimate Modal.Visibility
    | ModalClose
    | SectionFormUpdate SectionFormField
    | RotationFormUpdate RotationFormField
    | FormSubmitClicked
    | DeleteSubmitClicked
      -- Form results
    | GotSectionFormResult (APIData Section)
    | GotSectionDeleteResult (APIData ())
    | GotRotationFormResult (APIData Rotation)
    | GotRotationDeleteResult (APIData ())
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> SectionId -> ( Model, Cmd Msg )
init session sectionId =
    let
        model =
            { session = session
            , section = Loading
            , sectionId = sectionId
            , rotations = Loading
            , semesters = Loading
            , sections = Loading
            , timezone = Time.utc
            , time = Nothing
            , modalState = Hidden
            , sectionFormErrors = []
            , rotationFormErrors = []
            }
    in
    case Session.credential session of
        Nothing ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Login )

        Just _ ->
            ( model
            , Cmd.batch
                [ getSection session sectionId GotSection
                , sections session Nothing Nothing GotSections
                , semesters session GotSemesters
                , rotations session (Just sectionId) GotRotations
                , Task.perform GotTimezone Time.here
                , Task.perform GotTime Time.now
                ]
            )


toSession : Model -> Session
toSession model =
    model.session


viewRotations : Model -> Html Msg
viewRotations model =
    let
        tableConfig =
            { render = \item -> [ String.fromInt item.number, Maybe.withDefault "" item.description ]
            , headers = [ "Name", "Description" ]
            , onClick = RotationClicked
            , onEdit = RotationEditClicked
            , onDelete = RotationDeleteClicked
            }
    in
    div [ class "p-2" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-11" ]
                [ h4 [ class "" ] [ text "Rotations" ]
                ]
            , div [ class "col-lg-1" ] [ Button.button [ Button.success, Button.onClick RotationNewClicked ] [ text "New" ] ]
            ]
        , hr [] []
        , case model.rotations of
            Success rotations ->
                Table.view tableConfig rotations

            Failure e ->
                text <| (API.getErrorBody >> API.errorBodyToString) e

            _ ->
                Common.loading
        ]


viewSectionModal : Model -> Either ( Maybe SectionId, SectionForm, APIData Section ) ( Section, APIData () ) -> Modal.Visibility -> Html Msg
viewSectionModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                selectConfig : Select.Model Semester SemesterId Msg
                selectConfig =
                    { id = "semesterId"
                    , itemId = .id
                    , unwrapId = unwrapSemesterId
                    , toItemId = SemesterId
                    , selection =
                        case form.semesterId of
                            Just id ->
                                RemoteData.unwrap Nothing (ListExtra.find (.id >> (==) id)) model.semesters

                            _ ->
                                Nothing
                    , options = RemoteData.withDefault [] model.semesters
                    , onSelectionChanged = SectionSemesterId >> SectionFormUpdate
                    , render = .name
                    }

                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.sectionFormErrors of
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
                            text "New Section"

                        Just _ ->
                            text "Edit Section"
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
                                        , Input.value form.number
                                        , Input.onInput (SectionNumber >> SectionFormUpdate)
                                        ]
                                    , feedback (SectionNumber form.number)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "description" ] [ text "Description" ]
                                    , Textarea.textarea
                                        [ Textarea.rows 3
                                        , Textarea.id "description"
                                        , Textarea.value form.description
                                        , Textarea.onInput (SectionDescription >> SectionFormUpdate)
                                        ]
                                    , Form.help [] [ text "Optional description for the section" ]
                                    ]
                                , Form.group []
                                    [ Form.label [ for "semester" ] [ text "Semester" ]
                                    , Select.view selectConfig
                                    , Form.help [] [ text "What semester this section belongs to" ]
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

        Right ( section, remote ) ->
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.small
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 [] [ text "Delete Section" ]
                |> Modal.body []
                    [ p [] [ text <| "Are you sure you want to delete section '" ++ section.number ++ "' ?" ]
                    , p [] [ text "Deleting this section will also delete its rotations, their rotations, and their rotation groups." ]
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
                                    , Input.number
                                        [ Input.id "number"
                                        , Input.value <| String.fromInt form.number
                                        , Input.onInput (String.toInt >> Maybe.withDefault 0 >> RotationNumber >> RotationFormUpdate)
                                        ]
                                    , feedback (RotationNumber form.number)
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
                                    , feedback (RotationDescription form.description)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "startDate" ] [ text "Start Date" ]
                                    , Input.date
                                        [ Input.id "startDate"
                                        , Input.onInput (Iso8601.toTime >> Result.toMaybe >> Maybe.withDefault (Time.millisToPosix 0) >> StartDate >> RotationFormUpdate)
                                        , Input.value <| String.slice 0 10 <| Iso8601.fromTime form.startDate
                                        ]
                                    , Form.help [] [ text "When the rotation is set to start" ]
                                    ]
                                , Form.group []
                                    [ Form.label [ for "endDate" ] [ text "End Date" ]
                                    , Input.date
                                        [ Input.id "endDate"
                                        , Input.onInput (Iso8601.toTime >> Result.toMaybe >> Maybe.withDefault (Time.millisToPosix 0) >> EndDate >> RotationFormUpdate)
                                        , Input.value <| String.slice 0 10 <| Iso8601.fromTime form.endDate
                                        ]
                                    , Form.help [] [ text "When the rotation is set to end" ]
                                    ]
                                , Form.group []
                                    [ Form.label [ for "sectionId" ] [ text "Section" ]
                                    , Select.view selectConfig
                                    , Form.help [] [ text "What section does this rotation belong to?" ]
                                    , feedback (RotationSectionId <| Just form.sectionId)
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
                    [ p [] [ text <| "Are you sure you want to delete rotation '" ++ String.fromInt rotation.number ++ "' ?" ]
                    , p [] [ text "Deleting this rotation will also delete its rotations, their rotations, and their rotation groups." ]
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


viewSection : Model -> Html Msg
viewSection model =
    let
        number =
            RemoteData.unwrap "" .number model.section

        description =
            RemoteData.unwrap "" (.description >> Maybe.withDefault "") model.section
    in
    Card.config []
        |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
            [ h3 [] [ text <| "Section: " ++ number ]
            , div []
                [ Button.button [ Button.info, {- Button.onClick (SectionImportClicked model.sectionId), -} Button.disabled True ] [ text "Import Students" ]
                , span [] [text "  "]
                , RemoteData.unwrap (text "") (\section -> Button.button [ Button.success, Button.onClick (SectionEditClicked section) ] [ text "Edit" ]) model.section
                ]
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
            [ card <| viewSection model
            , card <| viewRotations model
            , case model.modalState of
                SectionFormVisible maybeId form remote visibility ->
                    viewSectionModal model (Left ( maybeId, form, remote )) visibility

                SectionDeleteVisible section remote visibility ->
                    viewSectionModal model (Right ( section, remote )) visibility

                RotationFormVisible maybeId form remote visibility ->
                    viewRotationModal model (Left ( maybeId, form, remote )) visibility

                RotationDeleteVisible rotation remote visibility ->
                    viewRotationModal model (Right ( rotation, remote )) visibility

                _ ->
                    text ""
            ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.sectionId

        GotSection response ->
            API.handleRemoteError response { model | section = response } Cmd.none

        GotSemesters response ->
            API.handleRemoteError response { model | semesters = response } Cmd.none

        GotRotations response ->
            API.handleRemoteError response { model | rotations = RemoteData.map (List.sortBy .number) response } Cmd.none

        GotSections response ->
            API.handleRemoteError response { model | sections = response } Cmd.none

        GotTimezone tz ->
            ( { model | timezone = tz }, Cmd.none )

        GotTime time ->
            ( { model | time = Just time }, Cmd.none )

        SectionEditClicked section ->
            ( { model | modalState = SectionFormVisible (Just section.id) (initSectionForm <| Left section) NotAsked Modal.shown }, Cmd.none )

        SectionDeleteClicked section ->
            ( { model | modalState = SectionDeleteVisible section NotAsked Modal.shown }, Cmd.none )

        ModalClose ->
            case model.modalState of
                SectionFormVisible id form section _ ->
                    ( { model | modalState = SectionFormVisible id form section Modal.hidden }, Cmd.none )

                SectionDeleteVisible id result _ ->
                    ( { model | modalState = SectionDeleteVisible id result Modal.hidden }, Cmd.none )

                RotationFormVisible id form rotation _ ->
                    ( { model | modalState = RotationFormVisible id form rotation Modal.hidden }, Cmd.none )

                RotationDeleteVisible id result _ ->
                    ( { model | modalState = RotationDeleteVisible id result Modal.hidden }, Cmd.none )

                SectionImportVisible id result _ ->
                    ( { model | modalState = SectionImportVisible id result Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                SectionFormVisible id form section _ ->
                    ( { model | modalState = SectionFormVisible id form section visibility }, Cmd.none )

                SectionDeleteVisible id result _ ->
                    ( { model | modalState = SectionDeleteVisible id result visibility }, Cmd.none )

                RotationFormVisible id form rotation _ ->
                    ( { model | modalState = RotationFormVisible id form rotation visibility }, Cmd.none )

                RotationDeleteVisible id result _ ->
                    ( { model | modalState = RotationDeleteVisible id result visibility }, Cmd.none )

                SectionImportVisible id result _ ->
                    ( { model | modalState = SectionImportVisible id result visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        SectionFormUpdate field ->
            case model.modalState of
                SectionFormVisible id form section visibility ->
                    let
                        updatedForm =
                            case field of
                                SectionNumber value ->
                                    { form | number = value }

                                SectionDescription value ->
                                    { form | description = value }

                                SectionSemesterId value ->
                                    { form | semesterId = value }
                    in
                    ( { model | modalState = SectionFormVisible id updatedForm section visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        RotationFormUpdate field ->
            case model.modalState of
                RotationFormVisible id form rotation visibility ->
                    let
                        updatedForm =
                            case field of
                                RotationNumber value ->
                                    { form | number = value }

                                RotationDescription value ->
                                    { form | description = value }

                                StartDate value ->
                                    { form | startDate = value }

                                EndDate value ->
                                    { form | endDate = value }

                                RotationSectionId maybeId ->
                                    case maybeId of
                                        Just value ->
                                            { form | sectionId = value }

                                        Nothing ->
                                            form
                    in
                    ( { model | modalState = RotationFormVisible id updatedForm rotation visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        RotationClicked rotation ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Rotation rotation.id) )

        RotationNewClicked ->
            ( { model | modalState = RotationFormVisible Nothing (initRotationForm (Right model.sectionId) model.time) NotAsked Modal.shown }, Cmd.none )

        RotationEditClicked rotation ->
            ( { model | modalState = RotationFormVisible (Just rotation.id) (initRotationForm (Left rotation) model.time) NotAsked Modal.shown }, Cmd.none )

        RotationDeleteClicked rotation ->
            ( { model | modalState = RotationDeleteVisible rotation NotAsked Modal.shown }, Cmd.none )

        FormSubmitClicked ->
            case model.modalState of
                SectionFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all [ ifBlank .number ( SectionNumber form.number, "Number cannot be blank" ) ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | sectionFormErrors = [], modalState = SectionFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateSection model.session id form GotSectionFormResult )

                                Nothing ->
                                    ( updatedModel, createSection model.session form GotSectionFormResult )

                        Err errors ->
                            ( { model | sectionFormErrors = errors }, Cmd.none )

                RotationFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all
                                []
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

                _ ->
                    ( model, Cmd.none )

        GotSectionFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        SectionFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = SectionFormVisible maybeId form result Modal.hidden }, getSection model.session model.sectionId GotSection )

                                _ ->
                                    ( { model | modalState = SectionFormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotSectionDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        SectionDeleteVisible section _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = SectionDeleteVisible section result Modal.hidden }, getSection model.session model.sectionId GotSection )

                                _ ->
                                    ( { model | modalState = SectionDeleteVisible section result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotRotationFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        RotationFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = RotationFormVisible maybeId form result Modal.hidden }, rotations model.session (Just model.sectionId) GotRotations )

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
                                    ( { model | modalState = RotationDeleteVisible rotation result Modal.hidden }, rotations model.session (Just model.sectionId) GotRotations )

                                _ ->
                                    ( { model | modalState = RotationDeleteVisible rotation result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        DeleteSubmitClicked ->
            case model.modalState of
                SectionDeleteVisible data _ visibility ->
                    ( { model | modalState = SectionDeleteVisible data Loading visibility }, deleteSection model.session data.id GotSectionDeleteResult )

                RotationDeleteVisible data _ visibility ->
                    ( { model | modalState = RotationDeleteVisible data Loading visibility }, deleteRotation model.session data.id GotRotationDeleteResult )

                _ ->
                    ( model, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (Session.navKey model.session)
        , case model.modalState of
            SectionFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            SectionDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            RotationFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            RotationDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            SectionImportVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]
