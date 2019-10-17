module Page.Users exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Users exposing (UserForm, deleteUser, editUser, newUser, users)
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Modal as Modal
import Components.Table as Table
import Html exposing (..)
import Html.Attributes exposing (..)
import RemoteData exposing (RemoteData(..))
import Route
import Session as Session exposing (Session)
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , users : APIData (List User)
    , modalState : ModalState
    , userForm : UserForm
    , formErrors : List ( FormField, String )
    }


type ModalState
    = Hidden
    | EditVisible User (APIData User)
    | NewVisible (APIData User)
    | DeleteVisible User (APIData User)


type FormField
    = Email
    | FirstName
    | MiddleName
    | LastName
    | Nickname
    | Active
    | Classrooms
    | Semesters
    | Sections
    | Rotations
    | RotationGroups
    | Roles


type Msg
    = GotSession Session
    | GotUsers (APIData (List User))
    | GotUserUpdate (APIData User)
    | GotUserCreate (APIData User)
    | GotUserDelete (APIData ())
      -- Buttons
    | UserSelected User
    | TableEditClicked User
    | TableDeleteClicked User
    | NewUserClicked
      -- Form submits
    | EditUserSubmit User
    | NewUserSubmit
    | DeleteUserSubmit User
      -- Form events
    | EmailChanged String
    | FirstNameChanged String
    | MiddleNameChanged String
    | LastNameChanged String
    | NicknameChanged String
    | ActiveChanged Bool
      -- Modal events
    | ModalClosed


init : Session -> ( Model, Cmd Msg )
init session =
    if Session.isAuthenticated session then
        ( { session = session
          , users = Loading
          , modalState = Hidden
          , userForm = initialForm Nothing
          , formErrors = []
          }
        , users session GotUsers
        )

    else
        ( { session = session
          , users = NotAsked
          , modalState = Hidden
          , userForm = initialForm Nothing
          , formErrors = []
          }
        , Route.replaceUrl (Session.navKey session) Route.Login
        )


toSession : Model -> Session
toSession model =
    model.session


tableConfig : Table.Config User Msg
tableConfig =
    let
        render item =
            [ item.email, item.firstName, item.lastName ]
    in
    { render = render
    , headers = [ "Email", "First Name", "Last Name" ]
    , onClick = UserSelected
    , onEdit = TableEditClicked
    , onDelete = TableDeleteClicked
    }


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Users"
    , content =
        let
            rendered =
                case model.users of
                    NotAsked ->
                        div [] [ text "Data fetch not started" ]

                    Loading ->
                        Common.loading

                    Failure e ->
                        div [ class "mx-4 my-2" ] [ div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ] ]

                    Success users ->
                        div [ class "mx-4 my-2 flex" ] [ Table.view tableConfig users ]

            modal =
                case model.modalState of
                    Hidden ->
                        text ""

                    EditVisible user data ->
                        viewModal model (Just user) data

                    NewVisible data ->
                        viewModal model Nothing data

                    DeleteVisible user data ->
                        viewDeleteModal model user data
        in
        div []
            [ Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ h1 [ class "text-4xl text-gray-400 font-display" ] [ text "Users" ]
                    , Common.successButton "New" NewUserClicked
                    ]
                , rendered
                ]
            , modal
            ]
    }


viewModal : Model -> Maybe User -> APIData User -> Html Msg
viewModal model maybeUser remoteUser =
    let
        ( submitAction, title ) =
            case maybeUser of
                Just user ->
                    ( EditUserSubmit user, "Edit User" )

                Nothing ->
                    ( NewUserSubmit, "New User" )

        content =
            case remoteUser of
                Failure e ->
                    [ div [ class "flex flex-wrap -mx-3 mb-6" ]
                        [ div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ]
                        , div [ class "w-full md:w-1/3 px-3 mb-6 md:mb-0" ]
                            [ Form.label "First Name" "firstName"
                            , Form.textInput "firstName" FirstName model.formErrors FirstNameChanged model.userForm.firstName
                            ]
                        , div [ class "w-full md:w-1/3 px-3 mb-6 md:mb-0" ]
                            [ Form.label "Middle Name" "middleName"
                            , Form.textInput "middleName" MiddleName model.formErrors MiddleNameChanged model.userForm.middleName
                            ]
                        , div [ class "w-full md:w-1/3 px-3 mb-6 md:mb-0" ]
                            [ Form.label "Last Name" "lastName"
                            , Form.textInput "lastName" LastName model.formErrors LastNameChanged model.userForm.lastName
                            ]
                        ]
                    , div [ class "flex flex-wrap -mx-3 mb-6" ]
                        [ div [ class "w-full px-3 mb-6 md:mb-0" ]
                            [ Form.label "Email" "email"
                            , Form.textInput "email" Email model.formErrors EmailChanged model.userForm.email
                            ]
                        ]
                    , Common.successButton "Submit" submitAction
                    ]

                Loading ->
                    [ Common.loading ]

                _ ->
                    [ div [ class "flex flex-wrap -mx-3 mb-6" ]
                        [ div [ class "w-full md:w-1/3 px-3 mb-6 md:mb-0" ]
                            [ Form.label "First Name" "firstName"
                            , Form.textInput "firstName" FirstName model.formErrors FirstNameChanged model.userForm.firstName
                            ]
                        , div [ class "w-full md:w-1/3 px-3 mb-6 md:mb-0" ]
                            [ Form.label "Middle Name" "middleName"
                            , Form.textInput "middleName" MiddleName model.formErrors MiddleNameChanged model.userForm.middleName
                            ]
                        , div [ class "w-full md:w-1/3 px-3 mb-6 md:mb-0" ]
                            [ Form.label "Last Name" "lastName"
                            , Form.textInput "lastName" LastName model.formErrors LastNameChanged model.userForm.lastName
                            ]
                        ]
                    , div [ class "flex flex-wrap -mx-3 mb-6" ]
                        [ div [ class "w-full px-3 mb-6 md:mb-0" ]
                            [ Form.label "Email" "email"
                            , Form.textInput "email" Email model.formErrors EmailChanged model.userForm.email
                            ]
                        ]
                    , Common.successButton "Submit" submitAction
                    ]
    in
    Modal.view { onClose = ModalClosed, title = title }
        [ Html.form [ class "w-full max-w-lg mb-8" ]
            content
        ]


viewDeleteModal : Model -> User -> APIData User -> Html Msg
viewDeleteModal model user remoteUser =
    let
        content =
            case remoteUser of
                Failure e ->
                    [ div [ class "text-2xl text-italic text-danger" ] [ text <| API.errorBodyToString <| API.getErrorBody e ]
                    , div [ class "text-gray-400" ] [ text <| "Are you sure you want to delete " ++ user.email ++ "?" ]
                    , div [ class "text-xl text-danger" ] [ text "Deleting this user is permanent" ]
                    , Common.dangerButton "Delete" <| DeleteUserSubmit user
                    ]

                Loading ->
                    [ Common.loading ]

                _ ->
                    [ div [ class "text-gray-400" ] [ text <| "Are you sure you want to delete " ++ user.email ++ "?" ]
                    , div [ class "text-xl text-danger" ] [ text "Deleting this user is permanent" ]
                    , Common.dangerButton "Delete" <| DeleteUserSubmit user
                    ]
    in
    Modal.view { onClose = ModalClosed, title = "Delete User?" }
        content


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session

        GotUsers result ->
            case result of
                Failure err ->
                    case err of
                        Unauthorized _ ->
                            ( { model | users = result }, API.logout )

                        _ ->
                            ( { model | users = result }, Cmd.none )

                _ ->
                    ( { model | users = result }, Cmd.none )

        EmailChanged val ->
            updateForm (\form -> { form | email = val }) model

        FirstNameChanged val ->
            updateForm (\form -> { form | firstName = val }) model

        MiddleNameChanged val ->
            updateForm (\form -> { form | middleName = val }) model

        LastNameChanged val ->
            updateForm (\form -> { form | lastName = val }) model

        NicknameChanged val ->
            updateForm (\form -> { form | nickname = val }) model

        ActiveChanged val ->
            updateForm (\form -> { form | active = val }) model

        TableEditClicked user ->
            ( { model | userForm = initialForm (Just user), modalState = EditVisible user NotAsked }, Cmd.none )

        NewUserClicked ->
            ( { model | userForm = initialForm Nothing, modalState = NewVisible NotAsked }, Cmd.none )

        ModalClosed ->
            ( { model | userForm = initialForm Nothing, modalState = Hidden }, Cmd.none )

        EditUserSubmit user ->
            case validate validator model.userForm of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    ( { model
                        | formErrors = []
                        , modalState = EditVisible user Loading
                      }
                    , editUser model.session user.id form GotUserUpdate
                    )

                Err errors ->
                    ( { model | formErrors = errors }, Cmd.none )

        GotUserUpdate data ->
            case data of
                Success user ->
                    updateUserList { model | userForm = initialForm Nothing, modalState = Hidden } user

                NotAsked ->
                    ( model, Cmd.none )

                _ ->
                    updateModalState model data

        NewUserSubmit ->
            case validate validator model.userForm of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    ( { model
                        | formErrors = []
                        , modalState = NewVisible Loading
                      }
                    , newUser model.session form GotUserCreate
                    )

                Err errors ->
                    ( { model | formErrors = errors }, Cmd.none )

        GotUserCreate data ->
            case data of
                Success _ ->
                    ( { model | userForm = initialForm Nothing, modalState = Hidden, users = Loading }, users model.session GotUsers )

                _ ->
                    updateModalState model data

        UserSelected user ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.User user.id) )

        TableDeleteClicked user ->
            ( { model | modalState = DeleteVisible user NotAsked }, Cmd.none )

        DeleteUserSubmit user ->
            ( { model | modalState = DeleteVisible user Loading }, deleteUser model.session user.id GotUserDelete )

        GotUserDelete data ->
            case data of
                Success _ ->
                    ( { model | modalState = Hidden, users = Loading }, users model.session GotUsers )

                _ ->
                    -- TODO: Need a better way to handle modal state
                    ( model, Cmd.none )


updateUserList : Model -> User -> ( Model, Cmd Msg )
updateUserList model user =
    case model.users of
        Success users ->
            let
                updateUser item =
                    if item.id == user.id then
                        user

                    else
                        item

                items =
                    List.map updateUser users
            in
            ( { model | users = Success items }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateModalState : Model -> APIData User -> ( Model, Cmd Msg )
updateModalState model remoteUser =
    case model.modalState of
        Hidden ->
            ( model, Cmd.none )

        EditVisible user _ ->
            ( { model | modalState = EditVisible user remoteUser }, Cmd.none )

        NewVisible _ ->
            ( { model | modalState = NewVisible remoteUser }, Cmd.none )

        DeleteVisible user _ ->
            ( { model | modalState = DeleteVisible user remoteUser }, Cmd.none )


initialForm : Maybe User -> UserForm
initialForm maybeUser =
    case maybeUser of
        Nothing ->
            { email = ""
            , firstName = ""
            , middleName = ""
            , nickname = ""
            , lastName = ""
            , active = True
            , classrooms = []
            , sections = []
            , rotationGroups = []
            , role = Student
            }

        Just user ->
            { email = user.email
            , firstName = user.firstName
            , middleName = Maybe.withDefault "" user.middleName
            , nickname = Maybe.withDefault "" user.nickname
            , lastName = user.lastName
            , active = user.active
            , classrooms = user.classrooms
            , sections = user.sections
            , rotationGroups = user.rotationGroups
            , role = user.role
            }


updateForm : (UserForm -> UserForm) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | userForm = transform model.userForm }, Cmd.none )


validator : Validator ( FormField, String ) UserForm
validator =
    Validate.all
        [ Validate.firstError
            [ ifBlank .email ( Email, "Please enter your email" )
            , ifInvalidEmail .email (\email -> ( Email, email ++ " is not a valid email address" ))
            ]
        , ifBlank .firstName ( FirstName, "Please enter a first name" )
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
