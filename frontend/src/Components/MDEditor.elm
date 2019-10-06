module Components.Editor exposing (Model, render)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode


type alias Model msg =
    { onInput : String -> msg
    , content : String
    }


render : Model msg -> Html msg
render model =
    Html.node "markdown-editor"
        [ Attributes.property "content" <| Encode.string model.content
        , Events.on "contentChanged" <| Decode.map model.onInput <| Decode.at [ "target", "content" ] <| Decode.string
        ]
        []
