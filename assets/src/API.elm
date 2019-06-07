module API exposing (Schema)
import Time as Time

type alias Schema s =
    { s | id : Int
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix }
