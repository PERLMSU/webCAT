port module API exposing (APIData, APIResult, Credential, Error(..), ErrorBody, application, credChanges, credentialDecoder, credentialHeader, credentialUser, delete, deleteRemote, errorBodyToString, get, getErrorBody, getRemote, handleRemoteError, logout, onStoreChange, post, postRemote, postRemoteNoContent, put, putRemote, storeCred)

import API.Endpoint as Endpoint exposing (Endpoint)
import Browser
import Browser.Navigation as Nav
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, nullable, string)
import Json.Decode.Pipeline as Pipeline exposing (optional, required)
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..))
import Types exposing (User, credUserDecoder, encodeUser, userDecoder)
import Url exposing (Url)



-- A credential holds the current user and JWT token


type Credential
    = Credential User String


type alias APIData a =
    RemoteData Error a


type alias APIResult a =
    Result Error a


credentialUser : Credential -> User
credentialUser (Credential user _) =
    user


credentialHeader : Credential -> Http.Header
credentialHeader (Credential _ token) =
    Http.header "Authorization" ("Bearer " ++ token)


credentialDecoder : Decoder Credential
credentialDecoder =
    Decode.succeed Credential
        |> required "user" (Decode.field "data" userDecoder)
        |> required "token" Decode.string



-- The API can error out


type Error
    = BadRequest ErrorBody
    | Unauthorized ErrorBody
    | Forbidden ErrorBody
    | NotFound ErrorBody
    | ServerError ErrorBody
      -- Errors that occur because of the transport mechanism
    | BadUrl ErrorBody
    | Timeout ErrorBody
    | NetworkError ErrorBody
    | BadBody ErrorBody


type alias ErrorBody =
    { message : Maybe String
    , status : String
    , title : String
    }



{- Logs out the user if we get an unauthorized error -}


handleRemoteError : APIData a -> model -> Cmd msg -> ( model, Cmd msg )
handleRemoteError data model cmd =
    case data of
        Failure e ->
            case e of
                Unauthorized _ ->
                    ( model, logout )

                _ ->
                    ( model, cmd )

        _ ->
            ( model, cmd )



-- PERSISTENCE


port onStoreChange : (Value -> msg) -> Sub msg


storeCredDecoder : Decoder Credential
storeCredDecoder =
    Decode.succeed Credential
        |> required "user" credUserDecoder
        |> required "token" Decode.string


credChanges : (Maybe Credential -> msg) -> Sub msg
credChanges toMsg =
    onStoreChange (\value -> toMsg (Decode.decodeValue Decode.string value |> Result.andThen (\str -> Decode.decodeString storeCredDecoder str) |> Result.toMaybe))


storeCred : Credential -> Cmd msg
storeCred (Credential user token) =
    let
        json =
            Encode.object
                [ ( "user", encodeUser user )
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
                        |> Result.andThen (Decode.decodeString storeCredDecoder)
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


get : Endpoint -> Maybe Credential -> Decoder a -> (APIResult a -> msg) -> Cmd msg
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


getRemote : Endpoint -> Maybe Credential -> Decoder a -> (APIData a -> msg) -> Cmd msg
getRemote url maybeCred decoder toMsg =
    get url maybeCred decoder (RemoteData.fromResult >> toMsg)


put : Endpoint -> Maybe Credential -> Body -> Decoder a -> (APIResult a -> msg) -> Cmd msg
put url maybeCred body decoder toMsg =
    Endpoint.request
        { method = "PUT"
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


putRemote : Endpoint -> Maybe Credential -> Body -> Decoder a -> (APIData a -> msg) -> Cmd msg
putRemote url maybeCred body decoder toMsg =
    put url maybeCred body decoder (RemoteData.fromResult >> toMsg)


post : Endpoint -> Maybe Credential -> Body -> Decoder a -> (APIResult a -> msg) -> Cmd msg
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


postRemote : Endpoint -> Maybe Credential -> Body -> Decoder a -> (APIData a -> msg) -> Cmd msg
postRemote url maybeCred body decoder toMsg =
    post url maybeCred body decoder (RemoteData.fromResult >> toMsg)


postRemoteNoContent : Endpoint -> Maybe Credential -> Body -> (APIData () -> msg) -> Cmd msg
postRemoteNoContent url maybeCred body toMsg =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = expectNothing (RemoteData.fromResult >> toMsg)
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


delete : Endpoint -> Maybe Credential -> (APIResult () -> msg) -> Cmd msg
delete url maybeCred toMsg =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , expect = expectNothing toMsg
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


deleteRemote : Endpoint -> Maybe Credential -> (APIData () -> msg) -> Cmd msg
deleteRemote url maybeCred toMsg =
    delete url maybeCred (RemoteData.fromResult >> toMsg)


expect : (APIResult String -> APIResult a) -> (APIResult a -> msg) -> Expect msg
expect toSuccess toMsg =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (BadUrl { status = "400", title = "Client Error", message = Just <| "Problem with url: " ++ url })

                Http.Timeout_ ->
                    Err (Timeout { status = "400", title = "Client Error", message = Just "Timed out" })

                Http.NetworkError_ ->
                    Err (NetworkError { status = "400", title = "Client Error", message = Just "Network Error" })

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
                    toSuccess (Ok body)


expectString : (APIResult String -> msg) -> Expect msg
expectString toMsg =
    expect identity toMsg


expectJson : (APIResult a -> msg) -> Decoder a -> Expect msg
expectJson toMsg decoder =
    let
        toSuccess body =
            case decodeString decoder body of
                Ok value ->
                    Ok value

                Err err ->
                    Err (BadBody { status = "500", title = "Unknown Server Error", message = Just <| Decode.errorToString err })
    in
    expect (Result.andThen toSuccess) toMsg


expectNothing : (APIResult () -> msg) -> Expect msg
expectNothing toMsg =
    expect (Result.map <| always ()) toMsg



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


getErrorBody : Error -> ErrorBody
getErrorBody error =
    case error of
        BadUrl body ->
            body

        Timeout body ->
            body

        NetworkError body ->
            body

        BadRequest body ->
            body

        Unauthorized body ->
            body

        Forbidden body ->
            body

        NotFound body ->
            body

        ServerError body ->
            body

        BadBody body ->
            body


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
