module API.Feedback exposing (CategoryForm, addStudentExplanation, addStudentFeedback, categories, category, deleteCategory, deleteStudentExplanation, deleteStudentFeedback, editCategory, encodeCategoryForm, encodeMaybe, feedbackByCategory, formFromCategory, grades, newCategory, observations, rotationGroupClassroomCategories, studentExplanations, studentFeedback)

import API exposing (APIData, APIResult)
import API.Endpoint as Endpoint
import Http exposing (emptyBody, jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Session exposing (Session)
import Time as Time
import Types exposing (..)


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe fn maybe =
    Maybe.withDefault Encode.null <| Maybe.map fn maybe



-- Categories


categories : Session -> Maybe ClassroomId -> Maybe CategoryId -> (APIData (List Category) -> msg) -> Cmd msg
categories session maybeClassroomId maybeParentCategoryId toMsg =
    API.getRemote (Endpoint.categories maybeClassroomId maybeParentCategoryId) (Session.credential session) (Decode.list categoryDecoder) toMsg


category : Session -> CategoryId -> (APIData Category -> msg) -> Cmd msg
category session categoryId toMsg =
    API.getRemote (Endpoint.category categoryId) (Session.credential session) categoryDecoder toMsg


observations : Session -> Maybe CategoryId -> (APIData (List Observation) -> msg) -> Cmd msg
observations session maybeCategoryId toMsg =
    API.getRemote (Endpoint.observations maybeCategoryId) (Session.credential session) (Decode.list observationDecoder) toMsg


type alias CategoryForm =
    { name : String
    , description : String

    -- Related data
    , parentCategoryId : Maybe CategoryId
    , classroomId : ClassroomId
    }


formFromCategory : Category -> CategoryForm
formFromCategory data =
    { name = data.name
    , description = Maybe.withDefault "" data.description

    -- Related data
    , parentCategoryId = data.parentCategoryId
    , classroomId = data.classroomId
    }


encodeCategoryForm : CategoryForm -> Encode.Value
encodeCategoryForm form =
    Encode.object
        [ ( "name", Encode.string form.name )
        , ( "description", Encode.string form.description )
        , ( "parent_category_id", encodeMaybe (unwrapCategoryId >> Encode.int) form.parentCategoryId )
        , ( "classroom_id", (unwrapClassroomId >> Encode.int) form.classroomId )
        ]


editCategory : Session -> CategoryId -> CategoryForm -> (APIData Category -> msg) -> Cmd msg
editCategory session id form toMsg =
    API.putRemote (Endpoint.category id) (Session.credential session) (jsonBody <| encodeCategoryForm form) categoryDecoder toMsg


newCategory : Session -> CategoryForm -> (APIData Category -> msg) -> Cmd msg
newCategory session form toMsg =
    API.postRemote (Endpoint.categories Nothing Nothing) (Session.credential session) (jsonBody <| encodeCategoryForm form) categoryDecoder toMsg


deleteCategory : Session -> CategoryId -> (APIData () -> msg) -> Cmd msg
deleteCategory session id toMsg =
    API.deleteRemote (Endpoint.category id) (Session.credential session) toMsg


studentFeedback : Session -> RotationGroupId -> UserId -> (APIData (List StudentFeedback) -> msg) -> Cmd msg
studentFeedback session groupId userId toMsg =
    API.getRemote (Endpoint.studentFeedback groupId userId) (Session.credential session) (Decode.list studentFeedbackDecoder) toMsg


addStudentFeedback : Session -> RotationGroupId -> UserId -> FeedbackId -> (APIResult StudentFeedback -> msg) -> Cmd msg
addStudentFeedback session groupId userId feedbackId toMsg =
    API.post (Endpoint.studentFeedbackItem groupId userId feedbackId) (Session.credential session) emptyBody studentFeedbackDecoder toMsg


deleteStudentFeedback : Session -> RotationGroupId -> UserId -> FeedbackId -> (APIResult () -> msg) -> Cmd msg
deleteStudentFeedback session groupId userId feedbackId toMsg =
    API.delete (Endpoint.studentFeedbackItem groupId userId feedbackId) (Session.credential session) toMsg


studentExplanations : Session -> RotationGroupId -> UserId -> (APIData (List StudentExplanation) -> msg) -> Cmd msg
studentExplanations session groupId userId toMsg =
    API.getRemote (Endpoint.studentExplanations groupId userId) (Session.credential session) (Decode.list studentExplanationDecoder) toMsg


addStudentExplanation : Session -> RotationGroupId -> UserId -> FeedbackId -> ExplanationId -> (APIResult StudentExplanation -> msg) -> Cmd msg
addStudentExplanation session groupId userId feedbackId explanationId toMsg =
    API.post (Endpoint.studentExplanation groupId userId feedbackId explanationId) (Session.credential session) emptyBody studentExplanationDecoder toMsg


deleteStudentExplanation : Session -> RotationGroupId -> UserId -> FeedbackId -> ExplanationId -> (APIResult () -> msg) -> Cmd msg
deleteStudentExplanation session groupId userId feedbackId explanationId toMsg =
    API.delete (Endpoint.studentExplanation groupId userId feedbackId explanationId) (Session.credential session) toMsg


feedbackByCategory : Session -> RotationGroupId -> UserId -> (APIData (List Category) -> msg) -> Cmd msg
feedbackByCategory session groupId userId toMsg =
    API.getRemote (Endpoint.studentFeedbackByCategory groupId userId) (Session.credential session) (Decode.list categoryDecoder) toMsg


rotationGroupClassroomCategories : Session -> RotationGroupId -> (APIData (List Category) -> msg) -> Cmd msg
rotationGroupClassroomCategories session groupId toMsg =
    API.getRemote (Endpoint.rotationGroupClassroomCategories groupId) (Session.credential session) (Decode.list categoryDecoder) toMsg


grades : Session -> DraftId -> (APIData (List Grade) -> msg) -> Cmd msg
grades session draftId toMsg =
    API.getRemote (Endpoint.grades draftId) (Session.credential session) (Decode.list gradeDecoder) toMsg
