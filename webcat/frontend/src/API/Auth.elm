module API.Auth exposing (finishPasswordReset, login, startPasswordReset)

import API exposing (APIData, Credential, credentialDecoder, postRemote, postRemoteNoContent)
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


encodeFinishPasswordReset : String -> String -> E.Value
encodeFinishPasswordReset token newPassword =
    E.object
        [ ( "token", E.string token )
        , ( "new_password", E.string newPassword )
        ]


encodeStartPasswordReset : String -> E.Value
encodeStartPasswordReset email =
    E.object [ ( "email", E.string email ) ]


login : String -> String -> (APIData Credential -> msg) -> Cmd msg
login email password toMsg =
    postRemote (Endpoint.login Nothing) Nothing (jsonBody (encodeLogin email password)) credentialDecoder toMsg


startPasswordReset : String -> (APIData () -> msg) -> Cmd msg
startPasswordReset email toMsg =
    postRemoteNoContent Endpoint.password_reset Nothing (jsonBody (encodeStartPasswordReset email)) toMsg


finishPasswordReset : String -> String -> (APIData Credential -> msg) -> Cmd msg
finishPasswordReset token newPassword toMsg =
    postRemote Endpoint.password_reset_finish Nothing (jsonBody (encodeFinishPasswordReset token newPassword)) credentialDecoder toMsg
