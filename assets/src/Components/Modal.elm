module Components.Modal exposing (Config, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config msg =
    { onClose : msg
    , title: String
    }


viewTitle : Config msg -> Html msg
viewTitle config =
    div [class "flex justify-between items-center pb-3 text-gray-400"]
        [ p [class "text-2xl font-bold"] [text config.title]
        , div [ class "cursor-pointer z-50", onClick config.onClose ] [ i [ class "fas fa-times" ] [] ]
        ]

view : Config msg -> List (Html msg) -> Html msg
view config content =
    div [ class "animated fadeIn faster absolute w-full h-full top-0 left-0 flex items-center justify-center" ]
        [ div [ onClick config.onClose, class "absolute w-full h-full bg-black opacity-25 top-0 left-0 cursor-pointer" ] []
        , div [ class "animated fadeInDown faster absolute w-1/2 bg-light-slate rounded-sm shadow-lg py-4 px-6" ] <|
            [ viewTitle config
            ]
                ++ content
        ]
