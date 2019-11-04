module Routes exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Route as Route exposing (Route(..))
import Test exposing (..)
import Types exposing (CategoryId(..), ClassroomId(..), DraftId(..), ExplanationId(..), FeedbackId(..), ObservationId(..), RotationGroupId(..), RotationId(..), SectionId(..), SemesterId(..), UserId(..))
import Url


suite : Test
suite =
    describe "The Route module"
        [ test "routes can be converted to string and then parsed back in as the same route" <|
            \_ ->
                let
                    routes =
                        [ Dashboard

                        -- Authentication
                        , Login
                        , Logout
                        , ResetPassword Nothing
                        , ResetPassword <| Just "token"

                        -- Classrooms
                        , Classrooms
                        , Classroom <| ClassroomId 1

                        -- Semesters
                        , Semesters
                        , Semester <| SemesterId 1

                        -- Sections
                        , Sections Nothing Nothing
                        , Sections Nothing (Just <| SemesterId 1)
                        , Sections (Just <| ClassroomId 1) Nothing
                        , Sections (Just <| ClassroomId 1) (Just <| SemesterId 1)
                        , Section <| SectionId 1

                        -- Rotations
                        , Rotations Nothing
                        , Rotations <| Just <| SectionId 1
                        , Rotation <| RotationId 1

                        -- Rotation Groups
                        , RotationGroups Nothing
                        , RotationGroups <| Just <| RotationId 1
                        , RotationGroup <| RotationGroupId 1

                        -- Categories
                        , Categories Nothing
                        , Categories <| Just <| CategoryId 1
                        , Category <| CategoryId 1

                        -- Observations
                        , Observations Nothing
                        , Observations <| Just <| CategoryId 1
                        , Observation <| ObservationId 1

                        -- Feedback
                        , Feedback Nothing
                        , Feedback <| Just <| ObservationId 1
                        , FeedbackItem <| FeedbackId 1

                        -- Explanations
                        , Explanations Nothing
                        , Explanations <| Just <| FeedbackId 1
                        , Explanation <| ExplanationId 1

                        -- Users
                        , Users
                        , User <| UserId 1

                        -- Feedback
                        , DraftClassrooms
                        , DraftRotations (SectionId 1)
                        , EditFeedback (DraftId 1) (Just <| CategoryId 1)
                        , EditFeedback (DraftId 1) Nothing
                        , Draft (RotationGroupId 1) (DraftId 1)

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
