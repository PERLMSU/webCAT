module Components.Form exposing (label, passwordInput, textInput)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


textInput : String -> field -> List ( field, String ) -> (String -> msg) -> String -> Html msg
textInput name field errors toMsg contents =
    input_
        { type_ = "text"
        , placeholder = ""
        , name = name
        , field = field
        , onInput = toMsg
        , errors = errors
        , contents = contents
        }


passwordInput : String -> field -> List ( field, String ) -> (String -> msg) -> String -> Html msg
passwordInput name field errors toMsg contents =
    input_
        { type_ = "password"
        , placeholder = "************"
        , name = name
        , field = field
        , onInput = toMsg
        , errors = errors
        , contents = contents
        }


label : String -> String -> Html msg
label content for_ =
    Html.label [ class "block text-white font-display text-sm mb-2", for for_ ]
        [ text content ]


type alias Config field msg =
    { type_ : String
    , placeholder : String
    , name : String
    , field : field
    , onInput : String -> msg
    , contents : String
    , errors : List ( field, String )
    }


input_ : Config field msg -> Html msg
input_ config =
    let
        hasError =
            List.any (\( f, m ) -> f == config.field) config.errors

        classes =
            classList
                [ ( "bg-transparent shadow appearance-none border rounded w-full py-2 px-3 text-white mb-3 leading-tight focus:outline-none", True )
                , ( "border-danger", hasError )
                , ( "border-gray-600", not hasError )
                ]

        err =
            List.filterMap
                (\( field, message ) ->
                    if config.field == field then
                        Just <| p [ class "text-danger text-xs italic" ] [ text message ]

                    else
                        Nothing
                )
                config.errors
    in
    div []
        ([ input [ classes, id config.name, placeholder config.placeholder, type_ config.type_, onInput config.onInput, value config.contents ] []
         ]
            ++ err
        )
