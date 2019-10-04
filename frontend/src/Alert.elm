module Alert exposing (Alert(..), dismiss, fromAPIError, render)

import API
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra exposing (remove)


type Alert
    = Info String String
    | Success String String
    | Warning String String
    | Danger String String


dismiss : Alert -> List Alert -> List Alert
dismiss alert alerts =
    remove alert alerts


fromAPIError : API.Error -> Alert
fromAPIError error =
    let
        { title, message } =
            API.getErrorBody error
    in
    Danger title <| Maybe.withDefault "" message


render : (Alert -> msg) -> Alert -> Html msg
render toMsg alert =
    let
        classes =
            List.map (\c -> ( c, True ))

        title =
            case alert of
                Info t _ ->
                    t

                Success t _ ->
                    t

                Warning t _ ->
                    t

                Danger t _ ->
                    t

        message =
            case alert of
                Info _ m ->
                    m

                Success _ m ->
                    m

                Warning _ m ->
                    m

                Danger _ m ->
                    m

        titleClasses =
            case alert of
                Info _ _ ->
                    [ "text-white", "bg-info" ]

                Success _ _ ->
                    [ "text-black", "bg-success" ]

                Warning _ _ ->
                    [ "text-black", "bg-warning" ]

                Danger _ _ ->
                    [ "text-white", "bg-danger" ]

        messageClasses =
            case alert of
                Info _ _ ->
                    [ "border-info" ]

                Success _ _ ->
                    [ "border-success" ]

                Warning _ _ ->
                    [ "border-warning" ]

                Danger _ _ ->
                    [ "border-danger" ]
    in
    div [ attribute "role" "alert", class "animated fadeInDown fast" ]
        [ div [ classList <| classes <| [ "font-display font-bold rounded-t px-4 py-2 relative" ] ++ titleClasses ]
            [ span [ class "absolute top-0 bottom-0 right-0 px-4 py-3 text-black" ]
                [ i [ class "far fa-times-circle cursor-pointer", onClick (toMsg alert) ] [] ]
            , p [] [ text title ]
            ]
        , div [ classList <| classes <| [ "text-white border border-t-0 rounded-b px-4 py-3" ] ++ messageClasses ] [ p [] [ text message ] ]
        ]
