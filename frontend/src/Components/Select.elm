module Components.Select exposing (Model, view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode



---- MODEL


type alias Model a msg =
    { id : String
    , selection : Maybe a
    , options : List a
    , onSelectionChanged : Maybe a -> msg
    , render : a -> String
    , decoder : Decode.Decoder a
    }


view : Model a msg -> Html msg
view model =
    Html.node "selectize-single"
        [ Attributes.id model.id
        , Attributes.property "options" <| Encode.list (model.render >> Encode.string) model.options
        , Attributes.property "selected" <| encodeMaybe (model.render >> Encode.string) model.selection
        , Events.on "selectionChanged" <| Decode.map model.onSelectionChanged <| Decode.at [ "target", "content" ] <| Decode.nullable model.decoder
        ]
        []


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe toValue maybe =
    case maybe of
        Nothing ->
            Encode.null

        Just a ->
            toValue a
