module Session exposing (Session, navKey, user, token)

import Types exposing (User)
import API.Auth exposing (Token)
import Browser.Navigation as Nav



-- Types


type Session
    = Authenticated Nav.Key User
    | Unauthenticated Nav.Key


-- Utility functions


navKey : Session -> Nav.Key
navKey session =
    case session of
        Authenticated key _ ->
            key

        Unauthenticated key ->
            key


user : Session -> Maybe User
user session =
    case session of
        Authenticated _ user ->
            Just user
        Unauthenticated _ ->
            Nothing
