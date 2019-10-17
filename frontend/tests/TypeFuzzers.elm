module TypeFuzzers exposing (userFuzzer)

import Fuzz exposing (Fuzzer, andMap, bool, int, list, map, maybe, string)
import FuzzUtils exposing (emailFuzzer, fuzzFromList, nameFuzzer, nothing, posixFuzzer, surnameFuzzer)
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
        |> andMap (fuzzFromList [ Admin, Faculty, TeachingAssistant, LearningAssistant, Student ])
        |> andMap (list <| map ClassroomId int)
        |> andMap (list <| map SectionId int)
        |> andMap (list <| map RotationGroupId int)
        |> andMap posixFuzzer
        |> andMap posixFuzzer
