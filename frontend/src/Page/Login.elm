module Page.Login exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Credential, Error(..), ErrorBody)
import API.Auth as Auth
import Browser
import Browser.Navigation as Nav
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Process as Process
import RemoteData exposing (RemoteData(..))
import Route
import Session exposing (Session)
import Url
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)



-- MODEL


type alias Model =
    { session : Session
    , credential : APIData Credential
    , formErrors : List ( Field, String )
    , form : Form
    }


type alias Form =
    { email : String
    , password : String
    }


init : Session -> ( Model, Cmd Msg )
init session =
    let
        model =
            { session = session
            , credential = NotAsked
            , formErrors = []
            , form =
                { email = ""
                , password = ""
                }
            }
    in
    case Session.credential session of
        Nothing ->
            ( model, Cmd.none )

        Just _ ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Classrooms )



-- UPDATE


type Msg
    = EmailChanged String
    | PasswordChanged String
    | SignIn
    | ForgotPassword
    | Response (APIData Credential)
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmailChanged email ->
            updateForm (\form -> { form | email = email }) model

        PasswordChanged pass ->
            updateForm (\form -> { form | password = pass }) model

        SignIn ->
            case validate validator model.form of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    ( { model | formErrors = [], credential = Loading }
                    , Auth.login form.email form.password Response
                    )

                Err errors ->
                    ( { model | formErrors = errors }
                    , Cmd.none
                    )

        ForgotPassword ->
            Debug.todo "forgot password"

        Response res ->
            case res of
                Success cred ->
                    ( { model | credential = res }, API.storeCred cred )

                _ ->
                    ( { model | credential = res }, Cmd.none )

        GotSession session ->
            let
                _ =
                    Debug.log "Session" session
            in
            case Session.credential session of
                Nothing ->
                    ( { model | session = session, credential = NotAsked }, Cmd.none )

                Just _ ->
                    ( { model | session = session }, Route.replaceUrl (Session.navKey session) Route.Classrooms )


updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | form = transform model.form }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "WebCAT - Login"
    , content =
        case model.credential of
            Success _ ->
                div [ class "flex justify-center bg-slate py-32" ]
                    [ div [ class "w-full h-screen max-w-xs" ]
                        [ Html.form [ class "bg-light-slate shadow-md rounded px-8 pt-6 pb-8 mb-4" ]
                            [ div [ class "text-center py-6" ] [ Common.icon Successful "checkbox" ]
                            ]
                        ]
                    ]

            Loading ->
                div [ class "flex justify-center bg-slate py-32" ]
                    [ div [ class "w-full h-screen max-w-xs" ]
                        [ Html.form [ class "bg-light-slate shadow-md rounded px-8 pt-6 pb-8 mb-4" ]
                            [ Common.loading
                            ]
                        ]
                    ]

            _ ->
                div [ class "flex justify-center bg-slate py-32" ]
                    [ div [ class "w-full h-screen max-w-xs" ]
                        [ Html.form [ class "bg-light-slate shadow-md rounded px-8 pt-6 pb-8 mb-4" ]
                            [ Form.label "Email" "email"
                            , Form.textInput "email" Email model.formErrors EmailChanged model.form.email
                            , Form.label "Password" "password"
                            , Form.passwordInput "password" Password model.formErrors PasswordChanged model.form.password
                            , div [ class "flex items-center justify-between" ]
                                [ Common.successButton "Sign In" SignIn

                                --, primaryButton ForgotPassword "Forgot Password"
                                ]
                            ]
                        ]
                    ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- FORM


{-| When adding a variant here, add it to `fieldsToValidate` too!
-}
type Field
    = Email
    | Password


validator : Validator ( Field, String ) Form
validator =
    Validate.all
        [ Validate.firstError
            [ ifBlank .email ( Email, "Please enter your email" )
            , ifInvalidEmail .email (\email -> ( Email, email ++ " is not a valid email address" ))
            ]
        , ifBlank .password ( Password, "Please enter your password" )
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
