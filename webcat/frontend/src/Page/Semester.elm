module Page.Semester exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

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
import Iso8601

type ModalState
    = Hidden
    | FormVisible (Maybe SemesterId) SemesterForm (APIData Semester) Modal.Visibility
    | DeleteVisible Semester (APIData ()) Modal.Visibility


type alias Model =
    { session : Session
    , semesterId : SemesterId
    , timezone : Time.Zone
    , time : Maybe Time.Posix

    -- Remote data
    , rotations : APIData (List Rotation)
    , semester : APIData Semester
    , users : APIData (List User)

    -- Modals
    , modalState : ModalState
    , formErrors : List ( FormField, String )
    }


type FormField
    = Name String
    | Description String
    | StartDate String
    | EndDate String


type Msg
    = GotSession Session
      -- Remote data
    | GotRotations (APIData (List Rotation))
    | GotSemester (APIData Semester)
    | GotUsers (APIData (List User))
      -- Semester table
    | SemesterEditClicked Semester
    | SemesterDeleteClicked Semester
      -- Modal and form
    | ModalAnimate Modal.Visibility
    | ModalClose
    | FormUpdate FormField
    | FormSubmitClicked
    | DeleteSubmitClicked
      -- Form results
    | GotFormResult (APIData Semester)
    | GotDeleteResult (APIData ())
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> SemesterId -> ( Model, Cmd Msg )
init session semesterId =
    let
        model =
            { session = session
            , semesterId = semesterId
            , semester = Loading
            , rotations = Loading
            , users = Loading
            , timezone = Time.utc
            , time = Nothing
            , modalState = Hidden
            , formErrors = []
            }
    in
    case Session.credential session of
        Nothing ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Login )

        Just _ ->
            ( model
            , Cmd.batch
                [ getSemester session semesterId GotSemester
                , rotations session Nothing GotRotations
                , users session GotUsers
                , Task.perform GotTimezone Time.here
                , Task.perform GotTime Time.now
                ]
            )


toSession : Model -> Session
toSession model =
    model.session


viewSemesterModal : Model -> Either ( Maybe SemesterId, SemesterForm, APIData Semester ) ( Semester, APIData () ) -> Modal.Visibility -> Html Msg
viewSemesterModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.formErrors of
                        Just ( _, message ) ->
                            Form.invalidFeedback [] [ text message ]

                        Nothing ->
                            text ""

                inputCondition field =
                    case ListExtra.find (\( f, m ) -> f == field) model.formErrors of
                        Just _ ->
                            [ Input.danger ]

                        Nothing ->
                            []
            in
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.large
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 []
                    [ case maybeId of
                        Nothing ->
                            text "New Semester"

                        Just _ ->
                            text "Edit Semester"
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
                                        , Input.onInput (Name >> FormUpdate)
                                        ]
                                    , feedback (Name form.name)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "description" ] [ text "Description" ]
                                    , Textarea.textarea
                                        [ Textarea.rows 3
                                        , Textarea.id "description"
                                        , Textarea.value form.description
                                        , Textarea.onInput (Description >> FormUpdate)
                                        ]
                                    , Form.help [] [ text "Optional description for the semester" ]
                                    ]
                                , Form.group []
                                    [ Form.label [ for "startDate" ] [ text "Start Date" ]
                                    , Input.date <|
                                        [ Input.id "startDate"
                                        , Input.onInput (StartDate >> FormUpdate)
                                        , Input.value <| String.slice 0 10 <| Iso8601.fromTime form.startDate
                                        ]
                                            ++ inputCondition (StartDate <| Iso8601.fromTime form.startDate)
                                    , Form.help [] [ text "When the semester is set to start" ]
                                    , feedback (StartDate <| Iso8601.fromTime form.startDate)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "endDate" ] [ text "End Date" ]
                                    , Input.date <|
                                        [ Input.id "endDate"
                                        , Input.onInput (EndDate >> FormUpdate)
                                        , Input.value <| String.slice 0 10 <| Iso8601.fromTime form.endDate
                                        ]
                                            ++ inputCondition (EndDate <| Iso8601.fromTime form.endDate)
                                    , feedback (EndDate <| Iso8601.fromTime form.endDate)
                                    , Form.help [] [ text "When the semester is set to end" ]
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

        Right ( semester, remote ) ->
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.small
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 [] [ text "Delete Semester" ]
                |> Modal.body []
                    [ p [] [ text <| "Are you sure you want to delete semester '" ++ semester.name ++ "' ?" ]
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


viewSemester : Model -> Html Msg
viewSemester model =
    let
        name =
            RemoteData.unwrap "" .name model.semester

        description =
            RemoteData.unwrap "" (.description >> Maybe.withDefault "") model.semester

        startDate = RemoteData.unwrap "" (.startDate >> Date.posixToDate (model.timezone)) model.semester
        endDate = RemoteData.unwrap "" (.endDate >> Date.posixToDate ( model.timezone)) model.semester
    in
    Card.config []
        |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
            [ h3 [] [ text <| "Semester: " ++ name ]
            , RemoteData.unwrap (text "") (\semester -> Button.button [ Button.success, Button.onClick (SemesterEditClicked semester) ] [ text "Edit" ]) model.semester
            ]
        |> Card.listGroup
            [ ListGroup.li [] [ text <| "Name: " ++ name ]
            , ListGroup.li [] [ text <| "Description: " ++ description ]
            , ListGroup.li [] [ text <| "Start Date: " ++ startDate ]
            , ListGroup.li [] [ text <| "End Date: " ++ endDate ]
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
            [ card <| viewSemester model
            , case model.modalState of
                FormVisible maybeId form remote visibility ->
                    viewSemesterModal model (Left ( maybeId, form, remote )) visibility

                DeleteVisible semester remote visibility ->
                    viewSemesterModal model (Right ( semester, remote )) visibility

                Hidden ->
                    text ""
            ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.semesterId

        GotSemester response ->
            API.handleRemoteError response { model | semester = response } Cmd.none

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
                FormVisible id form semester _ ->
                    ( { model | modalState = FormVisible id form semester Modal.hidden }, Cmd.none )

                DeleteVisible id result _ ->
                    ( { model | modalState = DeleteVisible id result Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                FormVisible id form semester _ ->
                    ( { model | modalState = FormVisible id form semester visibility }, Cmd.none )

                DeleteVisible id result _ ->
                    ( { model | modalState = DeleteVisible id result visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        FormUpdate field ->
            case model.modalState of
                FormVisible id form semester visibility ->
                    let
                        updatedForm =
                            case field of
                                Name data -> {form | name = data}

                                Description description ->
                                    { form | description = description }


                                StartDate value ->
                                    case (Iso8601.toTime >> Result.toMaybe) value of
                                        Just date ->
                                            { form | startDate = date }

                                        Nothing ->
                                            form

                                EndDate value ->
                                    case (Iso8601.toTime >> Result.toMaybe) value of
                                        Just date ->
                                            { form | startDate = date }

                                        Nothing ->
                                            form

                    in
                    ( { model | modalState = FormVisible id updatedForm semester visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SemesterEditClicked semester ->
            ( { model | modalState = FormVisible (Just semester.id) (initSemesterForm (Just semester) model.time) NotAsked Modal.shown }, Cmd.none )

        SemesterDeleteClicked semester ->
            ( { model | modalState = DeleteVisible semester NotAsked Modal.shown }, Cmd.none )

        FormSubmitClicked ->
            case model.modalState of
                FormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all
                                []
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | formErrors = [], modalState = FormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateSemester model.session id form GotFormResult )

                                Nothing ->
                                    ( updatedModel, createSemester model.session form GotFormResult )

                        Err errors ->
                            ( { model | formErrors = errors }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        FormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = FormVisible maybeId form result Modal.hidden }, getSemester model.session (model.semesterId) GotSemester )

                                _ ->
                                    ( { model | modalState = FormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        DeleteVisible semester _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = DeleteVisible semester result Modal.hidden }, getSemester model.session (semester.id) GotSemester )

                                _ ->
                                    ( { model | modalState = DeleteVisible semester result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        DeleteSubmitClicked ->
            case model.modalState of
                DeleteVisible data _ visibility ->
                    ( { model | modalState = DeleteVisible data Loading visibility }, deleteSemester model.session data.id GotDeleteResult )

                _ ->
                    ( model, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (Session.navKey model.session)
        , case model.modalState of
            FormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            DeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]
