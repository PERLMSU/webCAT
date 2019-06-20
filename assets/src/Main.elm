module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Url

-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { email : String
    , password : String
    }


init : () -> ( Model, Cmd Msg )
init flags =
    ( Model "" "", Cmd.none )



-- UPDATE


type Msg
    = EmailChanged String
    | PasswordChanged String
    | SignIn
    | ForgotPassword
    | Loading
    | Response (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmailChanged email ->
            ( { model | email = email }, Cmd.none )

        PasswordChanged pass ->
            ( { model | password = pass }, Cmd.none )

        SignIn ->
            (model, Cmd.none)

        ForgotPassword ->
            (model, Cmd.none)

        Loading ->
            (model, Cmd.none)

        Response _ ->
            (model, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "WebCAT - Login"
    , body =
        [ div [ class "flex justify-center bg-grey-lighter py-32" ]
            [ div [ class "w-full h-screen max-w-xs" ]
                [ Html.form [ class "bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4" ]
                    [ div [ class "mb-4" ]
                        [ labelView "Email" "email"
                        , input [ class "shadow appearance-none border rounded w-full py-2 px-3 text-grey-darker leading-tight focus:outline-none focus:shadow-outline", id "email", placeholder "Email", type_ "text" ]
                            [ text model.email ]
                        ]
                    , div [ class "mb-6" ]
                        [ labelView "Password" "password"
                        , input [ class "shadow appearance-none border rounded w-full py-2 px-3 text-grey-darker mb-3 leading-tight focus:outline-none focus:shadow-outline", id "password", placeholder "************", type_ "password" ]
                            [ text model.password ]
                        ]
                    , div [ class "flex items-center justify-between" ]
                        [ primaryButton SignIn "Sign In"
                        , tertiaryButton ForgotPassword "Forgot Password"
                        ]
                    ]
                ]
            ]
        ]
    }


labelView : String -> String -> Html msg
labelView content for =
    label [ class "block text-grey-darker text-sm font-bold mb-2", Html.Attributes.for for ]
        [ text content ]


textInput : (String -> Msg) -> String -> String -> Html Msg
textInput toMsg id_ placeholder_ =
    input [ class "shadow appearance-none border rounded w-full py-2 px-3 text-grey-darker mb-3 leading-tight focus:outline-none focus:shadow-outline", id id_, placeholder placeholder_, onInput toMsg ] [text ""]


primaryButton : Msg -> String -> Html Msg
primaryButton toMsg content =
    button [ class "bg-blue hover:bg-blue-dark text-white py-2 px-4 rounded focus:outline-none focus:shadow-outline", type_ "button", onClick toMsg ] [ text content ]


tertiaryButton : Msg -> String -> Html Msg
tertiaryButton toMsg content =
    button [ class "text-gray", type_ "button", onClick toMsg ] [ text content ]
