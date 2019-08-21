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
    div []
        [ textarea [ onInput config.onInput, placeholder config.placeholder ]
            [ text content ]
        ]
