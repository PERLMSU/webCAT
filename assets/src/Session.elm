module Session exposing (Session, changes, credential, fromCredential, navKey)

import API exposing (Credential)
import API.Auth exposing (Token)
import Browser.Navigation as Nav
import Types exposing (User)



-- Types


type Session
    = Authenticated Nav.Key Credential
    | Unauthenticated Nav.Key



-- Utility functions


navKey : Session -> Nav.Key
navKey session =
    case session of
        Authenticated key _ ->
            key

        Unauthenticated key ->
            key


credential : Session -> Maybe Credential
credential session =
    case session of
        Authenticated _ cred ->
            Just cred

        Unauthenticated _ ->
            Nothing


fromCredential : Nav.Key -> Maybe Credential -> Session
fromCredential key maybeCred =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    case maybeCred of
        Just cred ->
            Authenticated key cred

        Nothing ->
            Unauthenticated key


changes : (Session -> msg) -> Nav.Key -> Sub msg
changes toMsg key =
    API.credChanges (\maybeCred -> toMsg (fromCredential key maybeCred))


