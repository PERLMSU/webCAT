module Components.Select exposing (Model, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Json.Decode.Extra exposing (parseInt)


---- MODEL


type alias Model a id msg =
    { id : String
    , itemId : a -> id
    , unwrapId : id -> Int
    , toItemId : Int -> id
    , selection : Maybe a
    , options : List a
    , onSelectionChanged : Maybe id -> msg
    , render : a -> String
    }


view : Model a id msg -> Html msg
view model =
    let
        encode val = Encode.object [ ("content", (model.render >> Encode.string) val )
                                   , ("id", (model.itemId >> model.unwrapId >> Encode.int) val)]
    in
    Html.node "selectize-single"
        [ Attributes.id model.id
        , Attributes.property "options" <| Encode.list encode model.options
        , Attributes.property "selected" <| encodeMaybe encode model.selection
        , Events.on "selectionChanged" <| Decode.map model.onSelectionChanged  <| Decode.at [ "target", "selected" ] <| Decode.nullable (Decode.map model.toItemId parseInt)
        ]
        []

encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe toValue maybe =
    case maybe of
        Nothing ->
            Encode.null

        Just a ->
            toValue a
