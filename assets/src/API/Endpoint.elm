module API.Endpoint exposing (..)

import Http
import Maybe.Extra exposing (values)
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


userRotationGroups : UserId -> Endpoint
userRotationGroups id =
    url [ "users", String.fromInt <| unwrapUserId id, "rotation_groups" ] []



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


semesters : Maybe ClassroomId -> Endpoint
semesters maybeClassroomId =
    url [ "semesters" ] <| Maybe.Extra.toList <| Maybe.map (unwrapClassroomId >> int "classroom_id") maybeClassroomId



-- Sections


section : SectionId -> Endpoint
section id =
    url [ "sections", String.fromInt <| unwrapSectionId id ] []


sections : Maybe SemesterId -> Endpoint
sections maybeSemesterId =
    url [ "sections" ] <| Maybe.Extra.toList <| Maybe.map (unwrapSemesterId >> int "semester_id") maybeSemesterId


sectionImport : SectionId -> Endpoint
sectionImport id =
    url [ "sections", String.fromInt <| unwrapSectionId id, "import" ] []



-- Rotations


rotation : RotationId -> Endpoint
rotation id =
    url [ "rotations", String.fromInt <| unwrapRotationId id ] []


rotations : Maybe SectionId -> Endpoint
rotations maybeSectionId =
    url [ "rotations" ] <| Maybe.Extra.toList <| Maybe.map (unwrapSectionId >> int "section_id") maybeSectionId



-- Rotation groups


rotationGroup : RotationGroupId -> Endpoint
rotationGroup id =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id ] []


rotationGroups : Maybe RotationId -> Endpoint
rotationGroups maybeRotationId =
    url [ "rotation_groups" ] <| Maybe.Extra.toList <| Maybe.map (unwrapRotationId >> int "rotation_id") maybeRotationId


rotationGroupStudents : RotationGroupId -> Endpoint
rotationGroupStudents id =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id, "students" ] []


rotationGroupClassroom : RotationGroupId -> Endpoint
rotationGroupClassroom id =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id, "classroom" ] []


rotationGroupClassroomCategories : RotationGroupId -> Endpoint
rotationGroupClassroomCategories id =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id, "classroom", "categories" ] []



-- Categories


category : CategoryId -> Endpoint
category id =
    url [ "categories", String.fromInt <| unwrapCategoryId id ] []


categories : Maybe ClassroomId -> Maybe CategoryId -> Endpoint
categories maybeClassroomId maybeParentCategoryId =
    let
        classroomParam =
            Maybe.map (unwrapClassroomId >> int "classroom_id") maybeClassroomId

        parentParam =
            Maybe.map (unwrapCategoryId >> int "parent_category_id") maybeParentCategoryId
    in
    url [ "categories" ] <| values [ classroomParam, parentParam ]



-- Observations


observation : ObservationId -> Endpoint
observation id =
    url [ "observations", String.fromInt <| unwrapObservationId id ] []


observations : Maybe CategoryId -> Endpoint
observations maybeCategoryId =
    url [ "observations" ] <| Maybe.Extra.toList <| Maybe.map (unwrapCategoryId >> int "category_id") maybeCategoryId



-- Feedback


feedback : FeedbackId -> Endpoint
feedback id =
    url [ "feedback", String.fromInt <| unwrapFeedbackId id ] []


feedbackItem : Maybe ObservationId -> Endpoint
feedbackItem maybeObservationId =
    url [ "feedback" ] <| Maybe.Extra.toList <| Maybe.map (unwrapObservationId >> int "observation_id") maybeObservationId



-- Explanations


explanation : ExplanationId -> Endpoint
explanation id =
    url [ "explanations", String.fromInt <| unwrapExplanationId id ] []


explanations : Maybe FeedbackId -> Endpoint
explanations maybeFeedbackId =
    url [ "explanations" ] <| Maybe.Extra.toList <| Maybe.map (unwrapFeedbackId >> int "feedback_id") maybeFeedbackId



-- Drafts


draft : DraftId -> Endpoint
draft id =
    url [ "drafts", String.fromInt <| unwrapDraftId id ] []


drafts : Maybe DraftStatus -> Maybe UserId -> Maybe RotationGroupId -> Endpoint
drafts maybeStatus maybeStudentId maybeRotationGroupId =
    let
        statusParam =
            Maybe.map (draftStatusToString >> string "status") maybeStatus

        studentParam =
            Maybe.map (unwrapUserId >> int "student_id") maybeStudentId

        groupParam =
            Maybe.map (unwrapRotationGroupId >> int "rotation_group_id") maybeRotationGroupId
    in
    url [ "drafts" ] <| values [ statusParam, studentParam, groupParam ]



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


studentFeedback : RotationGroupId -> UserId -> Endpoint
studentFeedback id userId =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id, "feedback", String.fromInt <| unwrapUserId userId ] []


studentFeedbackItem : RotationGroupId -> UserId -> FeedbackId -> Endpoint
studentFeedbackItem id userId feedbackId =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id, "feedback", String.fromInt <| unwrapUserId userId, String.fromInt <| unwrapFeedbackId feedbackId ] []


studentExplanations : RotationGroupId -> UserId -> Endpoint
studentExplanations id userId =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id, "feedback", String.fromInt <| unwrapUserId userId, "explanations" ] []


studentExplanation : RotationGroupId -> UserId -> FeedbackId -> ExplanationId -> Endpoint
studentExplanation id userId feedbackId explanationId =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId id, "feedback", String.fromInt <| unwrapUserId userId, String.fromInt <| unwrapFeedbackId feedbackId, "explanations", String.fromInt <| unwrapExplanationId explanationId ] []


studentFeedbackByCategory : RotationGroupId -> UserId -> Endpoint
studentFeedbackByCategory groupId userId =
    url [ "rotation_groups", String.fromInt <| unwrapRotationGroupId groupId, "feedback", String.fromInt <| unwrapUserId userId, "by_category" ] []
