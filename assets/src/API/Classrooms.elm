module API.Classrooms exposing (Classroom, Rotation, RotationGroup, Section, Semester)

import API exposing (Schema)
import API.Accounts exposing (User)
import API.Feedback exposing (Category)
import Time as Time



-- API Types


type alias Classroom =
    Schema
        { courseCode : String
        , name : String
        , description : Maybe String

        -- Related data
        , semesters : Maybe (List Semester)
        , categories : Maybe (List Category)
        , users : Maybe (List User)
        }


type alias Semester =
    Schema
        { name : String
        , description : Maybe String
        , startDate : Time.Posix
        , endDate : Time.Posix

        -- Foreign keys
        , classroomId : Int

        -- Related data
        , classroom : Maybe Classroom
        , sections : Maybe (List Section)
        , users : Maybe (List User)
        }


type alias Section =
    Schema
        { number : String
        , description : Maybe String

        -- Foreign keys
        , semester_id : Int

        -- Related data
        , semester : Maybe Semester
        , rotations : Maybe (List Rotation)
        , users : Maybe (List User)
        }


type alias Rotation =
    Schema
        { number : Int
        , description : Maybe String
        , startDate : Time.Posix
        , endDate : Time.Posix

        -- Foreign keys
        , sectionId : Int

        -- Related data
        , section : Maybe Section
        , rotationGroups : Maybe (List RotationGroup)
        , users : Maybe (List User)
        }


type alias RotationGroup =
    Schema
        { number : Int
        , description : Maybe String

        -- Foreign keys
        , rotationId : Int

        -- Related data
        , rotation : Maybe Rotation
        , users : Maybe (List User)
        }
