module RemoteData.Extra exposing (priorityApply, priorityMap)

import RemoteData exposing (RemoteData(..), map, succeed)


{-| Apply a binary function to a remote data,
defaulting to the first piece of data if the second has not been loaded,
otherwise applying the function if other have been loaded.
-}
priorityApply : (a -> a -> a) -> RemoteData e a -> RemoteData e a -> RemoteData e a
priorityApply fun dataA dataB =
    case dataA of
        Success a1 ->
            case dataB of
                Success a2 ->
                    succeed (fun a1 a2)

                Failure _ ->
                    dataB

                _ ->
                    dataA

        _ ->
            dataA


{-| Works like priority apply, but applies a default function to the prioritized data.
-}
priorityMap : (a -> c) -> (a -> b -> c) -> RemoteData e a -> RemoteData e b -> RemoteData e c
priorityMap defaultFun fun dataA dataB =
    case dataA of
        Success a1 ->
            case dataB of
                Success a2 ->
                    succeed (fun a1 a2)

                Failure e ->
                    Failure e

                _ ->
                    map defaultFun dataA

        _ ->
            map defaultFun dataA
