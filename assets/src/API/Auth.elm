module API.Auth exposing (login, Token)

import API exposing (post)
import API.Endpoint as Endpoint
import Http exposing (jsonBody)
import Json.Decode as D exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E
import String
import Url.Builder


type alias Token =
    { token : String }



-- DECODER


tokenDecoder : Decoder Token
tokenDecoder =
    D.succeed Token
        |> required "token" string



-- ENCODER


encodeLogin : String -> String -> E.Value
encodeLogin email password =
    E.object
        [ ( "email", E.string email )
        , ( "password", E.string password )
        ]


login : String -> String -> (Result API.Error Token -> msg) -> Cmd msg
login email password toMsg =
    post Endpoint.login Nothing (jsonBody (encodeLogin email password)) tokenDecoder toMsg
