port module API exposing (..)

import Types exposing (User, userDecoder)
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string)
import Json.Decode.Pipeline as Pipeline exposing (optional, required)













-- A credential holds the current user and JWT token
type Credential = Credential User String

credentialHeader : Credential -> Http.Header
credentialHeader (Credential _ token) = Http.header "Authorization" ("Bearer " ++ token)


credentialDecoder : Decoder Credential
credentialDecoder =
    Decode.succeed Credential
        |> required "user" User.decoder
        |> required "token" Decode.string

-- PERSISTENCE


decode : Decoder (Cred -> viewer) -> Value -> Result Decode.Error viewer
decode decoder value =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    Decode.decodeValue Decode.string value
        |> Result.andThen (\str -> Decode.decodeString (Decode.field "user" (decoderFromCred decoder)) str)


port onStoreChange : (Value -> msg) -> Sub msg


viewerChanges : (Maybe viewer -> msg) -> Decoder (Cred -> viewer) -> Sub msg
viewerChanges toMsg decoder =
    onStoreChange (\value -> toMsg (decodeFromChange decoder value))


decodeFromChange : Decoder (Cred -> viewer) -> Value -> Maybe viewer
decodeFromChange viewerDecoder val =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    Decode.decodeValue (storageDecoder viewerDecoder) val
        |> Result.toMaybe


storeCredWith : Cred -> Avatar -> Cmd msg
storeCredWith (Cred uname token) avatar =
    let
        json =
            Encode.object
                [ ( "user"
                  , Encode.object
                        [ ( "username", Username.encode uname )
                        , ( "token", Encode.string token )
                        , ( "image", Avatar.encode avatar )
                        ]
                  )
                ]
    in
    storeCache (Just json)


logout : Cmd msg
logout =
    storeCache Nothing


port storeCache : Maybe Value -> Cmd msg
-- HTTP


get : Endpoint -> Maybe Cred -> Decoder a -> Http.Request a
get url maybeCred decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson decoder
        , headers =
            case maybeCred of
                Just cred ->
                    [ credHeader cred ]

                Nothing ->
                    []
        , body = Http.emptyBody
        , timeout = Nothing
        , withCredentials = False
        }


put : Endpoint -> Cred -> Body -> Decoder a -> Http.Request a
put url cred body decoder =
    Endpoint.request
        { method = "PUT"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader cred ]
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }


post : Endpoint -> Maybe Cred -> Body -> Decoder a -> Http.Request a
post url maybeCred body decoder =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = Http.expectJson decoder
        , headers =
            case maybeCred of
                Just cred ->
                    [ credHeader cred ]

                Nothing ->
                    []
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }


delete : Endpoint -> Cred -> Body -> Decoder a -> Http.Request a
delete url cred body decoder =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader cred ]
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }



-- LOCALSTORAGE KEYS


cacheStorageKey : String
cacheStorageKey =
    "cache"


credentialStorageKey : String
credentialStorageKey =
    "credential"
