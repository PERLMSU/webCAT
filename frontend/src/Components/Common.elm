module Components.Common exposing (Style(..), icon, iconButton, loading)

import Bootstrap.Button as Button
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Style
    = Primary
    | Secondary
    | Successful
    | Danger
    | Warning
    | Info


icon : Style -> String -> Html msg
icon style icon_ =
    let
        textColor =
            case style of
                Primary ->
                    "text-primary"

                Secondary ->
                    "text-secondary"

                Info ->
                    "text-info"

                Successful ->
                    "text-success"

                Warning ->
                    "text-warning"

                Danger ->
                    "text-danger"
    in
    i [ class (textColor ++ " far fa-" ++ icon_) ] []


{-| View a clickable icon button. Icons from FontAwesome are used.
-}
iconButton : Style -> String -> msg -> Html msg
iconButton style icon_ toMsg =
    let
        textColor =
            case style of
                Primary ->
                    Button.outlinePrimary

                Secondary ->
                    Button.outlineSecondary

                Info ->
                    Button.outlineInfo

                Successful ->
                    Button.outlineSuccess

                Warning ->
                    Button.outlineWarning

                Danger ->
                    Button.outlineDanger
    in
    Button.button [ textColor, Button.onClick toMsg ]
        [ i [ class ("far fa-" ++ icon_) ] [] ]

{-| View a loading spinner. Only one style for now.
-}
loading : Html msg
loading =
    div [ class "text-center d-block" ] [ i [ class "fa-3x fal fa-atom fa-spin" ] [] ]
