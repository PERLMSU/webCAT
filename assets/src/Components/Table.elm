module Components.Table exposing (Config, view)

import Components.Common as Common exposing (Style(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Config a msg =
    { render : a -> List String
    , headers : List String
    , tableClass : String
    , headerClass : String
    , rowClass : String
    , onClick : a -> msg
    , onEdit : a -> msg
    , onDelete : a -> msg
    }


view : Config a msg -> List a -> Html msg
view config items =
    let
        headers =
            tr [] (List.map (\header -> th [ class config.headerClass ] [ text header ]) (config.headers ++ [ "" ]))

        columns item =
            List.map (\i -> td [] [ text i ]) (config.render item)

        buttons item =
            [ div [ class "inline-flex" ]
                [ td [] [ Common.iconButton Info "edit" (config.onEdit item) ]
                , td [] [ Common.iconButton Danger "trash" (config.onDelete item) ]
                ]
            ]

        row item =
            tr [ class config.rowClass, onClick (config.onClick item) ] <| columns item ++ buttons item

        rows =
            List.map row items
    in
    table [ class config.tableClass ]
        [ thead [] [ headers ]
        , tbody [] rows
        ]
