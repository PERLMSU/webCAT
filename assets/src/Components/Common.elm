module Components.Common exposing (Style(..), dangerButton, subheader, header, icon, iconButton, infoButton, loading, panel, primaryButton, successButton, warningButton)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Style
    = Primary
    | Info
    | Successful
    | Warning
    | Danger


icon : Style -> String -> Html msg
icon style icon_ =
    let
        textColor =
            case style of
                Primary ->
                    "text-primary"

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
                    "text-primary"

                Info ->
                    "text-info"

                Successful ->
                    "text-success"

                Warning ->
                    "text-warning"

                Danger ->
                    "text-danger"
    in
    button [ class ("text-gray-400 font-bold py-2 px-4 rounded inline-flex items-center " ++ textColor), onClick toMsg ]
        [ i [ class ("far fa-" ++ icon_) ] [] ]


primaryButton : String -> msg -> Html msg
primaryButton =
    styledButton Primary


infoButton : String -> msg -> Html msg
infoButton =
    styledButton Info


successButton : String -> msg -> Html msg
successButton =
    styledButton Successful


warningButton : String -> msg -> Html msg
warningButton =
    styledButton Warning


dangerButton : String -> msg -> Html msg
dangerButton =
    styledButton Danger


styledButton : Style -> String -> msg -> Html msg
styledButton style content toMsg =
    let
        styleClass =
            case style of
                Primary ->
                    "text-primary border-primary"

                Info ->
                    "text-info border-info"

                Successful ->
                    "text-success border-success"

                Warning ->
                    "text-warning border-warning"

                Danger ->
                    "text-danger border-danger"
    in
    button [ class ("shadow bg-transparent border text-white py-2 px-4 rounded font-display " ++ styleClass), type_ "button", onClick toMsg ] [ text content ]


{-| View a loading spinner. Only one style for now.
-}
loading : Html msg
loading =
    div [ class "text-gray-400 text-center py-6" ] [ i [ class "fa-2x fas fa-spinner fa-pulse" ] [] ]


panel : List (Html msg) -> Html msg
panel content =
    div [ class "bg-light-slate rounded-sm shadow-md mx-24 my-12 py-2" ] content


header : String -> Html msg
header content =
    h1 [ class "text-4xl text-gray-400 font-display" ] [ text content ]

subheader : String -> Html msg
subheader content =
    h2 [ class "text-xl text-gray-400 font-display" ] [ text content ]
