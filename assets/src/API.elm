port module API exposing (Credential(..), application, cacheStorageKey, credentialDecoder, credentialHeader, credentialStorageKey, decode, decodeFromChange, decoderFromCredential, delete, get, logout, onStoreChange, post, put, storageDecoder, storeCache, storeCredWith, viewerChanges)

import API.Endpoint as Endpoint exposing (Endpoint)
import Browser
import Browser.Navigation as Nav
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string)
import Json.Decode.Pipeline as Pipeline exposing (optional, required)
import Json.Encode as Encode
import Types exposing (User, userDecoder, userEncoder)
import Url exposing (Url)



-- A credential holds the current user and JWT token


type Credential
    = Credential User String


credentialHeader : Credential -> Http.Header
credentialHeader (Credential _ token) =
    Http.header "Authorization" ("Bearer " ++ token)


credentialDecoder : Decoder Credential
credentialDecoder =
    Decode.succeed Credential
        |> required "user" userDecoder
        |> required "token" Decode.string



-- PERSISTENCE


decode : Decoder (Credential -> viewer) -> Value -> Result Decode.Error viewer
decode decoder value =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    Decode.decodeValue Decode.string value
        |> Result.andThen (\str -> Decode.decodeString (Decode.field "user" (decoderFromCredential decoder)) str)


port onStoreChange : (Value -> msg) -> Sub msg


viewerChanges : (Maybe viewer -> msg) -> Decoder (Credential -> viewer) -> Sub msg
viewerChanges toMsg decoder =
    onStoreChange (\value -> toMsg (decodeFromChange decoder value))


decodeFromChange : Decoder (Credential -> viewer) -> Value -> Maybe viewer
decodeFromChange viewerDecoder val =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    Decode.decodeValue (storageDecoder viewerDecoder) val
        |> Result.toMaybe


storeCredWith : Credential -> Cmd msg
storeCredWith (Credential user token) =
    let
        json =
            Encode.object
                [ ( "user", userEncoder user )
                , ( "token", Encode.string token )
                ]
    in
    storeCache (Just json)


logout : Cmd msg
logout =
    storeCache Nothing


port storeCache : Maybe Value -> Cmd msg



-- APPLICATION


application :
    Decoder (Credential -> viewer)
    ->
        { init : Maybe viewer -> Url -> Nav.Key -> ( model, Cmd msg )
        , onUrlChange : Url -> msg
        , onUrlRequest : Browser.UrlRequest -> msg
        , subscriptions : model -> Sub msg
        , update : msg -> model -> ( model, Cmd msg )
        , view : model -> Browser.Document msg
        }
    -> Program Value model msg
application viewerDecoder config =
    let
        init flags url navKey =
            let
                maybeViewer =
                    Decode.decodeValue Decode.string flags
                        |> Result.andThen (Decode.decodeString (storageDecoder viewerDecoder))
                        |> Result.toMaybe
            in
            config.init maybeViewer url navKey
    in
    Browser.application
        { init = init
        , onUrlChange = config.onUrlChange
        , onUrlRequest = config.onUrlRequest
        , subscriptions = config.subscriptions
        , update = config.update
        , view = config.view
        }


storageDecoder : Decoder (Credential -> viewer) -> Decoder viewer
storageDecoder viewerDecoder =
    Decode.field "user" (decoderFromCredential viewerDecoder)



-- HTTP


get : Endpoint -> Maybe Credential -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
get url maybeCred decoder toMsg =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson toMsg decoder
        , headers =
            case maybeCred of
                Just cred ->
                    [ credentialHeader cred ]

                Nothing ->
                    []
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


put : Endpoint -> Credential -> Body -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
put url cred body decoder toMsg =
    Endpoint.request
        { method = "PUT"
        , url = url
        , expect = Http.expectJson toMsg decoder
        , headers = [ credentialHeader cred ]
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }


post : Endpoint -> Maybe Credential -> Body -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
post url maybeCred body decoder toMsg =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = Http.expectJson toMsg decoder
        , headers =
            case maybeCred of
                Just cred ->
                    [ credentialHeader cred ]

                Nothing ->
                    []
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }


delete : Endpoint -> Credential -> Body -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
delete url cred body decoder toMsg =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , expect = Http.expectJson toMsg decoder
        , headers = [ credentialHeader cred ]
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }


decoderFromCredential : Decoder (Credential -> a) -> Decoder a
decoderFromCredential decoder =
    Decode.map2 (\fromCred cred -> fromCred cred)
        decoder
        credentialDecoder



-- LOCALSTORAGE KEYS


cacheStorageKey : String
cacheStorageKey =
    "cache"


credentialStorageKey : String
credentialStorageKey =
    "credential"
