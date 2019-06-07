module API.Accounts exposing (Role, User)

import API exposing (Schema)
import API.Classrooms exposing (Classroom, RotationGroup, Section)
import Time

type alias Role =
    { identifier : String
    , name : String
    }


type alias User =
    Schema
        { email : String
        , firstName : String
        , middleName : Maybe String
        , lastName : String
        , nickname : Maybe String
        , active : Bool

        -- Preferences
        , timezone : Maybe Time.Timezone

        -- Related data
        , roles : Maybe (List Role)
        , classrooms : Maybe (List Classroom)
        , sections : Maybe (List Section)
        , rotationGroups : Maybe (List RotationGroup)
        }
