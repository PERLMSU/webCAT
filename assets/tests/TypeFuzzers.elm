module TypeFuzzers exposing (userFuzzer)

import Fuzz exposing (Fuzzer, andMap, bool, int, list, map, maybe, string)
import FuzzUtils exposing (emailFuzzer, nameFuzzer, nothing, posixFuzzer, surnameFuzzer)
import Types exposing (..)


userFuzzer : Fuzzer User
userFuzzer =
    map User (map UserId int)
        |> andMap emailFuzzer
        |> andMap nameFuzzer
        |> andMap (maybe nameFuzzer)
        |> andMap surnameFuzzer
        |> andMap (maybe nameFuzzer)
        |> andMap bool
        |> andMap nothing
        |> andMap nothing
        |> andMap nothing
        |> andMap nothing
        |> andMap posixFuzzer
        |> andMap posixFuzzer
