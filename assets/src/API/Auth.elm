module API.Auth exposing (login)

import Http
import Json.Decode as D
import Json.Encode as E
import String
import Url.Builder
import API exposing (Message, messageDecoder)

-- DECODER

encodeLogin : String -> String -> E.Value
encodeLogin email password =
    E.object
        [ ( "email", E.string email)
        , ( "password", E.string password )
        ]


login : String -> String -> (Result Http.Error Message -> msg) -> Cmd msg
login email password toMsg =
    Http.request
        { body = Http.jsonBody (encodeLogin email password)
        , method = "POST"
        , expect = Http.expectJson toMsg messageDecoder
        , headers = []
        , url = Url.Builder.absolute [ "auth", "login" ] []
        , timeout = Nothing
        , tracker = Nothing
        }
