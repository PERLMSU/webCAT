module Page.Dashboard exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (..)
import API.Classrooms exposing (..)
import API.Feedback exposing (..)
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Modal as Modal
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
import Route
import Session exposing (Session)
import Task
import Time
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)
import Iso8601

type ModalState
    = Hidden
    | ClassroomFormVisible (Maybe ClassroomId) ClassroomForm (APIData Classroom) Modal.Visibility
    | SemesterFormVisible (Maybe SemesterId) SemesterForm (APIData Semester) Modal.Visibility
    | CategoryFormVisible (Maybe CategoryId) CategoryForm (APIData Category) Modal.Visibility
    | ClassroomDeleteVisible Classroom (APIData ()) Modal.Visibility
    | SemesterDeleteVisible Semester (APIData ()) Modal.Visibility
    | CategoryDeleteVisible Category (APIData ()) Modal.Visibility


type alias Model =
    { session : Session
    , timezone : Maybe Time.Zone
    , time : Maybe Time.Posix

    -- Remote data
    , classrooms : APIData (List Classroom)
    , semesters : APIData (List Semester)
    , categories : APIData (List Category)

    -- Modals
    , modalState : ModalState
    , formErrors : List ( FormField, String )
    }


type FormField
    = CourseCode String
    | Name String
    | Description String
    | StartDate String
    | EndDate String
    | ParentCategoryId (Maybe CategoryId)
    | CategoryIds (List CategoryId)


type Msg
    = GotSession Session
    | GotClassrooms (APIData (List Classroom))
    | GotClassroomFormResult (APIData Classroom)
    | GotClassroomDeleteResult (APIData ())
    | GotSemesters (APIData (List Semester))
    | GotSemesterFormResult (APIData Semester)
    | GotSemesterDeleteResult (APIData ())
    | GotCategories (APIData (List Category))
    | GotCategoryFormResult (APIData Category)
    | GotCategoryDeleteResult (APIData ())
      -- Classroom table
    | ClassroomClicked Classroom
    | ClassroomNewClicked
    | ClassroomEditClicked Classroom
    | ClassroomDeleteClicked Classroom
      -- Semester table
    | SemesterClicked Semester
    | SemesterNewClicked
    | SemesterEditClicked Semester
    | SemesterDeleteClicked Semester
      -- Category
    | CategoryClicked Category
    | CategoryNewClicked
    | CategoryEditClicked Category
    | CategoryDeleteClicked Category
      -- Modal and form
    | ModalAnimate Modal.Visibility
    | ModalClose
    | FormUpdate FormField
    | FormSubmitClicked
    | DeleteSubmitClicked
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> ( Model, Cmd Msg )
init session =
    case Session.credential session of
        Nothing ->
            ( { session = session
              , classrooms = Loading
              , semesters = Loading
              , categories = Loading
              , timezone = Nothing
              , time = Nothing
              , modalState = Hidden
              , formErrors = []
              }
            , Route.replaceUrl (Session.navKey session) Route.Login
            )

        Just _ ->
            ( { session = session
              , classrooms = Loading
              , semesters = Loading
              , categories = Loading
              , timezone = Nothing
              , time = Nothing
              , modalState = Hidden
              , formErrors = []
              }
            , Cmd.batch
                [ classrooms session GotClassrooms
                , semesters session GotSemesters
                , categories session Nothing GotCategories
                , Task.perform GotTimezone Time.here
                , Task.perform GotTime Time.now
                ]
            )


toSession : Model -> Session
toSession model =
    model.session


viewClassrooms : Model -> Html Msg
viewClassrooms model =
    let
        tableConfig =
            { render = \item -> [ item.courseCode, item.name, Maybe.withDefault "" item.description ]
            , headers = [ "Course Code", "Name", "Description" ]
            , onClick = ClassroomClicked
            , onEdit = ClassroomEditClicked
            , onDelete = ClassroomDeleteClicked
            }
    in
    div [ class "p-2" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-11" ]
                [ h1 [ class "" ] [ text "Classrooms" ]
                ]
            , div [ class "col-lg-1" ] [ Button.button [ Button.success, Button.onClick ClassroomNewClicked ] [ text "New" ] ]
            ]
        , hr [] []
        , case model.classrooms of
            Success classrooms ->
                Table.view tableConfig classrooms

            Failure e ->
                text <| (API.getErrorBody >> API.errorBodyToString) e

            _ ->
                Common.loading
        ]


viewSemesters : Model -> Html Msg
viewSemesters model =
    let
        tableConfig =
            { render = \item -> [ item.name, Maybe.withDefault "" item.description, Date.posixToDate (Maybe.withDefault Time.utc model.timezone) item.startDate, Date.posixToDate (Maybe.withDefault Time.utc model.timezone) item.endDate ]
            , headers = [ "Name", "Description", "Start Date", "End Date" ]
            , onClick = SemesterClicked
            , onEdit = SemesterEditClicked
            , onDelete = SemesterDeleteClicked
            }
    in
    div [ class "p-2" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-11" ]
                [ h1 [ class "" ] [ text "Semesters" ]
                ]
            , div [ class "col-lg-1" ] [ Button.button [ Button.success, Button.onClick SemesterNewClicked ] [ text "New" ] ]
            ]
        , hr [] []
        , case model.semesters of
            Success semesters ->
                Table.view tableConfig semesters

            Failure e ->
                text <| (API.getErrorBody >> API.errorBodyToString) e

            _ ->
                Common.loading
        ]


viewCategories : Model -> Html Msg
viewCategories model =
    let
        tableConfig =
            { render = \item -> [ item.name, Maybe.withDefault "" item.description ]
            , headers = [ "Name", "Description" ]
            , onClick = CategoryClicked
            , onEdit = CategoryEditClicked
            , onDelete = CategoryDeleteClicked
            }
    in
    div [ class "p-2" ]
        [ div [ class "row" ]
            [ div [ class "col-lg-11" ]
                [ h1 [ class "" ] [ text "Categories" ]
                ]
            , div [ class "col-lg-1" ] [ Button.button [ Button.success, Button.onClick CategoryNewClicked ] [ text "New" ] ]
            ]
        , case model.categories of
            Success categories ->
                Table.view tableConfig categories

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
                    , onSelectionChanged = CategoryIds >> FormUpdate
                    , render = .name
                    }

                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.formErrors of
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
                                        , Input.onInput (CourseCode >> FormUpdate)
                                        ]
                                    , feedback (CourseCode form.courseCode)
                                    ]
                                , Form.group []
                                    [ Form.label [ for "description" ] [ text "Description" ]
                                    , Textarea.textarea
                                        [ Textarea.rows 3
                                        , Textarea.id "description"
                                        , Textarea.value form.description
                                        , Textarea.onInput (Description >> FormUpdate)
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


viewCategoryModal : Model -> Either ( Maybe CategoryId, CategoryForm, APIData Category ) ( Category, APIData () ) -> Modal.Visibility -> Html Msg
viewCategoryModal model either visibility =
    case either of
        Left ( maybeId, form, remote ) ->
            let
                selectConfig =
                    { id = "parentCategoryId"
                    , itemId = .id
                    , unwrapId = unwrapCategoryId
                    , toItemId = CategoryId
                    , selection =
                        case model.categories of
                            Success categories ->
                                case form.parentCategoryId of
                                    Just id ->
                                        ListExtra.find (\c -> c.id == id) categories

                                    Nothing ->
                                        Nothing

                            _ ->
                                Nothing
                    , options =
                        case model.categories of
                            Success categories ->
                                List.filter (\c -> c.parentCategoryId == Nothing) categories

                            _ ->
                                []
                    , onSelectionChanged = ParentCategoryId >> FormUpdate
                    , render = .name
                    }

                feedback field =
                    case ListExtra.find (\( f, m ) -> f == field) model.formErrors of
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
                                    , Form.help [] [ text "Optional description for the category" ]
                                    ]
                                , Form.group []
                                    [ Form.label [ for "parentCategoryId" ] [ text "Parent Category" ]
                                    , Select.view selectConfig
                                    , Form.help [] [ text "Which category is this category's logical parent" ]
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
                    , p [] [ text "Deleting this category will also delete its observations, feedback items, and explanations." ]
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


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Dashboard"
    , content =
        let
            card inner =
                div [ class "row" ] [ div [ class "col" ] [ inner ] ]
        in
        div [ class "container" ]
            [ card <| viewClassrooms model
            , card <| viewSemesters model
            , card <| viewCategories model
            , case model.modalState of
                ClassroomFormVisible maybeId form remote visibility ->
                    viewClassroomModal model (Left ( maybeId, form, remote )) visibility

                ClassroomDeleteVisible classroom remote visibility ->
                    viewClassroomModal model (Right ( classroom, remote )) visibility

                SemesterFormVisible maybeId form remote visibility ->
                    viewSemesterModal model (Left ( maybeId, form, remote )) visibility

                SemesterDeleteVisible semester remote visibility ->
                    viewSemesterModal model (Right ( semester, remote )) visibility

                CategoryFormVisible maybeId form remote visibility ->
                    viewCategoryModal model (Left ( maybeId, form, remote )) visibility

                CategoryDeleteVisible category remote visibility ->
                    viewCategoryModal model (Right ( category, remote )) visibility

                _ ->
                    text ""
            ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session

        GotClassrooms response ->
            handleRemoteError response { model | classrooms = response } Cmd.none

        GotSemesters response ->
            handleRemoteError response { model | semesters = response } Cmd.none

        GotCategories response ->
            handleRemoteError response { model | categories = response } Cmd.none

        GotTimezone tz ->
            ( { model | timezone = Just tz }, Cmd.none )

        GotTime time ->
            ( { model | time = Just time }, Cmd.none )

        ClassroomClicked classroom ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Classroom classroom.id) )

        ClassroomNewClicked ->
            ( { model | modalState = ClassroomFormVisible Nothing (initClassroomForm Nothing) NotAsked Modal.shown }, Cmd.none )

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

                SemesterFormVisible id form semester _ ->
                    ( { model | modalState = SemesterFormVisible id form semester Modal.hidden }, Cmd.none )

                SemesterDeleteVisible id result _ ->
                    ( { model | modalState = SemesterDeleteVisible id result Modal.hidden }, Cmd.none )

                CategoryFormVisible id form category _ ->
                    ( { model | modalState = CategoryFormVisible id form category Modal.hidden }, Cmd.none )

                CategoryDeleteVisible id result _ ->
                    ( { model | modalState = CategoryDeleteVisible id result Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                ClassroomFormVisible id form classroom _ ->
                    ( { model | modalState = ClassroomFormVisible id form classroom visibility }, Cmd.none )

                ClassroomDeleteVisible id result _ ->
                    ( { model | modalState = ClassroomDeleteVisible id result visibility }, Cmd.none )

                SemesterFormVisible id form semester _ ->
                    ( { model | modalState = SemesterFormVisible id form semester visibility }, Cmd.none )

                SemesterDeleteVisible id result _ ->
                    ( { model | modalState = SemesterDeleteVisible id result visibility }, Cmd.none )

                CategoryFormVisible id form category _ ->
                    ( { model | modalState = CategoryFormVisible id form category visibility }, Cmd.none )

                CategoryDeleteVisible id result _ ->
                    ( { model | modalState = CategoryDeleteVisible id result visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        FormUpdate field ->
            case model.modalState of
                ClassroomFormVisible id form classroom visibility ->
                    let
                        updatedForm =
                            case field of
                                CourseCode courseCode ->
                                    { form | courseCode = courseCode }

                                Description description ->
                                    { form | description = description }

                                CategoryIds ids ->
                                    { form | categories = ids }

                                _ ->
                                    form
                    in
                    ( { model | modalState = ClassroomFormVisible id updatedForm classroom visibility }, Cmd.none )

                SemesterFormVisible id form semester visibility ->
                    let
                        updatedForm =
                            case field of
                                Name name ->
                                    { form | name = name }

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
                                            { form | endDate = date }

                                        Nothing ->
                                            form

                                _ ->
                                    form
                    in
                    ( { model | modalState = SemesterFormVisible id updatedForm semester visibility }, Cmd.none )

                CategoryFormVisible id form category visibility ->
                    let
                        updatedForm =
                            case field of
                                Name name ->
                                    { form | name = name }

                                Description description ->
                                    { form | description = description }

                                ParentCategoryId categoryId ->
                                    { form | parentCategoryId = categoryId }

                                _ ->
                                    form
                    in
                    ( { model | modalState = CategoryFormVisible id updatedForm category visibility }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SemesterClicked semester ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Semester semester.id) )

        SemesterNewClicked ->
            ( { model | modalState = SemesterFormVisible Nothing (initSemesterForm Nothing model.time) NotAsked Modal.shown }, Cmd.none )

        SemesterEditClicked semester ->
            ( { model | modalState = SemesterFormVisible (Just semester.id) (initSemesterForm (Just semester) model.time) NotAsked Modal.shown }, Cmd.none )

        SemesterDeleteClicked semester ->
            ( { model | modalState = SemesterDeleteVisible semester NotAsked Modal.shown }, Cmd.none )

        CategoryClicked category ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Category category.id) )

        CategoryEditClicked category ->
            ( { model | modalState = CategoryFormVisible (Just category.id) (initCategoryForm <| Just category) NotAsked Modal.shown }, Cmd.none )

        CategoryDeleteClicked category ->
            ( { model | modalState = CategoryDeleteVisible category NotAsked Modal.shown }, Cmd.none )

        CategoryNewClicked ->
            ( { model | modalState = CategoryFormVisible Nothing (initCategoryForm Nothing) NotAsked Modal.shown }, Cmd.none )

        FormSubmitClicked ->
            case model.modalState of
                CategoryFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all [ ifBlank .name ( Name form.name, "Name cannot be blank" ) ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | formErrors = [], modalState = CategoryFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateCategory model.session id form GotCategoryFormResult )

                                Nothing ->
                                    ( updatedModel, createCategory model.session form GotCategoryFormResult )

                        Err errors ->
                            ( { model | formErrors = errors }, Cmd.none )

                ClassroomFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all [ ifBlank .name ( Name form.name, "Name cannot be blank" ) ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | formErrors = [], modalState = ClassroomFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateClassroom model.session id form GotClassroomFormResult )

                                Nothing ->
                                    ( updatedModel, createClassroom model.session form GotClassroomFormResult )

                        Err errors ->
                            ( { model | formErrors = errors }, Cmd.none )

                SemesterFormVisible maybeId form result visibility ->
                    let
                        validator =
                            Validate.all [ ifBlank .name ( Name form.name, "Name cannot be blank" ) ]
                    in
                    case validate validator form of
                        Ok _ ->
                            let
                                updatedModel =
                                    { model | formErrors = [], modalState = SemesterFormVisible maybeId form Loading visibility }
                            in
                            case maybeId of
                                Just id ->
                                    ( updatedModel, updateSemester model.session id form GotSemesterFormResult )

                                Nothing ->
                                    ( updatedModel, createSemester model.session form GotSemesterFormResult )

                        Err errors ->
                            ( { model | formErrors = errors }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotClassroomFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        ClassroomFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = ClassroomFormVisible maybeId form result Modal.hidden }, classrooms model.session GotClassrooms )

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
                                    ( { model | modalState = ClassroomDeleteVisible classroom result Modal.hidden }, classrooms model.session GotClassrooms )

                                _ ->
                                    ( { model | modalState = ClassroomDeleteVisible classroom result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotSemesterFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        SemesterFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = SemesterFormVisible maybeId form result Modal.hidden }, semesters model.session GotSemesters )

                                _ ->
                                    ( { model | modalState = SemesterFormVisible maybeId form result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotSemesterDeleteResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        SemesterDeleteVisible semester _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = SemesterDeleteVisible semester result Modal.hidden }, semesters model.session GotSemesters )

                                _ ->
                                    ( { model | modalState = SemesterDeleteVisible semester result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        GotCategoryFormResult result ->
            let
                ( updatedModel, command ) =
                    case model.modalState of
                        CategoryFormVisible maybeId form _ visibility ->
                            case result of
                                Success _ ->
                                    ( { model | modalState = CategoryFormVisible maybeId form result Modal.hidden }, categories model.session Nothing GotCategories )

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
                                    ( { model | modalState = CategoryDeleteVisible category result Modal.hidden }, categories model.session Nothing GotCategories )

                                _ ->
                                    ( { model | modalState = CategoryDeleteVisible category result visibility }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
            API.handleRemoteError result updatedModel command

        DeleteSubmitClicked ->
            case model.modalState of
                ClassroomDeleteVisible data _ visibility ->
                    ( { model | modalState = ClassroomDeleteVisible data Loading visibility }, deleteClassroom model.session data.id GotClassroomDeleteResult )

                SemesterDeleteVisible data _ visibility ->
                    ( { model | modalState = SemesterDeleteVisible data Loading visibility }, deleteSemester model.session data.id GotSemesterDeleteResult )

                CategoryDeleteVisible data _ visibility ->
                    ( { model | modalState = CategoryDeleteVisible data Loading visibility }, deleteCategory model.session data.id GotCategoryDeleteResult )

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

            SemesterFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            SemesterDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            CategoryFormVisible _ _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            CategoryDeleteVisible _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]
