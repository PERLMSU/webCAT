module Session exposing (Session, navKey, user, token)

import API.Accounts exposing (User)
import API.Auth exposing (Token)
import Browser.Navigation as Nav



-- Types


type Session
    = Authenticated Nav.Key User Token
    | Unauthenticated Nav.Key



-- Utility functions


navKey : Session -> Nav.Key
navKey session =
    case session of
        Authenticated key _ _ ->
            key

        Unauthenticated key ->
            key

                
user : Session -> Maybe User
user session =
    case session of
        Authenticated _ user _ ->
            Just user
        Unauthenticated _ ->
            Nothing

token : Session -> Maybe Token
token session =
    case session of
        Authenticated _ _ token ->
            Just token
        Unauthenticated _ ->
            Nothing
