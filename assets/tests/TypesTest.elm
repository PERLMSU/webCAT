module TypesTest exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode exposing (Value)
import Test exposing (..)
import Time
import TypeFuzzers exposing (userFuzzer)
import Types


typeTests =
    [ { collection = "Users", fuzzer = userFuzzer, decoder = Types.userDecoder, encoder = Types.userEncoder }
    ]


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
