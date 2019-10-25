module API.Endpoint exposing (Endpoint, categories, category, classroom, classrooms, comment, comments, draft, drafts, explanation, explanations, feedback, feedbackItem, grade, grades, href, login, observation, observations, password_reset, password_reset_finish, profile, profilePicture, request, rotation, rotationGroup, rotationGroups, rotations, section, sectionImport, sections, semester, semesters, src, studentExplanation, studentExplanations, studentFeedback, studentFeedbackItem, unwrap, url, user, userProfilePicture, users)

import Html exposing (Attribute)
import Html.Attributes as Attributes
import Http
import Maybe.Extra exposing (toList, values)
import Types exposing (..)
import Url.Builder exposing (QueryParameter, int, string)


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


href : Endpoint -> Attribute msg
href =
    unwrap >> Attributes.href


src : Endpoint -> Attribute msg
src =
    unwrap >> Attributes.src


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    Endpoint <| Url.Builder.absolute ("api" :: paths) queryParams


mediaUrl : List String -> List QueryParameter -> Endpoint
mediaUrl paths queryParams =
    Endpoint <| Url.Builder.absolute ("media" :: paths) queryParams


intFilter : String -> Int -> QueryParameter
intFilter name param =
    int ("filter[" ++ name ++ "]") param


stringFilter : String -> String -> QueryParameter
stringFilter name param =
    string ("filter[" ++ name ++ "]") param



-- ENDPOINTS


profilePicture : UserId -> Endpoint
profilePicture userId =
    mediaUrl [ "profiles", String.fromInt <| unwrapUserId userId ] []


login : Maybe String -> Endpoint
login token =
    url [ "auth", "login" ] <| toList <| Maybe.map (string "token") token


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
    url [ "users", (unwrapUserId >> String.fromInt) id ] []


users : Endpoint
users =
    url [ "users" ] []


userProfilePicture : UserId -> Endpoint
userProfilePicture id =
    url [ "users", (unwrapUserId >> String.fromInt) id, "profile_picture" ] []



-- Classrooms


classroom : ClassroomId -> Endpoint
classroom id =
    url [ "classrooms", (unwrapClassroomId >> String.fromInt) id ] []


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


sections : Maybe ClassroomId -> Maybe SemesterId -> Endpoint
sections classroomId semesterId =
    let
        classroomIdQuery =
            Maybe.map (unwrapClassroomId >> intFilter "classroom_id") classroomId

        semesterIdQuery =
            Maybe.map (unwrapSemesterId >> intFilter "semester_id") semesterId
    in
    url [ "sections" ] <| values [ classroomIdQuery, semesterIdQuery ]


sectionImport : SectionId -> Endpoint
sectionImport id =
    url [ "sections", String.fromInt <| unwrapSectionId id, "import" ] []



-- Rotations


rotation : RotationId -> Endpoint
rotation id =
    url [ "rotations", String.fromInt <| unwrapRotationId id ] []


rotations : Maybe SectionId -> Endpoint
rotations maybeSectionId =
    url [ "rotations" ] <| toList <| Maybe.map (unwrapSectionId >> intFilter "section_id") maybeSectionId



-- Rotation groups


rotationGroup : RotationGroupId -> Endpoint
rotationGroup id =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id ] []


rotationGroups : Maybe RotationId -> Endpoint
rotationGroups maybeRotationId =
    url [ "rotation_groups" ] <| toList <| Maybe.map (unwrapRotationId >> intFilter "rotation_id") maybeRotationId



-- Categories


category : CategoryId -> Endpoint
category id =
    url [ "categories", String.fromInt <| unwrapCategoryId id ] []


categories : Maybe CategoryId -> Endpoint
categories maybeParentCategoryId =
    let
        parentParam =
            Maybe.map (unwrapCategoryId >> intFilter "parent_category_id") maybeParentCategoryId
    in
    url [ "categories" ] <| values [ parentParam ]



-- Observations


observation : ObservationId -> Endpoint
observation id =
    url [ "observations", String.fromInt <| unwrapObservationId id ] []


observations : Maybe CategoryId -> Endpoint
observations maybeCategoryId =
    url [ "observations" ] <| toList <| Maybe.map (unwrapCategoryId >> intFilter "category_id") maybeCategoryId



-- Feedback


feedback : FeedbackId -> Endpoint
feedback id =
    url [ "feedback", String.fromInt <| unwrapFeedbackId id ] []


feedbackItem : Maybe ObservationId -> Endpoint
feedbackItem maybeObservationId =
    url [ "feedback" ] <| toList <| Maybe.map (unwrapObservationId >> intFilter "observation_id") maybeObservationId



-- Explanations


explanation : ExplanationId -> Endpoint
explanation id =
    url [ "explanations", String.fromInt <| unwrapExplanationId id ] []


explanations : Maybe FeedbackId -> Endpoint
explanations maybeFeedbackId =
    url [ "explanations" ] <| toList <| Maybe.map (unwrapFeedbackId >> intFilter "feedback_id") maybeFeedbackId



-- Drafts


draft : DraftId -> Endpoint
draft id =
    url [ "drafts", String.fromInt <| unwrapDraftId id ] []


drafts : Maybe DraftStatus -> Maybe UserId -> Maybe RotationGroupId -> Maybe DraftId -> Endpoint
drafts maybeStatus maybeStudentId maybeRotationGroupId maybeParentDraftId =
    let
        statusParam =
            Maybe.map (draftStatusToString >> stringFilter "status") maybeStatus

        studentParam =
            Maybe.map (unwrapUserId >> intFilter "student_id") maybeStudentId

        groupParam =
            Maybe.map (unwrapRotationGroupId >> intFilter "rotation_group_id") maybeRotationGroupId

        parentParam =
            Maybe.map (unwrapDraftId >> intFilter "parent_draft_id") maybeParentDraftId
    in
    url [ "drafts" ] <| values [ statusParam, studentParam, groupParam, parentParam ]



-- Drafts/Comments


comment : CommentId -> Endpoint
comment id =
    url [ "comments", (unwrapCommentId >> String.fromInt) id ] []


comments : Maybe DraftId -> Endpoint
comments draftId =
    url [ "comments" ] <| toList <| Maybe.map (unwrapDraftId >> intFilter "draft_id") draftId



-- Drafts/Grades


grade : GradeId -> Endpoint
grade gradeId =
    url [ "grades", String.fromInt <| unwrapGradeId gradeId ] []


grades : Maybe DraftId -> Endpoint
grades draftId =
    url [ "drafts" ] <| toList <| Maybe.map (unwrapDraftId >> intFilter "draft_id") draftId



-- Student Feedback


studentFeedbackItem : StudentFeedbackId -> Endpoint
studentFeedbackItem id =
    url [ "student_feedback", String.fromInt <| unwrapStudentFeedbackId id ] []


studentFeedback : Maybe DraftId -> Maybe FeedbackId -> Endpoint
studentFeedback draftId feedbackId =
    let
        draftIdQuery =
            Maybe.map (unwrapDraftId >> intFilter "draft_id") draftId

        feedbackIdQuery =
            Maybe.map (unwrapFeedbackId >> intFilter "feedback_id") feedbackId
    in
    url [ "student_feedback" ] <| values [ draftIdQuery, feedbackIdQuery ]


studentExplanation : StudentExplanationId -> Endpoint
studentExplanation id =
    url [ "student_explanation", String.fromInt <| unwrapStudentExplanationId id ] []


studentExplanations : Maybe DraftId -> Maybe FeedbackId -> Maybe ExplanationId -> Endpoint
studentExplanations draftId feedbackId explanationId =
    let
        draftIdQuery =
            Maybe.map (unwrapDraftId >> intFilter "draft_id") draftId

        feedbackIdQuery =
            Maybe.map (unwrapFeedbackId >> intFilter "feedback_id") feedbackId

        explanationIdQuery =
            Maybe.map (unwrapExplanationId >> intFilter "explanation_id") explanationId
    in
    url [ "student_feedback" ] <| values [ draftIdQuery, feedbackIdQuery, explanationIdQuery ]
