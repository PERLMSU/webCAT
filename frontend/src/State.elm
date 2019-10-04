module Session exposing (Session)

import API.Accounts exposing (User)
import API.Auth exposing (Credential)


type Session
    = Authenticated User Credential
    | Unauthenticated
