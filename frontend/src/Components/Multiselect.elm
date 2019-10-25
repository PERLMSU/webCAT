module Components.Multiselect exposing ( Model, view )

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
    , selection : List a
    , options : List a
    , onSelectionChanged : List id -> msg
    , render : a -> String
    }


view : Model a id msg -> Html msg
view model =
    let
        encode val = Encode.object [ ("content", (model.render >> Encode.string) val )
                                   , ("id", (model.itemId >> model.unwrapId >> Encode.int) val)
                                   ]
    in
    Html.node "selectize-multi"
        [ Attributes.id model.id
        , Attributes.property "options" <| Encode.list encode model.options
        , Attributes.property "selected" <| Encode.list encode model.selection
        , Events.on "selectionChanged" <| Decode.map model.onSelectionChanged <| loggingDecoder <| Decode.at ["target", "selected"] <| Decode.list (Decode.map model.toItemId parseInt)]
        []

loggingDecoder : Decode.Decoder a -> Decode.Decoder a
loggingDecoder realDecoder =
  Decode.value
    |> Decode.andThen
      (\event ->
        case Decode.decodeValue realDecoder event of
          Ok decoded ->
            Decode.succeed decoded

          Err error ->
            error
              |> Decode.errorToString
              |> Debug.log "decoding error"
              |> Decode.fail
      )

