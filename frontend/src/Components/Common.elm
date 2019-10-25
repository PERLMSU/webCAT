module Components.Common exposing (Style(..), icon, iconButton, iconTooltip, loading)

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


iconTooltip : String -> String -> Html msg
iconTooltip icon_ content =
    i [ class <| "far fa-" ++ icon_, attribute "data-toggle" "tooltip", attribute "data-placement" "top", title content ] []


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
    div [ class "text-center d-block" ] [ div [ class "spinner-border", attribute "role" "status" ] [ span [ class "sr-only" ] [ text "Loading..." ] ] ]
