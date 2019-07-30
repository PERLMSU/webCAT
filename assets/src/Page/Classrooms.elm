module Page.Classrooms exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Classrooms exposing (classrooms, editClassroom, newClassroom)
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Modal as Modal
import Components.Table as Table
import Html exposing (..)
import Html.Attributes exposing (..)
import RemoteData exposing (RemoteData(..))
import Route
import Session as Session exposing (Session)
import Types exposing (Classroom, ClassroomId)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , classrooms : APIData (List Classroom)
    , modalState : ModalState
    , classroomForm : Form
    , formErrors : List ( FormField, String )
    }


type ModalState
    = Hidden
    | EditVisible ClassroomId (APIData Classroom)
    | NewVisible (APIData Classroom)


type alias Form =
    { courseCode : String
    , name : String
    , description : String
    }


type FormField
    = CourseCode
    | Name
    | Description


type Msg
    = GotSession Session
    | GotClassrooms (APIData (List Classroom))
    | GotClassroomUpdate (APIData Classroom)
    | GotClassroomCreate (APIData Classroom)
      -- Buttons
    | ClassroomSelected Classroom
    | TableEditClicked Classroom
    | TableDeleteClicked Classroom
    | NewClassroomClicked
      -- Form submits
    | EditClassroomSubmit ClassroomId
    | NewClassroomSubmit
      -- Form events
    | CourseCodeChanged String
    | NameChanged String
    | DescriptionChanged String
      -- Modal events
    | ModalClosed


init : Session -> ( Model, Cmd Msg )
init session =
    if Session.isAuthenticated session then
        ( { session = session
          , classrooms = Loading
          , modalState = Hidden
          , classroomForm = initialForm Nothing
          , formErrors = []
          }
        , classrooms session GotClassrooms
        )

    else
        ( { session = session
          , classrooms = NotAsked
          , modalState = Hidden
          , classroomForm = initialForm Nothing
          , formErrors = []
          }
        , Route.replaceUrl (Session.navKey session) (Route.Login Nothing)
        )


toSession : Model -> Session
toSession model =
    model.session


tableConfig : Table.Config Classroom Msg
tableConfig =
    let
        render item =
            [ item.courseCode, item.name, Maybe.withDefault "" item.description ]
    in
    { render = render
    , headers = [ "Course Code", "Name", "Description" ]
    , tableClass = "w-full table-auto"
    , headerClass = "text-left text-gray-400"
    , rowClass = "border-t-1 border-gray-500 text-gray-400 cursor-pointer hover:bg-slate py-1"
    , onClick = ClassroomSelected
    , onEdit = TableEditClicked
    , onDelete = TableDeleteClicked
    }


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Classrooms"
    , content =
        let
            rendered =
                case model.classrooms of
                    NotAsked ->
                        div [] [ text "Data fetch not started" ]

                    Loading ->
                        Common.loading

                    Failure e ->
                        div [] [ text "Error" ]

                    Success classrooms ->
                        div [ class "mx-4 my-2 flex" ] [ Table.view tableConfig classrooms ]

            modal =
                case model.modalState of
                    Hidden ->
                        text ""

                    EditVisible id classroom ->
                        viewModal model (Just id) classroom

                    NewVisible classroom ->
                        viewModal model Nothing classroom
        in
        div []
            [ Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ h1 [ class "text-4xl text-gray-400 font-display" ] [ text "Classrooms" ]
                    , Common.successButton "New" NewClassroomClicked
                    ]
                , rendered
                ]
            , modal
            ]
    }


viewModal : Model -> Maybe ClassroomId -> APIData Classroom -> Html Msg
viewModal model maybeId remoteClassroom =
    let
        submitAction =
            case maybeId of
                Just id ->
                    EditClassroomSubmit id

                Nothing ->
                    NewClassroomSubmit

        content =
            case remoteClassroom of
                Failure e ->
                    case e of
                        _ ->
                            Debug.todo "Handle error states in form"

                Loading ->
                    [ Common.loading ]

                _ ->
                    [ div [ class "flex flex-wrap -mx-3 mb-6" ]
                        [ div [ class "w-full md:w-1/2 px-3 mb-6 md:mb-0" ]
                            [ Form.label "Course Code" "courseCode"
                            , Form.textInput "courseCode" CourseCode model.formErrors CourseCodeChanged model.classroomForm.courseCode
                            ]
                        , div [ class "w-full md:w-1/2 px-3 mb-6 md:mb-0" ]
                            [ Form.label "Name" "name"
                            , Form.textInput "name" Name model.formErrors NameChanged model.classroomForm.name
                            ]
                        ]
                    , div [ class "flex flex-wrap -mx-3 mb-6" ]
                        [ div [ class "w-full px-3 mb-6 md:mb-0" ]
                            [ Form.label "Description" "description"
                            , Form.textInput "description" Description model.formErrors DescriptionChanged model.classroomForm.description
                            ]
                        ]
                    , Common.successButton "Submit" submitAction
                    ]
    in
    Modal.view { onClose = ModalClosed, title = "Edit Classroom" }
        [ Html.form [ class "w-full max-w-lg mb-8" ]
            content
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session

        GotClassrooms result ->
            case result of
                Failure err ->
                    case err of
                        Unauthorized _ ->
                            ( { model | classrooms = result }, API.logout )

                        _ ->
                            ( { model | classrooms = result }, Cmd.none )

                _ ->
                    ( { model | classrooms = result }, Cmd.none )

        CourseCodeChanged val ->
            updateForm (\form -> { form | courseCode = val }) model

        NameChanged val ->
            updateForm (\form -> { form | name = val }) model

        DescriptionChanged val ->
            updateForm (\form -> { form | description = val }) model

        TableEditClicked classroom ->
            ( { model | classroomForm = initialForm (Just classroom), modalState = EditVisible classroom.id NotAsked }, Cmd.none )

        NewClassroomClicked ->
            ( { model | classroomForm = initialForm Nothing, modalState = NewVisible NotAsked }, Cmd.none )

        ModalClosed ->
            ( { model | classroomForm = initialForm Nothing, modalState = Hidden }, Cmd.none )

        EditClassroomSubmit id ->
            case validate validator model.classroomForm of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    ( { model
                        | formErrors = []
                        , classroomForm = { courseCode = "", name = "", description = "" }
                      }
                    , editClassroom model.session id form GotClassroomUpdate
                    )

                Err errors ->
                    ( { model | formErrors = errors }, Cmd.none )

        GotClassroomUpdate data ->
            case data of
                Success classroom ->
                    updateClassroomList { model | classroomForm = initialForm Nothing, modalState = Hidden } classroom

                NotAsked ->
                    ( model, Cmd.none )

                _ ->
                    updateModalState model data

        NewClassroomSubmit ->
            case validate validator model.classroomForm of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    ( { model
                        | formErrors = []
                        , classroomForm = { courseCode = "", name = "", description = "" }
                      }
                    , newClassroom model.session form GotClassroomCreate
                    )

                Err errors ->
                    ( { model | formErrors = errors }, Cmd.none )

        GotClassroomCreate data ->
            case data of
                Success _ ->
                    ( { model | classroomForm = initialForm Nothing, modalState = Hidden, classrooms = Loading }, classrooms model.session GotClassrooms )

                NotAsked ->
                    ( model, Cmd.none )

                _ ->
                    updateModalState model data

        _ ->
            ( model, Cmd.none )


updateClassroomList : Model -> Classroom -> ( Model, Cmd Msg )
updateClassroomList model classroom =
    case model.classrooms of
        Success classrooms ->
            let
                updateClassroom item =
                    if item.id == classroom.id then
                        classroom

                    else
                        item

                items =
                    List.map updateClassroom classrooms
            in
            ( { model | classrooms = Success items }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateModalState : Model -> APIData Classroom -> ( Model, Cmd Msg )
updateModalState model classroom =
    case model.modalState of
        Hidden ->
            ( model, Cmd.none )

        EditVisible id _ ->
            ( { model | modalState = EditVisible id classroom }, Cmd.none )

        NewVisible _ ->
            ( { model | modalState = NewVisible classroom }, Cmd.none )


initialForm : Maybe Classroom -> Form
initialForm maybeClassroom =
    case maybeClassroom of
        Nothing ->
            Form "" "" ""

        Just classroom ->
            { courseCode = classroom.courseCode, name = classroom.name, description = Maybe.withDefault "" classroom.description }


updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | classroomForm = transform model.classroomForm }, Cmd.none )


validator : Validator ( FormField, String ) Form
validator =
    Validate.all
        [ ifBlank .courseCode ( CourseCode, "Please enter a course code" )
        , ifBlank .name ( Name, "Please enter a name" )
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
