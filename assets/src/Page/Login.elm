module Page.Login exposing (Form, Model, Msg(..), Problem(..), ValidatedField(..), fieldsToValidate, init, labelView, primaryButton, subscriptions, tertiaryButton, textInput, toSession, update, validate, validateField, view, viewProblem)

import API exposing (Credential, Error(..), ErrorBody)
import API.Auth as Auth
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Route
import Session exposing (Session)
import Url



-- MODEL


type alias Model =
    { session : Session
    , errors : List Problem
    , loading : Bool
    , form : Form
    }


type alias Form =
    { email : String
    , password : String
    }


type Problem
    = InvalidEntry ValidatedField String
    | ServerError String


init : Session -> ( Model, Cmd Msg )
init session =
    let
        model =
            { session = session
            , errors = []
            , loading = False
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
            ( model, Route.replaceUrl (Session.navKey session) (Route.Dashboard Nothing) )



-- UPDATE


type Msg
    = EmailChanged String
    | PasswordChanged String
    | SignIn
    | ForgotPassword
    | Response (Result Error Credential)
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmailChanged email ->
            updateForm (\form -> { form | email = email }) model

        PasswordChanged pass ->
            updateForm (\form -> { form | password = pass }) model

        SignIn ->
            case validate model.form of
                Ok form ->
                    ( { model | errors = [], loading = True }
                    , Auth.login form.email form.password Response
                    )

                Err errors ->
                    ( { model | errors = errors }
                    , Cmd.none
                    )

        ForgotPassword ->
            Debug.todo "forgot password"

        Response (Err error) ->
            let
                serverErrors =
                    case error of
                        BadRequest errBody ->
                            [ ServerError <| API.errorBodyToString errBody ]

                        Unauthorized errBody ->
                            [ ServerError <| API.errorBodyToString errBody ]

                        Forbidden errBody ->
                            [ ServerError <| API.errorBodyToString errBody ]

                        NotFound errBody ->
                            [ ServerError <| API.errorBodyToString errBody ]

                        API.ServerError errBody ->
                            [ ServerError <| API.errorBodyToString errBody ]

                        BadUrl errMsg ->
                            [ ServerError errMsg ]

                        Timeout errMsg ->
                            [ ServerError errMsg ]

                        NetworkError errMsg ->
                            [ ServerError errMsg ]

                        BadBody errMsg ->
                            [ ServerError errMsg ]
            in
            ( { model | errors = List.append model.errors serverErrors, loading = False }
            , Cmd.none
            )

        Response (Ok cred) ->
            ( { model | loading = False }, API.storeCred cred )

        GotSession session ->
            case Session.credential session of
                Nothing ->
                    ( { model | session = session }, Cmd.none )

                Just _ ->
                    ( { model | session = session, errors = [ ServerError "Problem decoding session" ] }, Route.replaceUrl (Session.navKey session) (Route.Dashboard Nothing) )


updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | form = transform model.form }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "WebCAT - Login"
    , content =
        div [ class "flex justify-center bg-grey-lighter py-32" ]
            [ div [ class "w-full h-screen max-w-xs" ]
                [ Html.form [ class "bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4" ]
                    [ ul [ class "error-messages" ]
                        (List.map viewProblem model.errors)
                    , div [ class "mb-4" ]
                        [ labelView "Email" "email"
                        , input [ class "shadow appearance-none border rounded w-full py-2 px-3 text-grey-darker leading-tight focus:outline-none focus:shadow-outline", id "email", placeholder "Email", type_ "text", onInput EmailChanged ]
                            [ text model.form.email ]
                        ]
                    , div [ class "mb-6" ]
                        [ labelView "Password" "password"
                        , input [ class "shadow appearance-none border rounded w-full py-2 px-3 text-grey-darker mb-3 leading-tight focus:outline-none focus:shadow-outline", id "password", placeholder "************", type_ "password", onInput PasswordChanged ]
                            [ text model.form.password ]
                        ]
                    , div [ class "flex items-center justify-between" ]
                        [ primaryButton SignIn "Sign In"
                        , tertiaryButton ForgotPassword "Forgot Password"
                        ]
                    ]
                ]
            ]
    }


viewProblem : Problem -> Html msg
viewProblem problem =
    let
        errorMessage =
            case problem of
                InvalidEntry _ str ->
                    str

                ServerError str ->
                    str
    in
    li [] [ text errorMessage ]


labelView : String -> String -> Html msg
labelView content for =
    label [ class "block text-grey-darker text-sm font-bold mb-2", Html.Attributes.for for ]
        [ text content ]


textInput : (String -> Msg) -> String -> String -> Html Msg
textInput toMsg id_ placeholder_ =
    input [ class "shadow appearance-none border rounded w-full py-2 px-3 text-grey-darker mb-3 leading-tight focus:outline-none focus:shadow-outline", id id_, placeholder placeholder_, onInput toMsg ] [ text "" ]


primaryButton : Msg -> String -> Html Msg
primaryButton toMsg content =
    button [ class "bg-blue hover:bg-blue-dark text-white py-2 px-4 rounded focus:outline-none focus:shadow-outline", type_ "button", onClick toMsg ] [ text content ]


tertiaryButton : Msg -> String -> Html Msg
tertiaryButton toMsg content =
    button [ class "text-gray", type_ "button", onClick toMsg ] [ text content ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- FORM


{-| When adding a variant here, add it to `fieldsToValidate` too!
-}
type ValidatedField
    = Email
    | Password


fieldsToValidate : List ValidatedField
fieldsToValidate =
    [ Email
    , Password
    ]


{-| Trim the form and validate its fields. If there are problems, report them!
-}
validate : Form -> Result (List Problem) Form
validate form =
    let
        trimmedForm =
            { email = String.trim form.email
            , password = String.trim form.password
            }
    in
    case List.concatMap (validateField trimmedForm) fieldsToValidate of
        [] ->
            Ok trimmedForm

        problems ->
            Err problems


validateField : Form -> ValidatedField -> List Problem
validateField form field =
    List.map (InvalidEntry field) <|
        case field of
            Email ->
                if String.isEmpty form.email then
                    [ "email can't be blank." ]

                else
                    []

            Password ->
                if String.isEmpty form.password then
                    [ "password can't be blank." ]

                else
                    []



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
