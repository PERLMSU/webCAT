module Page.Dashboard exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (..)
import API.Classrooms exposing (..)
import API.Feedback exposing (..)
import Bootstrap.Modal as Modal
import Components.Common as Common
import Components.Table as Table
import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (..)
import Route
import Session exposing (Session)
import Task
import Time
import Types exposing (..)


type alias Model =
    { session : Session
    , timezone : Maybe Time.Zone

    -- Remote data
    , classrooms : APIData (List Classroom)
    , semesters : APIData (List Semester)
    , categories : APIData (List Category)

    -- Modals
    , editClassroomVisibility : Modal.Visibility
    , deleteClassroomVisibility : Modal.Visibility
    , editSemesterVisibility : Modal.Visibility
    , deleteSemesterVisibility : Modal.Visibility
    , editCategoryVisibility : Modal.Visibility
    , deleteCategoryVisibility : Modal.Visibility

    -- Classroom Form
    , classroomForm : ClassroomForm
    , classroomFormErrors : List ( FormField, String )
                            
    -- Semester Form
    , semesterForm : SemesterForm
    , semesterFormErrors : List ( FormField, String )

    -- Category Form
    , categoryForm : CategoryForm
    , categoryFormErrors : List ( FormField, String )
    }


type FormField
    = CourseCode String
    | Name String
    | Description String
    | StartDate Time.Posix
    | EndDate Time.Posix


type Msg
    = GotSession Session
    | GotClassrooms (APIData (List Classroom))
    | GotSemesters (APIData (List Semester))
    | GotCategories (APIData (List Category))
      -- Classroom table
    | ClassroomClicked Classroom
    | ClassroomNewClicked
    | ClassroomEditClicked Classroom
    | ClassroomDeleteClicked Classroom
    | ClassroomFormModalClose
    | ClassroomFormModalAnimate Modal.Visibility
    | ClassroomFormUpdate FormField
    | ClassroomDeleteModalClose
    | ClassroomDeleteModalAnimate Modal.Visibility
      -- Semester table
    | SemesterClicked Semester
    | SemesterNewClicked
    | SemesterEditClicked Semester
    | SemesterDeleteClicked Semester
    | SemesterFormModalClose
    | SemesterFormModalAnimate Modal.Visibility
    | SemesterFormUpdate FormField
    | SemesterDeleteModalClose
    | SemesterDeleteModalAnimate Modal.Visibility
      -- Category
    | CategoryClicked Category
    | CategoryNewClicked
    | CategoryEditClicked Category
    | CategoryDeleteClicked Category
    | CategoryFormModalClose
    | CategoryFormModalAnimate Modal.Visibility
    | CategoryFormUpdate FormField
    | CategoryDeleteModalClose
    | CategoryDeleteModalAnimate Modal.Visibility
      -- Date stuff
    | GotTimezone Time.Zone
    | GotTime Time.Posix


init : Session -> ( Model, Cmd Msg )
init session =
    case Session.credential session of
        Nothing ->
            ( { session = session
              , classrooms = NotAsked
              , semesters = NotAsked
              , categories = NotAsked
              , timezone = Nothing
              , editClassroomVisibility = Modal.hiddenAnimated
              , deleteClassroomVisibility = Modal.hiddenAnimated
              , editSemesterVisibility = Modal.hiddenAnimated
              , deleteSemesterVisibility = Modal.hiddenAnimated
              , editCategoryVisibility = Modal.hiddenAnimated
              , deleteCategoryVisibility = Modal.hiddenAnimated
              , classroomForm = {courseCode = "", name = "", description = "" }
              , classroomFormErrors = []
              , semesterForm = {name = "", description = "", startDate = Time.millisToPosix 0, endDate = Time.millisToPosix 0 }
              , semesterFormErrors = []
              , categoryForm = {name = "", description = "", parentCategoryId = Nothing}
              , categoryFormErrors = []
              }
            , Route.replaceUrl (Session.navKey session) Route.Login
            )

        Just _ ->
            ( { session = session
              , classrooms = Loading
              , semesters = Loading
              , categories = Loading
              , timezone = Nothing
              , editClassroomVisibility = Modal.hiddenAnimated
              , deleteClassroomVisibility = Modal.hiddenAnimated
              , editSemesterVisibility = Modal.hiddenAnimated
              , deleteSemesterVisibility = Modal.hiddenAnimated
              , editCategoryVisibility = Modal.hiddenAnimated
              , deleteCategoryVisibility = Modal.hiddenAnimated
              , classroomForm = {courseCode = "", name = "", description = "" }
              , classroomFormErrors = []
              , semesterForm = {name = "", description = "", startDate = Time.millisToPosix 0, endDate = Time.millisToPosix 0 }
              , semesterFormErrors = []
              , categoryForm = {name = "", description = "", parentCategoryId = Nothing}
              , categoryFormErrors = []
              }
            , Cmd.batch
                [ listClassrooms session GotClassrooms
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
        [ h1 [ class "" ] [ text "Classrooms" ]
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
        [ h1 [ class "" ] [ text "Semesters" ]
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
        [ h1 [ class "" ] [ text "Categories" ]
        , hr [] []
        , case model.categories of
            Success categories ->
                Table.view tableConfig categories

            Failure e ->
                text <| (API.getErrorBody >> API.errorBodyToString) e

            _ ->
                Common.loading
        ]


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

        ClassroomClicked classroom ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Classroom classroom.id) )

        ClassroomEditClicked classroom ->
            Debug.todo "ClassroomEditClicked"

        ClassroomDeleteClicked classroom ->
            Debug.todo "ClassroomDeleteClicked"

        SemesterClicked semester ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Semester semester.id) )

        SemesterEditClicked semester ->
            Debug.todo "SemesterEditClicked"

        SemesterDeleteClicked semester ->
            Debug.todo "SemesterDeleteClicked"

        CategoryClicked category ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Category category.id) )

        CategoryEditClicked category ->
            Debug.todo "CategoryEditClicked"

        CategoryDeleteClicked category ->
            Debug.todo "CategoryDeleteClicked"

        GotTimezone tz ->
            ( { model | timezone = Just tz }, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
