module API.Endpoint exposing (Endpoint, categories, category, classroom, classrooms, feedback, feedbackList, imports, login, observation, observations, password_reset, password_reset_finish, profile, request, rotation, rotation_group, rotation_groups, rotations, section, sections, semester, semesters, user, users)

import Http
import Types exposing (CategoryId, ClassroomId, CommentId, DraftId, ExplanationId, FeedbackId, GradeId, ObservationId, RotationGroupId, RotationId, SectionId, SemesterId, UserId, unwrapCategoryId, unwrapClassroomId, unwrapCommentId, unwrapDraftId, unwrapEmailId, unwrapExplanationId, unwrapFeedbackId, unwrapGradeId, unwrapObservationId, unwrapRoleId, unwrapRotationGroupId, unwrapRotationId, unwrapSectionId, unwrapSemesterId, unwrapUserId)
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
user id =
    url [ "users", String.fromInt <| unwrapUserId id ] []


users : Endpoint
users =
    url [ "users" ] []



-- Classrooms


classroom : ClassroomId -> Endpoint
classroom id =
    url [ "classrooms", String.fromInt <| unwrapClassroomId id ] []


classrooms : Endpoint
classrooms =
    url [ "classrooms" ] []



-- Semesters


semester : SemesterId -> Endpoint
semester id =
    url [ "semesters", String.fromInt <| unwrapSemesterId id ] []


semesters : Endpoint
semesters =
    url [ "semesters" ] []



-- Sections


section : SectionId -> Endpoint
section id =
    url [ "sections", String.fromInt <| unwrapSectionId id ] []


sections : Endpoint
sections =
    url [ "sections" ] []



-- Rotations


rotation : RotationId -> Endpoint
rotation id =
    url [ "rotations", String.fromInt <| unwrapRotationId id ] []


rotations : Endpoint
rotations =
    url [ "rotations" ] []



-- Rotation groups


rotation_group : RotationGroupId -> Endpoint
rotation_group id =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id ] []


rotation_groups : Endpoint
rotation_groups =
    url [ "rotation_groups" ] []



-- Import


imports : Endpoint
imports =
    url [ "imports" ] []



-- Categories


category : CategoryId -> Endpoint
category id =
    url [ "categories", String.fromInt <| unwrapCategoryId id ] []


categories : Endpoint
categories =
    url [ "categories" ] []



-- Observations


observation : ObservationId -> Endpoint
observation id =
    url [ "observations", String.fromInt <| unwrapObservationId id ] []


observations : Endpoint
observations =
    url [ "observations" ] []



-- Feedback


feedback : FeedbackId -> Endpoint
feedback id =
    url [ "feedback", String.fromInt <| unwrapFeedbackId id ] []


feedbackList : Endpoint
feedbackList =
    url [ "feedback" ] []



-- Explanations


explanation : ExplanationId -> Endpoint
explanation id =
    url [ "explanations", String.fromInt <| unwrapExplanationId id ] []


explanations : Endpoint
explanations =
    url [ "explanations" ] []



-- Drafts


draft : DraftId -> Endpoint
draft id =
    url [ "drafts", String.fromInt <| unwrapDraftId id ] []


drafts : Endpoint
drafts =
    url [ "drafts" ] []



-- Drafts/Comments


comment : DraftId -> CommentId -> Endpoint
comment draftId commentId =
    url [ "drafts", String.fromInt <| unwrapDraftId draftId, "comments", String.fromInt <| unwrapCommentId commentId ] []


comments : DraftId -> Endpoint
comments draftId =
    url [ "drafts", String.fromInt <| unwrapDraftId draftId, "comments" ] []



-- Drafts/Grades


grade : DraftId -> GradeId -> Endpoint
grade draftId gradeId =
    url [ "drafts", String.fromInt <| unwrapDraftId draftId, "grades", String.fromInt <| unwrapGradeId gradeId ] []


grades : DraftId -> Endpoint
grades draftId =
    url [ "drafts", String.fromInt <| unwrapDraftId draftId, "grades" ] []



-- Student Feedback


studentFeedback : RotationGroupId -> Maybe UserId -> Endpoint
studentFeedback id maybeUserId =
    let
        queryParams =
            case maybeUserId of
                Just userId ->
                    [ string "userId" (String.fromInt <| unwrapUserId userId) ]

                _ ->
                    []
    in
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id, "feedback" ] queryParams
