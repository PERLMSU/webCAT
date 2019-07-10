module API.Auth exposing (login)

import API exposing (post, Credential, credentialDecoder)
import API.Endpoint as Endpoint
import Http exposing (jsonBody)
import Json.Decode as D exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E
import String
import Url.Builder


-- ENCODER


encodeLogin : String -> String -> E.Value
encodeLogin email password =
    E.object
        [ ( "email", E.string email )
        , ( "password", E.string password )
        ]


login : String -> String -> (Result API.Error Credential -> msg) -> Cmd msg
login email password toMsg =
    post Endpoint.login Nothing (jsonBody (encodeLogin email password)) credentialDecoder toMsg
