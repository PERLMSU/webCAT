module TypeFuzzers exposing (userFuzzer, userIdFuzzer, usersFuzzer)

import Fuzz exposing (Fuzzer, bool, int, list, map, maybe, string)
import FuzzUtils exposing (emailFuzzer, nameFuzzer, nothing, posixFuzzer, surnameFuzzer)
import Types exposing (User, UserId(..), Users(..))


userIdFuzzer : Fuzzer UserId
userIdFuzzer =
    map UserId int


userFuzzer : Fuzzer User
userFuzzer =
    map User userIdFuzzer
        |> Fuzz.andMap emailFuzzer
        |> Fuzz.andMap nameFuzzer
        |> Fuzz.andMap (maybe nameFuzzer)
        |> Fuzz.andMap surnameFuzzer
        |> Fuzz.andMap (maybe nameFuzzer)
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
