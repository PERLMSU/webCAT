module Page.Login exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Credential, Error(..), ErrorBody)
import API.Auth as Auth
import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Textarea as Textarea
import Browser
import Browser.Navigation as Nav
import Components.Common as Common exposing (Style(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import List.Extra exposing (find)
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
    , alertVisibility : Alert.Visibility
    }


type alias Form =
    { email : String
    , password : String
    }


init : Session -> ( Model, Cmd Msg )
init session =
    let
        model =
            { session = session, credential = NotAsked, formErrors = [], form = { email = "", password = "" }, alertVisibility = Alert.closed }
    in
    case Session.credential session of
        Nothing ->
            ( model, Cmd.none )

        Just _ ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Dashboard )



-- UPDATE


type Msg
    = EmailChanged String
    | PasswordChanged String
    | SignInClicked
    | ForgotPasswordClicked
    | GotLoginResponse (APIData Credential)
    | GotSession Session
      -- Alerts
    | AlertMsg Alert.Visibility


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmailChanged email ->
            updateForm (\form -> { form | email = email }) model

        PasswordChanged pass ->
            updateForm (\form -> { form | password = pass }) model

        SignInClicked ->
            case validate validator model.form of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    ( { model | formErrors = [], credential = Loading }
                    , Auth.login form.email form.password GotLoginResponse
                    )

                Err errors ->
                    ( { model | formErrors = errors }
                    , Cmd.none
                    )

        ForgotPasswordClicked ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.ResetPassword Nothing) )

        GotLoginResponse res ->
            case res of
                Success cred ->
                    ( { model | credential = res }, API.storeCred cred )

                Failure _ ->
                    ( { model | credential = res, alertVisibility = Alert.shown }, Cmd.none )

                _ ->
                    ( { model | credential = res }, Cmd.none )

        GotSession session ->
            case Session.credential session of
                Nothing ->
                    ( { model | session = session, credential = NotAsked }, Cmd.none )

                Just _ ->
                    ( { model | session = session }, Route.replaceUrl (Session.navKey session) Route.Dashboard )

        AlertMsg visibility ->
            ( { model | alertVisibility = visibility }, Cmd.none )


updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | form = transform model.form }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "WebCAT - Login"
    , content =
        let
            feedback field =
                case find (\( f, m ) -> f == field) model.formErrors of
                    Just ( _, message ) ->
                        Form.invalidFeedback [] [ text message ]

                    Nothing ->
                        text ""

            email =
                if not <| List.any (\( f, m ) -> f == Email) model.formErrors then
                    Input.email [ Input.id "email", Input.onInput EmailChanged, Input.placeholder "Email Address", Input.value model.form.email ]

                else
                    Input.email [ Input.id "email", Input.danger, Input.onInput EmailChanged, Input.placeholder "Email Address", Input.value model.form.email ]

            password =
                if not <| List.any (\( f, m ) -> f == Password) model.formErrors then
                    Input.password [ Input.id "password", Input.onInput PasswordChanged, Input.placeholder "Password", Input.value model.form.password ]

                else
                    Input.password [ Input.id "password", Input.danger, Input.onInput PasswordChanged, Input.placeholder "Password", Input.value model.form.password ]

            alert =
                case model.credential of
                    Failure err ->
                        let
                            body =
                                API.getErrorBody err
                        in
                        dangerAlert body.title (Maybe.withDefault "" body.message) model.alertVisibility

                    _ ->
                        text ""

            inner =
                case model.credential of
                    Success _ ->
                        div [ class "text-center py-6" ] [ Common.icon Successful "checkbox" ]

                    Loading ->
                        Common.loading

                    _ ->
                        Form.form [ class "form-signin" ]
                            [ img [ class "mb-4", src "../static/images/physics.svg", width 100, height 100 ] []
                            , h1 [ class "h3 mb-3 font-weight-normal" ] [ text "Please Sign In" ]
                            , Form.label [ for "email", class "sr-only" ] [ text "Email Address" ]
                            , email
                            , feedback Email
                            , Form.label [ for "password", class "sr-only" ] [ text "Password" ]
                            , password
                            , feedback Password
                            , Button.button [ Button.primary, Button.large, Button.block, Button.onClick SignInClicked ] [ text "Log In" ]
                            , Button.button [ Button.secondary, Button.large, Button.block, Button.onClick ForgotPasswordClicked ] [ text "Reset Password" ]
                            ]
        in
        div []
            [ alert
            , div [ class "text-center login-container" ]
                [ inner
                ]
            ]
    }


dangerAlert : String -> String -> Alert.Visibility -> Html Msg
dangerAlert title message visibility =
    Alert.config |> Alert.danger |> Alert.dismissableWithAnimation AlertMsg |> Alert.children [ Alert.h4 [] [ text title ], Alert.h6 [] [ text message ] ] |> Alert.view visibility



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (Session.navKey model.session)
        ]



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
