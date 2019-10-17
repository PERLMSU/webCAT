module Components.Table exposing (Config, view)

import Components.Common as Common exposing (Style(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Bootstrap.Table as Table

type alias Config a msg =
    { render : a -> List String
    , headers : List String
    , onClick : a -> msg
    , onEdit : a -> msg
    , onDelete : a -> msg
    }


view : Config a msg -> List a -> Html msg
view config items =
    let
        headers =
            (List.map (\header -> Table.th [ ] [ text header ]) (config.headers ++ [ "" ]))

        columns item =
            List.map (\i -> Table.td [ Table.cellAttr <| onClick (config.onClick item) ] [ text i ]) (config.render item)

        buttons item =
                [ Table.td [] [ Common.iconButton Info "edit" (config.onEdit item) ]
                , Table.td [] [ Common.iconButton Danger "trash" (config.onDelete item) ]
                ]
            

        row item =
            Table.tr [ ] <| columns item ++ buttons item

        rows =
            List.map row items
    in
    Table.simpleTable 
        ( Table.simpleThead headers
        , Table.tbody [] rows
        )
