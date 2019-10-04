port module Popup exposing (Popup, popupChanges, sendPopup)

import Json.Decode as Decode exposing (Decoder, Value, bool, decodeValue, field, float, int, lazy, list, map, nullable, string)
import Json.Encode as Encode


type Popup
    = Info String String
    | Success String String
    | Warning String String
    | Danger String String


port putPopup : Value -> Cmd msg


sendPopup : Popup -> Cmd msg
sendPopup popup =
    let
        obj =
            case popup of
                Info title message ->
                    [ ( "type", Encode.string "info" ), ( "title", Encode.string title ), ( "message", Encode.string message ) ]

                Success title message ->
                    [ ( "type", Encode.string "success" ), ( "title", Encode.string title ), ( "message", Encode.string message ) ]

                Warning title message ->
                    [ ( "type", Encode.string "warning" ), ( "title", Encode.string title ), ( "message", Encode.string message ) ]

                Danger title message ->
                    [ ( "type", Encode.string "danger" ), ( "title", Encode.string title ), ( "message", Encode.string message ) ]
    in
    putPopup (Encode.object obj)


port onPutPopup : (Value -> msg) -> Sub msg


popupChanges : (Maybe Popup -> msg) -> Sub msg
popupChanges toMsg =
    let
        decodePopup : Value -> Maybe Popup
        decodePopup value =
            let
                decodePopup_ type_ =
                    case type_ of
                        "success" ->
                            decodeValue (Decode.map2 Success (field "title" string) (field "message" string)) value

                        "warning" ->
                            decodeValue (Decode.map2 Warning (field "title" string) (field "message" string)) value

                        "dancer" ->
                            decodeValue (Decode.map2 Danger (field "title" string) (field "message" string)) value

                        _ ->
                            decodeValue (Decode.map2 Info (field "title" string) (field "message" string)) value
            in
            decodeValue (field "type" string) value
                |> Result.toMaybe
                |> Maybe.andThen (Result.toMaybe << decodePopup_)
    in
    onPutPopup (decodePopup >> toMsg)
