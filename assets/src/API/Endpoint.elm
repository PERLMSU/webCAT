module API.Endpoint exposing (Endpoint, categories, category, classroom, classrooms, feedback, feedbackList, imports, login, observation, observations, password_reset, password_reset_finish, profile, rotation, rotation_group, rotation_groups, rotations, section, sections, semester, semesters, user, users, request)

import Http
import Types exposing (CategoryId(..), ClassroomId(..), CommentId(..), DraftId(..), ExplanationId(..), FeedbackId(..), GradeId(..), ObservationId(..), RotationGroupId(..), RotationId(..), SectionId(..), SemesterId(..), UserId(..))
import Url.Builder exposing (QueryParameter, string)


{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { method : String
    , body : Http.Body
    , headers : List Http.Header
    , url : Endpoint
    , expect : Http.Expect a
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Cmd a
request config =
    Http.request
        { method = config.method
        , headers = config.headers
        , url = unwrap config.url
        , body = config.body
        , expect = config.expect
        , timeout = config.timeout
        , tracker = config.tracker
        }



-- TYPES


{-| Get a URL to the WebCAT API.
This is not publicly exposed, because we want to make sure the only way to get one of these URLs is from this module.
-}
type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    Endpoint <| Url.Builder.absolute ("api" :: paths) queryParams



-- ENDPOINTS


login : Endpoint
login =
    url [ "auth", "login" ] []


password_reset : Endpoint
password_reset =
    url [ "auth", "password_reset" ] []


password_reset_finish : Endpoint
password_reset_finish =
    url [ "auth", "password_reset", "finish" ] []



-- Accounts/Profile


profile : Endpoint
profile =
    url [ "user" ] []


user : UserId -> Endpoint
user (UserId id) =
    url [ "users", String.fromInt id ] []


users : Endpoint
users =
    url [ "users" ] []



-- Classrooms


classroom : ClassroomId -> Endpoint
classroom (ClassroomId id) =
    url [ "classrooms", String.fromInt id ] []


classrooms : Endpoint
classrooms =
    url [ "classrooms" ] []



-- Semesters


semester : SemesterId -> Endpoint
semester (SemesterId id) =
    url [ "semesters", String.fromInt id ] []


semesters : Endpoint
semesters =
    url [ "semesters" ] []



-- Sections


section : SectionId -> Endpoint
section (SectionId id) =
    url [ "sections", String.fromInt id ] []


sections : Endpoint
sections =
    url [ "sections" ] []



-- Rotations


rotation : RotationId -> Endpoint
rotation (RotationId id) =
    url [ "rotations", String.fromInt id ] []


rotations : Endpoint
rotations =
    url [ "rotations" ] []



-- Rotation groups


rotation_group : RotationGroupId -> Endpoint
rotation_group (RotationGroupId id) =
    url [ "rotation_groups", String.fromInt id ] []


rotation_groups : Endpoint
rotation_groups =
    url [ "rotation_groups" ] []



-- Import


imports : Endpoint
imports =
    url [ "imports" ] []



-- Categories


category : CategoryId -> Endpoint
category (CategoryId id) =
    url [ "categories", String.fromInt id ] []


categories : Endpoint
categories =
    url [ "categories" ] []



-- Observations


observation : ObservationId -> Endpoint
observation (ObservationId id) =
    url [ "observations", String.fromInt id ] []


observations : Endpoint
observations =
    url [ "observations" ] []



-- Feedback


feedback : FeedbackId -> Endpoint
feedback (FeedbackId id) =
    url [ "feedback", String.fromInt id ] []


feedbackList : Endpoint
feedbackList =
    url [ "feedback" ] []



-- Explanations


explanation : ExplanationId -> Endpoint
explanation (ExplanationId id) =
    url [ "explanations", String.fromInt id ] []


explanations : Endpoint
explanations =
    url [ "explanations" ] []



-- Drafts


draft : DraftId -> Endpoint
draft (DraftId id) =
    url [ "drafts", String.fromInt id ] []


drafts : Endpoint
drafts =
    url [ "drafts" ] []



-- Drafts/Comments


comment : DraftId -> CommentId -> Endpoint
comment (DraftId draftId) (CommentId commentId) =
    url [ "drafts", String.fromInt draftId, "comments", String.fromInt commentId ] []


comments : DraftId -> Endpoint
comments (DraftId draftId) =
    url [ "drafts", String.fromInt draftId, "comments" ] []



-- Drafts/Grades


grade : DraftId -> GradeId -> Endpoint
grade (DraftId draftId) (GradeId gradeId) =
    url [ "drafts", String.fromInt draftId, "grades", String.fromInt gradeId ] []


grades : DraftId -> Endpoint
grades (DraftId draftId) =
    url [ "drafts", String.fromInt draftId, "grades" ] []



-- Student Feedback


studentFeedback : RotationGroupId -> Maybe UserId -> Endpoint
studentFeedback (RotationGroupId id) maybeUserId =
    let
        queryParams =
            case maybeUserId of
                Just (UserId userId) ->
                    [ string "userId" (String.fromInt userId) ]

                _ ->
                    []
    in
    url [ "rotation_groups", String.fromInt id, "feedback" ] queryParams
