module Page.Classroom exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

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
    | ClassroomFormVisible (Maybe ClassroomId) ClassroomForm (APIData Classroom) Modal.Visibility
    | SectionFormVisible (Maybe SectionId) SectionForm (APIData Section) Modal.Visibility
    | ClassroomDeleteVisible Classroom (APIData ()) Modal.Visibility
    | SectionDeleteVisible Section (APIData ()) Modal.Visibility


type alias Model =
    { session : Session
    , classroomId : ClassroomId
    , timezone : Time.Zone
    , time : Maybe Time.Posix

    -- Remote data
    , classroom : APIData Classroom
    , sections : APIData (List Section)
    , semesters : APIData (List Semester)
    , categories : APIData (List Category)

    -- Modals
    , modalState : ModalState
    , classroomFormErrors : List ( ClassroomFormField, String )
    , sectionFormErrors : List ( SectionFormField, String )
    }


type ClassroomFormField
    = CourseCode String
    | Name String
    | ClassroomDescription String
    | Categories (List CategoryId)


type SectionFormField
    = Number String
    | SectionDescription String
    | SectionSemesterId (Maybe SemesterId)


type Msg
    = GotSession Session
      -- Remote data
    | GotClassroom (APIData Classroom)
    | GotSemesters (APIData (List Semester))
    | GotSections (APIData (List Section))
    | GotCategories (APIData (List Category))
      -- Classroom buttons
    | ClassroomEditClicked Classroom
    | ClassroomDeleteClicked Classroom
      -- Section table
    | SectionClicked Section
    | SectionNewClicked
    | SectionEditClicked Section
    | SectionDeleteClicked Section
      -- Modal and form
    | ModalAnimate Modal.Visibility
    | ModalClose
    | ClassroomFormUpdate ClassroomFormField
    | SectionFormUpdate SectionFormField
    | FormSubmitClicked
    | DeleteSubmitClicked
      -- Form results
    | GotClassroomFormResult (APIData Classroom)
    | GotClassroomDeleteResult (APIData ())
    | GotSectionFormResult (APIData Section)
    | GotSectionDeleteResult (APIData ())
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> ClassroomId -> ( Model, Cmd Msg )
init session classroomId =
    let
        model =
            { session = session
            , classroom = Loading
            , classroomId = classroomId
            , sections = Loading
            , semesters = Loading
            , categories = Loading
            , timezone = Time.utc
            , time = Nothing
            , modalState = Hidden
            , classroomFormErrors = []
            , sectionFormErrors = []
            }
    in
    case Session.credential session of
        Nothing ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Login )

        Just _ ->
            ( model
            , Cmd.batch
                [ getClassroom session classroomId GotClassroom
                , semesters session GotSemesters
                , sections session (Just classroomId) Nothing GotSections
                , categories session Nothing GotCategories
                , Task.perform GotTimezone Time.here
                , Task.perform GotTime Time.now
                ]
            )


toSession : Model -> Session
toSession model =
    model.session


viewSections : Model -> Html Msg
viewSections model =
    let
        tableConfig =
            { render = \item -> [ item.number, Maybe.withDefault "" item.description ]
            , headers = [ "Name", "Description" ]
            , onClick = SectionClicked
            , onEdit = SectionEditClicked
            , onDelete = SectionDeleteClicked
            }
    in
    div [ class "p-2" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-11" ]
                [ h4 [ class "" ] [ text "Sections" ]
                ]
            , div [ class "col-lg-1" ] [ Button.button [ Button.success, Button.onClick SectionNewClicked ] [ text "New" ] ]
            ]
        , hr [] []
        , case model.sections of
            Success sections ->
                Table.view tableConfig sections

            Failure e ->
                text <| (API.getErrorBody >> API.errorBodyToString) e

            _ ->
                Common.loading
        ]


viewClassroomModal : Model -> Either ( Maybe ClassroomId, ClassroomForm, APIData Classroom ) ( Classroom, APIData () ) -> Modal.Visibility -> Html Msg
viewClassroomModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                selectConfig =
                    { id = "categories"
                    , itemId = .id
                    , unwrapId = unwrapCategoryId
                    , toItemId = CategoryId
                    , selection =
                        case model.categories of
                            Success categories ->
                                List.filter (\c -> List.member c.id form.categories) categories

                            _ ->
                                []
                    , options =
                        case model.categories of
                            Success categories ->
                                List.filter (\c -> c.parentCategoryId == Nothing) categories

                            _ ->
                                []
                    , onSelectionChanged = Categories >> ClassroomFormUpdate
                    , render = .name
                    }

                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.classroomFormErrors of
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
                            text "New Classroom"

                        Just _ ->
                            text "Edit Classroom"
                    ]
                |> Modal.body []
                    [ case remote of
                        Loading ->
                            Common.loading

                        _ ->
                            Form.form []
                                [ Form.group []
                                    [ Form.label [ for "courseCode" ] [ text "Course Code" ]
                                    , Input.text
                                        [ Input.id "courseCode"
                                        , Input.value form.courseCode
                                        , Input.onInput (CourseCode >> ClassroomFormUpdate)
                                        ]
                                    , feedback (CourseCode form.courseCode)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "description" ] [ text "Description" ]
                                    , Textarea.textarea
                                        [ Textarea.rows 3
                                        , Textarea.id "description"
                                        , Textarea.value form.description
                                        , Textarea.onInput (ClassroomDescription >> ClassroomFormUpdate)
                                        ]
                                    , Form.help [] [ text "Optional description for the classroom" ]
                                    ]
                                , Form.group []
                                    [ Form.label [ for "categories" ] [ text "Categories" ]
                                    , Multiselect.view selectConfig
                                    , Form.help [] [ text "What top-level categories will be available for grading, giving feedback, etc." ]
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

        Right ( classroom, remote ) ->
            Modal.config ModalClose
                |> Modal.withAnimation ModalAnimate
                |> Modal.small
                |> Modal.hideOnBackdropClick True
                |> Modal.h3 [] [ text "Delete Classroom" ]
                |> Modal.body []
                    [ p [] [ text <| "Are you sure you want to delete classroom '" ++ classroom.name ++ "' ?" ]
                    , p [] [ text "Deleting this classroom will also delete its sections, their rotations, and their rotation groups." ]
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
                                        , Input.onInput (Number >> SectionFormUpdate)
                                        ]
                                    , feedback (Number form.number)
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
                                    , feedback (SectionDescription form.description)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "semesterId" ] [ text "Semester" ]
                                    , Select.view selectConfig
                                    , Form.help [] [ text "What semester does this section belong to?" ]
                                    , feedback (SectionSemesterId form.semesterId)
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
                    , p [] [ text "Deleting this section will also delete its sections, their rotations, and their rotation groups." ]
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


viewClassroom : Model -> Html Msg
viewClassroom model =
    let
        name =
            RemoteData.unwrap "" .name model.classroom

        courseCode =
            RemoteData.unwrap "" .courseCode model.classroom

        description =
            RemoteData.unwrap "" (.description >> Maybe.withDefault "") model.classroom
    in
    Card.config []
        |> Card.header [ Flex.block, Flex.justifyBetween, Flex.alignItemsCenter ]
            [ h3 [] [ text <| "Classroom: " ++ name ]
            , RemoteData.unwrap (text "") (\classroom -> Button.button [ Button.success, Button.onClick (ClassroomEditClicked classroom) ] [ text "Edit" ]) model.classroom
            ]
        |> Card.listGroup
            [ ListGroup.li [] [ text <| "Name: " ++ name ]
            , ListGroup.li [] [ text <| "Course Code: " ++ courseCode ]
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
            [ card <| viewClassroom model
            , card <| viewSections model
            , case model.modalState of
                ClassroomFormVisible maybeId form remote visibility ->
                    viewClassroomModal model (Left ( maybeId, form, remote )) visibility

                ClassroomDeleteVisible classroom remote visibility ->
                    viewClassroomModal model (Right ( classroom, remote )) visibility

                SectionFormVisible maybeId form remote visibility ->
                    viewSectionModal model (Left ( maybeId, form, remote )) visibility

                SectionDeleteVisible section remote visibility ->
                    viewSectionModal model (Right ( section, remote )) visibility

                _ ->
                    text ""
            ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.classroomId

        GotClassroom response ->
            API.handleRemoteError response { model | classroom = response } Cmd.none

        GotSemesters response ->
            API.handleRemoteError response { model | semesters = response } Cmd.none

        GotSections response ->
            API.handleRemoteError response { model | sections = RemoteData.map (List.sortBy .number) response } Cmd.none

        GotCategories response ->
            API.handleRemoteError response { model | categories = response } Cmd.none

        GotTimezone tz ->
            ( { model | timezone = tz }, Cmd.none )

        GotTime time ->
            ( { model | time = Just time }, Cmd.none )

        ClassroomEditClicked classroom ->
            ( { model | modalState = ClassroomFormVisible (Just classroom.id) (initClassroomForm <| Just classroom) NotAsked Modal.shown }, Cmd.none )

        ClassroomDeleteClicked classroom ->
            ( { model | modalState = ClassroomDeleteVisible classroom NotAsked Modal.shown }, Cmd.none )

        ModalClose ->
            case model.modalState of
                ClassroomFormVisible id form classroom _ ->
                    ( { model | modalState = ClassroomFormVisible id form classroom Modal.hidden }, Cmd.none )

                ClassroomDeleteVisible id result _ ->
                    ( { model | modalState = ClassroomDeleteVisible id result Modal.hidden }, Cmd.none )

                SectionFormVisible id form section _ ->
                    ( { model | modalState = SectionFormVisible id form section Modal.hidden }, Cmd.none )

                SectionDeleteVisible id result _ ->
                    ( { model | modalState = SectionDeleteVisible id result Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                ClassroomFormVisible id form classroom _ ->
                    ( { model | modalState = ClassroomFormVisible id form classroom visibility }, Cmd.none )

                ClassroomDeleteVisible id result _ ->
                    ( { model | modalState = ClassroomDeleteVisible id result visibility }, Cmd.none )

                SectionFormVisible id form section _ ->
                    ( { model | modalState = SectionFormVisible id form section visibility }, Cmd.none )

                SectionDeleteVisible id result _ ->
                    ( { model | modalState = SectionDeleteVisible id result visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ClassroomFormUpdate field ->
            case model.modalState of
                ClassroomFormVisible id form classroom visibility ->
                    let
                        updatedForm =
                            case field of
                                CourseCode courseCode ->
                                    { form | courseCode = courseCode }

                                ClassroomDescription description ->
                                    { form | description = description }

                                Categories ids ->
                                    { form | categories = ids }

                                _ ->
                                    form
                    in
                    ( { model | modalState = ClassroomFormVisible id updatedForm classroom visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SectionFormUpdate field ->
            case model.modalState of
                SectionFormVisible id form section visibility ->
                    let
                        updatedForm =
                            case field of
                                Number number ->
                                    { form | number = number }

                                SectionDescription description ->
                                    { form | description = description }

                                SectionSemesterId semesterId ->
                                    { form | semesterId = semesterId }
                    in
                    ( { model | modalState = SectionFormVisible id updatedForm section visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SectionClicked section ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Section section.id) )

        SectionNewClicked ->
            ( { model | modalState = SectionFormVisible Nothing (initSectionForm <| Right model.classroomId) NotAsked Modal.shown }, Cmd.none )

        SectionEditClicked section ->
            ( { model | modalState = SectionFormVisible (Just section.id) (initSectionForm <| Left section) NotAsked Modal.shown }, Cmd.none )

        SectionDeleteClicked section ->
            ( { model | modalState = SectionDeleteVisible section NotAsked Modal.shown }, Cmd.none )

        FormSubmitClicked ->
            case model.modalState of
                ClassroomFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all [ ifBlank .name ( Name form.name, "Name cannot be blank" ) ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | classroomFormErrors = [], modalState = ClassroomFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateClassroom model.session id form GotClassroomFormResult )

                                Nothing ->
                                    ( updatedModel, createClassroom model.session form GotClassroomFormResult )

                        Err errors ->
                            ( { model | classroomFormErrors = errors }, Cmd.none )

                SectionFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all
                                [ ifBlank .number ( Number form.number, "number cannot be blank" )
                                , ifNothing .semesterId ( SectionSemesterId form.semesterId, "you must choose a semester" )
                                ]
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

                _ ->
                    ( model, Cmd.none )

        GotClassroomFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        ClassroomFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = ClassroomFormVisible maybeId form result Modal.hidden }, getClassroom model.session model.classroomId GotClassroom )

                                _ ->
                                    ( { model | modalState = ClassroomFormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotClassroomDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        ClassroomDeleteVisible classroom _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = ClassroomDeleteVisible classroom result Modal.hidden }, getClassroom model.session model.classroomId GotClassroom )

                                _ ->
                                    ( { model | modalState = ClassroomDeleteVisible classroom result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotSectionFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        SectionFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = SectionFormVisible maybeId form result Modal.hidden }, sections model.session (Just model.classroomId) Nothing GotSections )

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
                                    ( { model | modalState = SectionDeleteVisible section result Modal.hidden }, sections model.session (Just model.classroomId) Nothing GotSections )

                                _ ->
                                    ( { model | modalState = SectionDeleteVisible section result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        DeleteSubmitClicked ->
            case model.modalState of
                ClassroomDeleteVisible data _ visibility ->
                    ( { model | modalState = ClassroomDeleteVisible data Loading visibility }, deleteClassroom model.session data.id GotClassroomDeleteResult )

                SectionDeleteVisible data _ visibility ->
                    ( { model | modalState = SectionDeleteVisible data Loading visibility }, deleteSection model.session data.id GotSectionDeleteResult )

                _ ->
                    ( model, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (Session.navKey model.session)
        , case model.modalState of
            ClassroomFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            ClassroomDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            SectionFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            SectionDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]
