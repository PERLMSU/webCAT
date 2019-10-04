module Components.MDEditor exposing (Config, render)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { onInput : String -> msg
    , placeholder : String
    }


render : Config msg -> String -> Html msg
render config content =
    div [class "mx-4 my-2"]
        [ textarea [ class "bg-transparent p-2 border rounded shadow leading-tight focus:outline-none w-full", onInput config.onInput, placeholder config.placeholder ]
            [ text content ]
        ]
