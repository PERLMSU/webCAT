module Components.Multiselect exposing ( Model, view )

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode 

---- MODEL


type alias Model a msg =
    { selection : List a
    , options : List a
    , onSelectionChanged : List a -> msg
    , render : a -> String
    , decoder : Decode.Decoder a
    }


view : Model a msg -> Html msg
view model =
    Html.node "selectize-multi"
        [ Attributes.property "options" <| Encode.list (model.render >> Encode.string) model.options
        , Attributes.property "selected" <| Encode.list (model.render >> Encode.string) model.selection
        , Events.on "selectionChanged" <| Decode.map model.onSelectionChanged <| Decode.at ["target", "content"] <| Decode.list model.decoder]
        []
