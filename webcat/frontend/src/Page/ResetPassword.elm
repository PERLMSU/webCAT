module Page.ResetPassword exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Credential, Error(..), ErrorBody)
import API.Auth as Auth
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
import Validate exposing (Validator, ifBlank, ifFalse, ifInvalidEmail, validate)



-- MODEL


type alias Model =
    { session : Session
    , token : Maybe String
    , credential : APIData Credential
    , startReset : APIData ()
    , formErrors : List ( Field, String )
    , form : Form
    }


type alias Form =
    { email : String

    -- Finish reset
    , newPassword : String
    , newPasswordConfirm : String
    }


init : Session -> Maybe String -> ( Model, Cmd Msg )
init session maybeToken =
    let
        model =
            { session = session, token = maybeToken, credential = NotAsked, startReset = NotAsked, formErrors = [], form = { email = "", newPassword = "", newPasswordConfirm = "" } }
    in
    case Session.credential session of
        Nothing ->
            ( model, Cmd.none )

        Just _ ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Classrooms )



-- UPDATE


type Msg
    = EmailChanged String
    | NewPasswordChanged String
    | NewPasswordConfirmChanged String
    | StartResetClicked
    | FinishResetClicked String
    | GotStartResetResponse (APIData ())
    | GotFinishResetResponse (APIData Credential)
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmailChanged email ->
            updateForm (\form -> { form | email = email }) model

        NewPasswordChanged pass ->
            updateForm (\form -> { form | newPassword = pass }) model

        NewPasswordConfirmChanged pass ->
            updateForm (\form -> { form | newPasswordConfirm = pass }) model

        StartResetClicked ->
            case validate validator model.form of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    ( { model | formErrors = [], credential = Loading }
                    , Auth.startPasswordReset form.email GotStartResetResponse
                    )

                Err errors ->
                    ( { model | formErrors = errors }
                    , Cmd.none
                    )

        FinishResetClicked token ->
            case validate validator model.form of
                Ok validated ->
                    let
                        form =
                            Validate.fromValid validated
                    in
                    ( { model | formErrors = [], credential = Loading }
                    , Auth.finishPasswordReset token form.newPassword GotFinishResetResponse
                    )

                Err errors ->
                    ( { model | formErrors = errors }
                    , Cmd.none
                    )

        GotStartResetResponse res ->
            ( { model | startReset = res }, Cmd.none )

        GotFinishResetResponse res ->
            case res of
                Success cred ->
                    ( { model | credential = res }, API.storeCred cred )

                _ ->
                    ( { model | credential = res }, Cmd.none )

        GotSession session ->
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
    { title = "Reset Password"
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
                    Input.email [ Input.id "email", Input.onInput EmailChanged, Input.placeholder "Email Address" ]

                else
                    Input.email [ Input.id "email", Input.danger, Input.onInput EmailChanged, Input.placeholder "Email Address" ]

            newPassword =
                if not <| List.any (\( f, m ) -> f == NewPassword) model.formErrors then
                    Input.password [ Input.id "newPassword", Input.onInput NewPasswordChanged, Input.placeholder "New Password" ]

                else
                    Input.password [ Input.id "newPassword", Input.danger, Input.onInput NewPasswordChanged, Input.placeholder "New Password" ]

            newPasswordConfirm =
                if not <| List.any (\( f, m ) -> f == NewPasswordConfirm) model.formErrors then
                    Input.password [ Input.id "newPasswordConfirm", Input.onInput NewPasswordConfirmChanged, Input.placeholder "Confirm New Password" ]

                else
                    Input.password [ Input.id "newPasswordConfirm", Input.danger, Input.onInput NewPasswordConfirmChanged, Input.placeholder "Confirm New Password" ]

            startResetInner =
                case model.startReset of
                    Success _ ->
                        div [ class "text-center py-6" ] [ Common.icon Successful "checkbox" ]

                    Loading ->
                        Common.loading

                    _ ->
                        Form.form [ class "form-signin" ]
                            [ img [ class "mb-4", src "../static/images/physics.png", width 100, height 100 ] []
                            , h3 [ class "h3 mb-3 font-weight-normal" ] [ text "Please enter your email address" ]
                            , h5 [ class "h5 mb-3 font-weight-normal" ] [ text "Password reset instructions will be sent to the provided address." ]
                            , Form.label [ for "email", class "sr-only" ] [ text "Email Address" ]
                            , email
                            , feedback Email
                            , Button.button [ Button.primary, Button.large, Button.block, Button.onClick StartResetClicked ] [ text "Start Reset" ]
                            ]

            finishResetInner token =
                case model.credential of
                    Success _ ->
                        div [ class "text-center py-6" ] [ Common.icon Successful "checkbox" ]

                    Loading ->
                        Common.loading

                    _ ->
                        Form.form [ class "form-signin" ]
                            [ img [ class "mb-4", src "../static/images/physics.png", width 100, height 100 ] []
                            , h3 [ class "h3 mb-3 font-weight-normal" ] [ text "Please enter your new password" ]
                            , Form.label [ for "newPassword", class "sr-only" ] [ text "Password" ]
                            , newPassword
                            , feedback NewPassword
                            , Form.label [ for "newPasswordConfirm", class "sr-only" ] [ text "Confirm Password" ]
                            , newPasswordConfirm
                            , feedback NewPasswordConfirm
                            , Button.button [ Button.primary, Button.large, Button.block, Button.onClick (FinishResetClicked token) ] [ text "Change Password" ]
                            ]

            inner =
                case model.token of
                    Just token ->
                        finishResetInner token

                    Nothing ->
                        startResetInner
        in
        div [ class "text-center login-container" ]
            [ inner ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- FORM


type Field
    = Email
    | NewPassword
    | NewPasswordConfirm


validator : Validator ( Field, String ) Form
validator =
    Validate.all
        [ Validate.firstError
            [ ifBlank .email ( Email, "Please enter your email" )
            , ifInvalidEmail .email (\email -> ( Email, email ++ " is not a valid email address" ))
            ]
        , ifBlank .newPassword ( NewPassword, "Please enter your password" )
        , ifBlank .newPasswordConfirm ( NewPasswordConfirm, "Please enter your password again" )
        , ifFalse (\form -> form.newPassword == form.newPasswordConfirm) ( NewPasswordConfirm, "New password confirmation much match password" )
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
