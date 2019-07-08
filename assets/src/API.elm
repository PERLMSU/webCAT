port module API exposing (Credential, Error(..), application, credChanges, credentialDecoder, credentialHeader, credentialUser, decode, decoderFromCredential, delete, get, logout, onStoreChange, post, put, storageDecoder, storeCache, storeCred)

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


credentialUser : Credential -> User
credentialUser (Credential user _) =
    user


credentialHeader : Credential -> Http.Header
credentialHeader (Credential _ token) =
    Http.header "Authorization" ("Bearer " ++ token)


credentialDecoder : Decoder Credential
credentialDecoder =
    Decode.succeed Credential
        |> required "user" userDecoder
        |> required "token" Decode.string



-- The API can error out


type Error
    = BadRequest String
    | Unauthorized String
    | Forbidden String
    | NotFound String
    | ServerError String
      -- Errors that occur because of the transport mechanism
    | BadUrl String
    | Timeout String
    | NetworkError String
    | BadBody String



-- PERSISTENCE


decode : Decoder (Credential -> viewer) -> Value -> Result Decode.Error viewer
decode decoder value =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    Decode.decodeValue Decode.string value
        |> Result.andThen (\str -> Decode.decodeString (Decode.field "user" (decoderFromCredential decoder)) str)


port onStoreChange : (Value -> msg) -> Sub msg


credChanges : (Maybe Credential -> msg) -> Sub msg
credChanges toMsg =
    onStoreChange (\value -> toMsg (Decode.decodeValue Decode.string value |> Result.andThen (\str -> Decode.decodeString credentialDecoder str) |> Result.toMaybe))


storeCred : Credential -> Cmd msg
storeCred (Credential user token) =
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
    { init : Maybe Credential -> Url -> Nav.Key -> ( model, Cmd msg )
    , onUrlChange : Url -> msg
    , onUrlRequest : Browser.UrlRequest -> msg
    , subscriptions : model -> Sub msg
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Browser.Document msg
    }
    -> Program Value model msg
application config =
    let
        init flags url navKey =
            let
                maybeCred =
                    Decode.decodeValue Decode.string flags
                        |> Result.andThen (Decode.decodeString credentialDecoder)
                        |> Result.toMaybe
            in
            config.init maybeCred url navKey
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


get : Endpoint -> Maybe Credential -> Decoder a -> (Result Error a -> msg) -> Cmd msg
get url maybeCred decoder toMsg =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = expectJson toMsg decoder
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


put : Endpoint -> Credential -> Body -> Decoder a -> (Result Error a -> msg) -> Cmd msg
put url cred body decoder toMsg =
    Endpoint.request
        { method = "PUT"
        , url = url
        , expect = expectJson toMsg decoder
        , headers = [ credentialHeader cred ]
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }


post : Endpoint -> Maybe Credential -> Body -> Decoder a -> (Result Error a -> msg) -> Cmd msg
post url maybeCred body decoder toMsg =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = expectJson toMsg decoder
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


delete : Endpoint -> Credential -> Body -> Decoder a -> (Result Error a -> msg) -> Cmd msg
delete url cred body decoder toMsg =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , expect = expectJson toMsg decoder
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


expectJson : (Result Error a -> msg) -> Decoder a -> Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (BadUrl ("Problem with url: " ++ url))

                Http.Timeout_ ->
                    Err (Timeout "Request timed out")

                Http.NetworkError_ ->
                    Err (NetworkError "Network error")

                Http.BadStatus_ metadata body ->
                    case metadata.statusCode of
                        400 ->
                            Err (decodeErrorString BadRequest body)

                        401 ->
                            Err (decodeErrorString Unauthorized body)

                        403 ->
                            Err (decodeErrorString Forbidden body)

                        404 ->
                            Err (decodeErrorString NotFound body)

                        _ ->
                            Err (decodeErrorString ServerError body)

                Http.GoodStatus_ _ body ->
                    case decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (BadBody (Decode.errorToString err))



-- ERRORS


decodeErrorString : (String -> a) -> String -> a
decodeErrorString error str =
    case decodeString errorDecoder str of
        Ok errorMsg ->
            error errorMsg

        Err decodeError ->
            error ("Problem decoding error message: " ++ Decode.errorToString decodeError)


errorDecoder : Decoder String
errorDecoder =
    field "error" string
