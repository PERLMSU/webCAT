port module API exposing (Credential, Error(..), ErrorBody, application, credChanges, credentialDecoder, credentialHeader, credentialUser, delete, errorBodyToString, get, logout, onStoreChange, post, put, storeCred)

import API.Endpoint as Endpoint exposing (Endpoint)
import Browser
import Browser.Navigation as Nav
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, nullable, string)
import Json.Decode.Pipeline as Pipeline exposing (optional, required)
import Json.Encode as Encode
import RemoteData exposing (RemoteData)
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
    = BadRequest ErrorBody
    | Unauthorized ErrorBody
    | Forbidden ErrorBody
    | NotFound ErrorBody
    | ServerError ErrorBody
      -- Errors that occur because of the transport mechanism
    | BadUrl String
    | Timeout String
    | NetworkError String
    | BadBody String


type alias ErrorBody =
    { message : Maybe String
    , status : String
    , title : String
    }



-- PERSISTENCE


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


getRemote : Endpoint -> Maybe Credential -> Decoder a -> (RemoteData Error a -> msg) -> Cmd msg
getRemote url maybeCred decoder toMsg =
    get url maybeCred decoder (RemoteData.fromResult >> toMsg)


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


putRemote : Endpoint -> Credential -> Body -> Decoder a -> (RemoteData Error a -> msg) -> Cmd msg
putRemote url cred body decoder toMsg =
    put url cred body decoder (RemoteData.fromResult >> toMsg)


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


postRemote : Endpoint -> Maybe Credential -> Body -> Decoder a -> (RemoteData Error a -> msg) -> Cmd msg
postRemote url maybeCred body decoder toMsg =
    post url maybeCred body decoder (RemoteData.fromResult >> toMsg)


delete : Endpoint -> Credential -> Decoder a -> (Result Error a -> msg) -> Cmd msg
delete url cred decoder toMsg =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , expect = expectJson toMsg decoder
        , headers = [ credentialHeader cred ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


deleteRemote : Endpoint -> Credential -> Decoder a -> (RemoteData Error a -> msg) -> Cmd msg
deleteRemote url cred decoder toMsg =
    delete url cred decoder (RemoteData.fromResult >> toMsg)


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
                            Err (decodeErrorBody BadRequest body)

                        401 ->
                            Err (decodeErrorBody Unauthorized body)

                        403 ->
                            Err (decodeErrorBody Forbidden body)

                        404 ->
                            Err (decodeErrorBody NotFound body)

                        _ ->
                            Err (decodeErrorBody ServerError body)

                Http.GoodStatus_ _ body ->
                    case decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (BadBody (Decode.errorToString err))



-- ERRORS


decodeErrorBody : (ErrorBody -> a) -> String -> a
decodeErrorBody error str =
    case decodeString (field "error" errorDecoder) str of
        Ok errorMsg ->
            error errorMsg

        Err decodeError ->
            error
                { title = "Problem decoding error message"
                , status = "500"
                , message = Just <| Decode.errorToString decodeError
                }


errorBodyToString : ErrorBody -> String
errorBodyToString { message, status, title } =
    case message of
        Just str ->
            "Error: " ++ str ++ "."

        Nothing ->
            "Error " ++ status ++ ": " ++ title


errorDecoder : Decoder ErrorBody
errorDecoder =
    Decode.succeed ErrorBody
        |> required "message" (nullable string)
        |> required "status" string
        |> required "title" string
