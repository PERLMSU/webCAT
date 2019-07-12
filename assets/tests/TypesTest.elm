module TypesTest exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, bool, int, list, map, maybe, string)
import Json.Decode as Decode
import Test exposing (..)
import Time
import Types exposing (User, UserId(..), Users(..))


nothing : Fuzzer (Maybe a)
nothing =
    Fuzz.constant Nothing


posixFuzzer : Fuzzer Time.Posix
posixFuzzer =
    map Time.millisToPosix int


userIdFuzzer : Fuzzer UserId
userIdFuzzer =
    map UserId int


userFuzzer : Fuzzer User
userFuzzer =
    map User userIdFuzzer
        |> Fuzz.andMap string
        |> Fuzz.andMap string
        |> Fuzz.andMap (maybe string)
        |> Fuzz.andMap string
        |> Fuzz.andMap (maybe string)
        |> Fuzz.andMap bool
        |> Fuzz.andMap nothing
        |> Fuzz.andMap nothing
        |> Fuzz.andMap nothing
        |> Fuzz.andMap nothing
        |> Fuzz.andMap posixFuzzer
        |> Fuzz.andMap posixFuzzer


usersFuzzer : Fuzzer Users
usersFuzzer =
    map Users (list userFuzzer)


suite : Test
suite =
    describe "Types"
        [ fuzz userFuzzer "Can encode and decode data into the same structure" <|
            \user ->
                case (Decode.decodeValue Types.userDecoder <| Types.userEncoder user) |> Result.toMaybe of
                    Just decoded ->
                        Expect.equal user decoded

                    Nothing ->
                        Expect.fail "Failed to decode user"
        ]
