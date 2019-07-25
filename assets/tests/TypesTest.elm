module TypesTest exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode exposing (Value)
import Test exposing (..)
import Time
import TypeFuzzers exposing (userFuzzer)
import Types


suite : Test
suite =
    describe "Types"
        [ fuzz userFuzzer "Can encode and decode data into the same structure" <|
            \user ->
                case (Decode.decodeValue Types.userDecoder <| Types.encodeUser user) |> Result.toMaybe of
                    Just decoded ->
                        Expect.equal user decoded

                    Nothing ->
                        Expect.fail "Failed to decode user"
        ]
