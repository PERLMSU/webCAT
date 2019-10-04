module Routes exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Route as Route exposing (LoginToken(..), PasswordResetToken(..), Route(..))
import Test exposing (..)
import Types exposing (CategoryId(..), ClassroomId(..), DraftId(..), RotationGroupId(..), RotationId(..), SectionId(..), SemesterId(..), UserId(..))
import Url


suite : Test
suite =
    describe "The Route module"
        [ test "routes can be converted to string and then parsed back in as the same route" <|
            \_ ->
                let
                    routes =
                        [ Dashboard Nothing
                        , Dashboard <| Just <| ClassroomId 1

                        -- Authentication
                        , Login Nothing
                        , Login <| Just <| LoginToken "abc"
                        , Logout
                        , ForgotPassword Nothing
                        , ForgotPassword <| Just <| PasswordResetToken "abc"

                        -- Classrooms
                        , Classrooms
                        , Classroom <| ClassroomId 1
                        , NewClassroom
                        , EditClassroom <| ClassroomId 1

                        -- Semesters
                        , Semesters Nothing
                        , Semesters <| Just <| ClassroomId 1
                        , Semester <| SemesterId 1
                        , NewSemester Nothing
                        , NewSemester <| Just <| ClassroomId 1
                        , EditSemester <| SemesterId 1

                        -- Sections
                        , Sections Nothing
                        , Sections <| Just <| SemesterId 1
                        , Section <| SectionId 1
                        , NewSection Nothing
                        , NewSection <| Just <| SemesterId 1
                        , EditSection <| SectionId 1

                        -- Rotations
                        , Rotations Nothing
                        , Rotations <| Just <| SectionId 1
                        , Rotation <| RotationId 1
                        , NewRotation Nothing
                        , NewRotation <| Just <| SectionId 1
                        , EditRotation <| RotationId 1

                        -- Rotation Groups
                        , RotationGroups Nothing
                        , RotationGroups <| Just <| RotationId 1
                        , RotationGroup <| RotationGroupId 1
                        , NewRotationGroup Nothing
                        , NewRotationGroup <| Just <| RotationId 1
                        , EditRotationGroup <| RotationGroupId 1

                        -- Users
                        , Users
                        , User <| UserId 1
                        , NewUser
                        , EditUser <| UserId 1

                        -- Feedback
                        , DraftClassrooms
                        , DraftRotations (SectionId 1)
                        , EditFeedback (DraftId 1) (Just (CategoryId 1))
                        , EditFeedback (DraftId 1) Nothing
                        , Draft <| DraftId 1

                        -- Profile
                        , Profile

                        -- Utility
                        , Root
                        ]

                    toStrings =
                        List.map (\route -> "https://example.com" ++ route)

                    toUrls =
                        List.filterMap Url.fromString

                    toRoutes =
                        List.filterMap Route.fromUrl
                in
                List.map Route.routeToString routes
                    |> toStrings
                    |> toUrls
                    |> toRoutes
                    |> Expect.equalLists routes
        ]
