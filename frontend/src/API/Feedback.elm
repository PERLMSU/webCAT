module API.Feedback exposing (CategoryForm, ExplanationForm, FeedbackForm, ObservationForm, categories, category, createCategory, createExplanation, createFeedback, createObservation, createStudentExplanation, createStudentFeedback, deleteCategory, deleteExplanation, deleteFeedback, deleteObservation, deleteStudentExplanation, deleteStudentFeedback, explanations, feedback, getExplanation, getFeedback, getObservation, initCategoryForm, initExplanationForm, initFeedbackForm, initObservationForm, observations, studentExplanations, studentFeedback, updateCategory, updateExplanation, updateFeedback, updateObservation)

import API exposing (APIData, APIResult)
import API.Endpoint as Endpoint
import Either exposing (..)
import Http exposing (emptyBody, jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Session exposing (Session)
import Time as Time
import Types exposing (..)



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
    }


initCategoryForm : Maybe Category -> CategoryForm
initCategoryForm maybeCategory =
    case maybeCategory of
        Just data ->
            { name = data.name
            , description = Maybe.withDefault "" data.description
            , parentCategoryId = data.parentCategoryId
            }

        Nothing ->
            { name = ""
            , description = ""
            , parentCategoryId = Nothing
            }


encodeCategoryForm : CategoryForm -> Encode.Value
encodeCategoryForm form =
    Encode.object
        [ ( "name", Encode.string form.name )
        , ( "description", Encode.string form.description )
        , ( "parent_category_id", encodeMaybe (unwrapCategoryId >> Encode.int) form.parentCategoryId )
        ]


updateCategory : Session -> CategoryId -> CategoryForm -> (APIData Category -> msg) -> Cmd msg
updateCategory session id form toMsg =
    API.putRemote (Endpoint.category id) (Session.credential session) (jsonBody <| encodeCategoryForm form) (singleDecoder categoryDecoder) toMsg


createCategory : Session -> CategoryForm -> (APIData Category -> msg) -> Cmd msg
createCategory session form toMsg =
    API.postRemote (Endpoint.categories Nothing) (Session.credential session) (jsonBody <| encodeCategoryForm form) (singleDecoder categoryDecoder) toMsg


deleteCategory : Session -> CategoryId -> (APIData () -> msg) -> Cmd msg
deleteCategory session id toMsg =
    API.deleteRemote (Endpoint.category id) (Session.credential session) toMsg



-- Observations


type alias ObservationForm =
    { content : String
    , type_ : ObservationType
    , categoryId : CategoryId
    }


initObservationForm : Either Observation CategoryId -> ObservationForm
initObservationForm either =
    case either of
        Left observation ->
            { content = observation.content
            , type_ = observation.type_
            , categoryId = observation.categoryId
            }

        Right id ->
            { content = ""
            , type_ = Neutral
            , categoryId = id
            }


encodeObservationForm : ObservationForm -> Encode.Value
encodeObservationForm form =
    Encode.object
        [ ( "content", Encode.string form.content )
        , ( "type", (observationTypeToString >> Encode.string) form.type_ )
        , ( "categoryId", (unwrapCategoryId >> Encode.int) form.categoryId )
        ]


observations : Session -> Maybe CategoryId -> (APIData (List Observation) -> msg) -> Cmd msg
observations session maybeCategoryId toMsg =
    API.getRemote (Endpoint.observations maybeCategoryId) (Session.credential session) (multiDecoder observationDecoder) toMsg


getObservation : Session -> ObservationId -> (APIData Observation -> msg) -> Cmd msg
getObservation session id toMsg =
    API.getRemote (Endpoint.observation id) (Session.credential session) (singleDecoder observationDecoder) toMsg


createObservation : Session -> ObservationForm -> (APIData Observation -> msg) -> Cmd msg
createObservation session form toMsg =
    API.postRemote (Endpoint.observations Nothing) (Session.credential session) (jsonBody <| encodeObservationForm form) (singleDecoder observationDecoder) toMsg


updateObservation : Session -> ObservationId -> ObservationForm -> (APIData Observation -> msg) -> Cmd msg
updateObservation session id form toMsg =
    API.putRemote (Endpoint.observation id) (Session.credential session) ((encodeObservationForm >> jsonBody) form) (singleDecoder observationDecoder) toMsg


deleteObservation : Session -> ObservationId -> (APIData () -> msg) -> Cmd msg
deleteObservation session id toMsg =
    API.deleteRemote (Endpoint.observation id) (Session.credential session) toMsg



-- Feedback


type alias FeedbackForm =
    { content : String
    , observationId : ObservationId
    }


initFeedbackForm : Either Feedback ObservationId -> FeedbackForm
initFeedbackForm either =
    case either of
        Left fb ->
            { content = fb.content
            , observationId = fb.observationId
            }

        Right id ->
            { content = ""
            , observationId = id
            }


encodeFeedbackForm : FeedbackForm -> Encode.Value
encodeFeedbackForm form =
    Encode.object
        [ ( "content", Encode.string form.content )
        , ( "observationId", (unwrapObservationId >> Encode.int) form.observationId )
        ]


feedback : Session -> Maybe ObservationId -> (APIData (List Feedback) -> msg) -> Cmd msg
feedback session maybeObservationId toMsg =
    API.getRemote (Endpoint.feedback maybeObservationId) (Session.credential session) (multiDecoder feedbackDecoder) toMsg


getFeedback : Session -> FeedbackId -> (APIData Feedback -> msg) -> Cmd msg
getFeedback session id toMsg =
    API.getRemote (Endpoint.feedbackItem id) (Session.credential session) (singleDecoder feedbackDecoder) toMsg


createFeedback : Session -> FeedbackForm -> (APIData Feedback -> msg) -> Cmd msg
createFeedback session form toMsg =
    API.postRemote (Endpoint.feedback Nothing) (Session.credential session) (jsonBody <| encodeFeedbackForm form) (singleDecoder feedbackDecoder) toMsg


updateFeedback : Session -> FeedbackId -> FeedbackForm -> (APIData Feedback -> msg) -> Cmd msg
updateFeedback session id form toMsg =
    API.putRemote (Endpoint.feedbackItem id) (Session.credential session) ((encodeFeedbackForm >> jsonBody) form) (singleDecoder feedbackDecoder) toMsg


deleteFeedback : Session -> FeedbackId -> (APIData () -> msg) -> Cmd msg
deleteFeedback session id toMsg =
    API.deleteRemote (Endpoint.feedbackItem id) (Session.credential session) toMsg



-- Explanations


type alias ExplanationForm =
    { content : String
    , feedbackId : FeedbackId
    }


initExplanationForm : Either Explanation FeedbackId -> ExplanationForm
initExplanationForm either =
    case either of
        Left explanation ->
            { content = explanation.content
            , feedbackId = explanation.feedbackId
            }

        Right id ->
            { content = ""
            , feedbackId = id
            }


encodeExplanationForm : ExplanationForm -> Encode.Value
encodeExplanationForm form =
    Encode.object
        [ ( "content", Encode.string form.content )
        , ( "feedbackId", (unwrapFeedbackId >> Encode.int) form.feedbackId )
        ]


explanations : Session -> Maybe FeedbackId -> (APIData (List Explanation) -> msg) -> Cmd msg
explanations session maybeFeedbackId toMsg =
    API.getRemote (Endpoint.explanations maybeFeedbackId) (Session.credential session) (multiDecoder explanationDecoder) toMsg


getExplanation : Session -> ExplanationId -> (APIData Explanation -> msg) -> Cmd msg
getExplanation session id toMsg =
    API.getRemote (Endpoint.explanation id) (Session.credential session) (singleDecoder explanationDecoder) toMsg


createExplanation : Session -> ExplanationForm -> (APIData Explanation -> msg) -> Cmd msg
createExplanation session form toMsg =
    API.postRemote (Endpoint.explanations Nothing) (Session.credential session) (jsonBody <| encodeExplanationForm form) (singleDecoder explanationDecoder) toMsg


updateExplanation : Session -> ExplanationId -> ExplanationForm -> (APIData Explanation -> msg) -> Cmd msg
updateExplanation session id form toMsg =
    API.putRemote (Endpoint.explanation id) (Session.credential session) ((encodeExplanationForm >> jsonBody) form) (singleDecoder explanationDecoder) toMsg


deleteExplanation : Session -> ExplanationId -> (APIData () -> msg) -> Cmd msg
deleteExplanation session id toMsg =
    API.deleteRemote (Endpoint.explanation id) (Session.credential session) toMsg



-- Student Feedback


studentFeedback : Session -> DraftId -> (APIData (List StudentFeedback) -> msg) -> Cmd msg
studentFeedback session draftId toMsg =
    API.getRemote (Endpoint.studentFeedback (Just draftId) Nothing) (Session.credential session) (multiDecoder studentFeedbackDecoder) toMsg


createStudentFeedback : Session -> DraftId -> FeedbackId -> (APIResult StudentFeedback -> msg) -> Cmd msg
createStudentFeedback session draftId feedbackId toMsg =
    let
        encodedBody =
            Encode.object
                [ ( "draft_id", (unwrapDraftId >> Encode.int) draftId )
                , ( "feedback_id", (unwrapFeedbackId >> Encode.int) feedbackId )
                ]
    in
    API.post (Endpoint.studentFeedback Nothing Nothing) (Session.credential session) (jsonBody encodedBody) (singleDecoder studentFeedbackDecoder) toMsg


deleteStudentFeedback : Session -> StudentFeedbackId -> (APIResult () -> msg) -> Cmd msg
deleteStudentFeedback session id toMsg =
    API.delete (Endpoint.studentFeedbackItem id) (Session.credential session) toMsg



-- Student Explanations


studentExplanations : Session -> DraftId -> Maybe FeedbackId -> (APIData (List StudentExplanation) -> msg) -> Cmd msg
studentExplanations session draftId feedbackId toMsg =
    API.getRemote (Endpoint.studentExplanations (Just draftId) feedbackId Nothing) (Session.credential session) (multiDecoder studentExplanationDecoder) toMsg


createStudentExplanation : Session -> DraftId -> FeedbackId -> ExplanationId -> (APIResult StudentExplanation -> msg) -> Cmd msg
createStudentExplanation session draftId feedbackId explanationId toMsg =
    let
        encodedBody =
            Encode.object
                [ ( "draft_id", (unwrapDraftId >> Encode.int) draftId )
                , ( "feedback_id", (unwrapFeedbackId >> Encode.int) feedbackId )
                , ( "explanation_id", (unwrapExplanationId >> Encode.int) explanationId )
                ]
    in
    API.post (Endpoint.studentExplanations Nothing Nothing Nothing) (Session.credential session) (jsonBody encodedBody) (singleDecoder studentExplanationDecoder) toMsg


deleteStudentExplanation : Session -> StudentExplanationId -> (APIResult () -> msg) -> Cmd msg
deleteStudentExplanation session id toMsg =
    API.delete (Endpoint.studentExplanation id) (Session.credential session) toMsg



-- Private utilities


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe fn =
    Maybe.map fn >> Maybe.withDefault Encode.null
