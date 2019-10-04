module FuzzUtils exposing (emailFuzzer, fuzzFromList, fuzzFromList2, fuzzFromList3, nameFuzzer, nothing, posixFuzzer, surnameFuzzer)

import Fuzz exposing (Fuzzer, bool, int, list, map, maybe, string)
import Time



-- Utility functions for building bigger and better fuzzers


fuzzFromList : List a -> Fuzzer a
fuzzFromList list =
    Fuzz.frequency (List.map (\item -> ( 1, Fuzz.constant item )) list)


fuzzFromList2 : (a -> b -> c) -> List a -> List b -> Fuzzer c
fuzzFromList2 toC listA listB =
    let
        fuzzA =
            fuzzFromList listA

        fuzzB =
            fuzzFromList listB
    in
    Fuzz.map2 toC fuzzA fuzzB


fuzzFromList3 : (a -> b -> c -> d) -> List a -> List b -> List c -> Fuzzer d
fuzzFromList3 toD listA listB listC =
    let
        fuzzA =
            fuzzFromList listA

        fuzzB =
            fuzzFromList listB

        fuzzC =
            fuzzFromList listC
    in
    Fuzz.map3 toD fuzzA fuzzB fuzzC



-- Fake data generators


emailFuzzer : Fuzzer String
emailFuzzer =
    let
        usernames =
            [ "user", "dude", "abc" ]

        domains =
            [ "gmail", "yahoo", "hotmail", "outlook" ]

        tlds =
            [ "com", "org", "gov", "edu" ]
    in
    fuzzFromList3 (\username domain tld -> username ++ "@" ++ domain ++ "." ++ tld) usernames domains tlds


nameFuzzer : Fuzzer String
nameFuzzer =
    let
        names =
            [ "Adam", "John" ]
    in
    fuzzFromList names


surnameFuzzer : Fuzzer String
surnameFuzzer =
    let
        names =
            [ "Johnson", "Smith" ]
    in
    fuzzFromList names



-- Fuzz common things


nothing : Fuzzer (Maybe a)
nothing =
    Fuzz.constant Nothing


posixFuzzer : Fuzzer Time.Posix
posixFuzzer =
    map Time.millisToPosix int
