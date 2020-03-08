module Page.Classrooms exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Classrooms exposing (ClassroomForm, listClassrooms, deleteClassroom, updateClassroom, initClassroomForm, createClassroom)
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
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
    , classroomForm : ClassroomForm
    , formErrors : List ( FormField, String )
    }


type ModalState
    = Hidden
    | EditVisible Classroom (APIData Classroom)
    | NewVisible (APIData Classroom)
    | DeleteVisible Classroom (APIData Classroom)


type FormField
    = CourseCode
    | Name
    | Description


type Msg
    = GotSession Session
    | GotClassrooms (APIData (List Classroom))
    | GotClassroomUpdate (APIData Classroom)
    | GotClassroomCreate (APIData Classroom)
    | GotClassroomDelete (APIData ())
      -- Buttons
    | ClassroomSelected Classroom
    | TableEditClicked Classroom
    | TableDeleteClicked Classroom
    | NewClassroomClicked
      -- Form submits
    | EditClassroomSubmit Classroom
    | NewClassroomSubmit
    | DeleteClassroomSubmit Classroom
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
          , classroomForm = initClassroomForm Nothing
          , formErrors = []
          }
        , listClassrooms session GotClassrooms
        )

    else
        ( { session = session
          , classrooms = NotAsked
          , modalState = Hidden
          , classroomForm = initClassroomForm Nothing
          , formErrors = []
          }
        , Route.replaceUrl (Session.navKey session) Route.Login
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
                        div [ class "mx-4 my-2 flex" ] [ div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ] ]

                    Success classrooms ->
                        div [ class "mx-4 my-2 flex" ] [ Table.view tableConfig classrooms ]

            modal =
                case model.modalState of
                    Hidden ->
                        text ""

                    EditVisible classroom data ->
                        viewModal model (Just classroom) data

                    NewVisible data ->
                        viewModal model Nothing data

                    DeleteVisible classroom data ->
                        viewDeleteModal model classroom data
        in
        div []
            [ div []
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ h1 [ class "text-4xl text-gray-400 font-display" ] [ text "Classrooms" ]
                    --, Common.successButton "New" NewClassroomClicked
                    ]
                , rendered
                ]
            , modal
            ]
    }


viewModal : Model -> Maybe Classroom -> APIData Classroom -> Html Msg
viewModal model maybeClassroom remoteClassroom =
    let
        ( submitAction, title ) =
            case maybeClassroom of
                Just classroom ->
                    ( EditClassroomSubmit classroom, "Edit Classroom" )

                Nothing ->
                    ( NewClassroomSubmit, "New Classroom" )

        content =
            case remoteClassroom of
                Failure e ->
                    [ div [ class "flex flex-wrap -mx-3 mb-6" ]
                        [ div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ]
                        , div [ class "w-full md:w-1/2 px-3 mb-6 md:mb-0" ]
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
                    --, Common.successButton "Submit" submitAction
                    ]

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
                    -- , Common.successButton "Submit" submitAction
                    ]
    in
    Modal.view { onClose = ModalClosed, title = title }
        [ Html.form [ class "w-full max-w-lg mb-8" ]
            content
        ]


viewDeleteModal : Model -> Classroom -> APIData Classroom -> Html Msg
viewDeleteModal model classroom remoteClassroom =
    let
        content =
            case remoteClassroom of
                Failure e ->
                    [ div [ class "text-2xl text-italic text-danger" ] [ text <| API.errorBodyToString <| API.getErrorBody e ]
                    , div [ class "text-gray-400" ] [ text <| "Are you sure you want to delete " ++ classroom.courseCode ++ "?" ]
                    , div [ class "text-xl text-danger" ] [ text "Deleting this classroom is permanent and will delete ALL associated:" ]
                    , ul [ class "pl-4 mb-4 mt-2 text-gray-400 list-disc" ]
                        [ li [] [ text "Semesters" ]
                        , li [] [ text "Categories" ]
                        , li [] [ text "Observations" ]
                        , li [] [ text "Feedback" ]
                        ]
                    --, Common.dangerButton "Delete" <| DeleteClassroomSubmit classroom
                    ]

                Loading ->
                    [ Common.loading ]

                _ ->
                    [ div [ class "text-gray-400" ] [ text <| "Are you sure you want to delete " ++ classroom.courseCode ++ "?" ]
                    , div [ class "text-xl text-danger" ] [ text "Deleting this classroom is permanent and will delete ALL associated:" ]
                    , ul [ class "pl-4 mb-4 mt-2 text-gray-400 list-disc" ]
                        [ li [] [ text "Semesters" ]
                        , li [] [ text "Categories" ]
                        , li [] [ text "Observations" ]
                        , li [] [ text "Feedback" ]
                        ]
                    --, Common.dangerButton "Delete" <| DeleteClassroomSubmit classroom
                    ]
    in
    Modal.view { onClose = ModalClosed, title = "Delete Classroom?" }
        content


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session

        GotClassrooms result ->
            API.handleRemoteError result { model | classrooms = result } Cmd.none

        CourseCodeChanged val ->
            updateForm (\form -> { form | courseCode = val }) model

        NameChanged val ->
            updateForm (\form -> { form | name = val }) model

        DescriptionChanged val ->
            updateForm (\form -> { form | description = val }) model

        TableEditClicked classroom ->
            ( { model | classroomForm = initClassroomForm (Just classroom), modalState = EditVisible classroom NotAsked }, Cmd.none )

        NewClassroomClicked ->
            ( { model | classroomForm = initClassroomForm Nothing, modalState = NewVisible NotAsked }, Cmd.none )

        ModalClosed ->
            ( { model | classroomForm = initClassroomForm Nothing, modalState = Hidden }, Cmd.none )

        EditClassroomSubmit classroom ->
            case validate validator model.classroomForm of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    ( { model
                        | formErrors = []
                        , modalState = EditVisible classroom Loading
                      }
                    , updateClassroom model.session classroom.id form GotClassroomUpdate
                    )

                Err errors ->
                    ( { model | formErrors = errors }, Cmd.none )

        GotClassroomUpdate data ->
            case data of
                Success classroom ->
                    updateClassroomList { model | classroomForm = initClassroomForm Nothing, modalState = Hidden } classroom

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
                        , modalState = NewVisible Loading
                      }
                    , createClassroom model.session form GotClassroomCreate
                    )

                Err errors ->
                    ( { model | formErrors = errors }, Cmd.none )

        GotClassroomCreate data ->
            case data of
                Success _ ->
                    ( { model | classroomForm = initClassroomForm Nothing, modalState = Hidden, classrooms = Loading }, listClassrooms model.session GotClassrooms )

                _ ->
                    updateModalState model data

        ClassroomSelected classroom ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Classroom classroom.id) )

        TableDeleteClicked classroom ->
            ( { model | modalState = DeleteVisible classroom NotAsked }, Cmd.none )

        DeleteClassroomSubmit classroom ->
            ( { model | modalState = DeleteVisible classroom Loading }, deleteClassroom model.session classroom.id GotClassroomDelete )

        GotClassroomDelete data ->
            case data of
                Success _ ->
                    ( { model | modalState = Hidden, classrooms = Loading }, listClassrooms model.session GotClassrooms )

                _ ->
                    -- TODO: Need a better solution for handling delete errors
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
updateModalState model remoteClassroom =
    case model.modalState of
        Hidden ->
            ( model, Cmd.none )

        EditVisible classroom _ ->
            ( { model | modalState = EditVisible classroom remoteClassroom }, Cmd.none )

        NewVisible _ ->
            ( { model | modalState = NewVisible remoteClassroom }, Cmd.none )

        DeleteVisible classroom _ ->
            ( { model | modalState = DeleteVisible classroom remoteClassroom }, Cmd.none )


updateForm : (ClassroomForm -> ClassroomForm) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | classroomForm = transform model.classroomForm }, Cmd.none )


validator : Validator ( FormField, String ) ClassroomForm
validator =
    Validate.all
        [ ifBlank .courseCode ( CourseCode, "Please enter a course code" )
        , ifBlank .name ( Name, "Please enter a name" )
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
