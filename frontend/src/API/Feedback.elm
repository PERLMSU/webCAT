module API.Feedback exposing (..)

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


categories : Session -> Maybe CategoryId -> (APIData (List Category) -> msg) -> Cmd msg
categories session maybeParentCategoryId toMsg =
    API.getRemote (Endpoint.categories maybeParentCategoryId) (Session.credential session) (multiDecoder categoryDecoder) toMsg


category : Session -> CategoryId -> (APIData Category -> msg) -> Cmd msg
category session categoryId toMsg =
    API.getRemote (Endpoint.category categoryId) (Session.credential session) (singleDecoder categoryDecoder) toMsg


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


updateCategory : Session -> CategoryId -> CategoryForm -> (APIData Category -> msg) -> Cmd msg
updateCategory session id form toMsg =
    API.putRemote (Endpoint.category id) (Session.credential session) (jsonBody <| encodeCategoryForm form) categoryDecoder toMsg


createCategory : Session -> CategoryForm -> (APIData Category -> msg) -> Cmd msg
createCategory session form toMsg =
    API.postRemote (Endpoint.categories Nothing) (Session.credential session) (jsonBody <| encodeCategoryForm form) categoryDecoder toMsg


deleteCategory : Session -> CategoryId -> (APIData () -> msg) -> Cmd msg
deleteCategory session id toMsg =
    API.deleteRemote (Endpoint.category id) (Session.credential session) toMsg

-- Observations


observations : Session -> Maybe CategoryId -> (APIData (List Observation) -> msg) -> Cmd msg
observations session maybeCategoryId toMsg =
    API.getRemote (Endpoint.observations maybeCategoryId) (Session.credential session) (multiDecoder observationDecoder) toMsg

-- Feedback


-- Explanations


-- Student Feedback


studentFeedback : Session -> DraftId -> (APIData (List StudentFeedback) -> msg) -> Cmd msg
studentFeedback session draftId toMsg =
    API.getRemote (Endpoint.studentFeedback (Just draftId) Nothing) (Session.credential session) (multiDecoder studentFeedbackDecoder) toMsg


createStudentFeedback : Session -> DraftId -> FeedbackId -> (APIResult StudentFeedback -> msg) -> Cmd msg
createStudentFeedback session draftId feedbackId toMsg =
    API.post (Endpoint.studentFeedback (Just draftId) (Just feedbackId)) (Session.credential session) emptyBody (singleDecoder studentFeedbackDecoder) toMsg


deleteStudentFeedback : Session -> StudentFeedbackId -> (APIResult () -> msg) -> Cmd msg
deleteStudentFeedback session id toMsg =
    API.delete (Endpoint.studentFeedbackItem id) (Session.credential session) toMsg


-- Student Explanations

studentExplanations : Session -> DraftId -> Maybe FeedbackId -> (APIData (List StudentExplanation) -> msg) -> Cmd msg
studentExplanations session draftId feedbackId toMsg =
    API.getRemote (Endpoint.studentExplanations (Just draftId) feedbackId Nothing) (Session.credential session) (multiDecoder studentExplanationDecoder) toMsg


createStudentExplanation : Session -> DraftId -> FeedbackId -> ExplanationId -> (APIResult StudentExplanation -> msg) -> Cmd msg
createStudentExplanation session draftId feedbackId explanationId toMsg =
    API.post (Endpoint.studentExplanations (Just draftId) (Just feedbackId) (Just explanationId)) (Session.credential session) emptyBody (singleDecoder studentExplanationDecoder) toMsg


deleteStudentExplanation : Session -> StudentExplanationId -> (APIResult () -> msg) -> Cmd msg
deleteStudentExplanation session id toMsg =
    API.delete (Endpoint.studentExplanation id) (Session.credential session) toMsg
