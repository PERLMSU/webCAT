module API.Drafts exposing (CommentForm, GradeForm, GroupDraftForm, StudentDraftForm, commentToForm, comments, createComment, createGrade, createGroupDraft, createStudentDraft, deleteDraft, draft, encodeCommentForm, encodeGradeForm, encodeGroupDraftForm, encodeMaybe, encodeStudentDraftForm, gradeToForm, grades, groupDraft, groupDraftToForm, groupDrafts, studentDraft, studentDraftToForm, studentDrafts, updateComment, updateGrade, updateGroupDraft, updateStudentDraft)

import API exposing (APIData, APIResult)
import API.Endpoint as Endpoint
import Either exposing (Either)
import Either.Decode exposing (either)
import Http exposing (jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Session exposing (Session)
import Time as Time
import Types exposing (..)



-- Drafts


draft : Session -> DraftId -> (APIData (Either GroupDraft StudentDraft) -> msg) -> Cmd msg
draft session draftId toMsg =
    API.getRemote (Endpoint.draft draftId) (Session.credential session) (either (singleDecoder groupDraftDecoder) (singleDecoder studentDraftDecoder)) toMsg


groupDraft : Session -> DraftId -> (APIData GroupDraft -> msg) -> Cmd msg
groupDraft session draftId toMsg =
    API.getRemote (Endpoint.draft draftId) (Session.credential session) (singleDecoder groupDraftDecoder) toMsg


groupDrafts : Session -> Maybe RotationGroupId -> (APIData (List GroupDraft) -> msg) -> Cmd msg
groupDrafts session maybeGroup toMsg =
    API.getRemote (Endpoint.drafts Nothing Nothing maybeGroup Nothing) (Session.credential session) (multiDecoder groupDraftDecoder) toMsg


studentDrafts : Session -> Maybe DraftId -> (APIData (List StudentDraft) -> msg) -> Cmd msg
studentDrafts session maybeDraftId toMsg =
    API.getRemote (Endpoint.drafts Nothing Nothing Nothing maybeDraftId) (Session.credential session) (multiDecoder studentDraftDecoder) toMsg


studentDraft : Session -> DraftId -> (APIData StudentDraft -> msg) -> Cmd msg
studentDraft session draftId toMsg =
    API.getRemote (Endpoint.draft draftId) (Session.credential session) (singleDecoder studentDraftDecoder) toMsg


groupDraftToForm : Maybe GroupDraft -> GroupDraftForm
groupDraftToForm maybeDraft =
    case maybeDraft of
        Just d ->
            { content = d.content
            , notes = Maybe.withDefault "" d.notes
            , status = d.status
            , rotationGroupId = Just d.rotationGroupId
            }

        Nothing ->
            { content = ""
            , notes = ""
            , status = Unreviewed
            , rotationGroupId = Nothing
            }


type alias GroupDraftForm =
    { content : String
    , status : DraftStatus
    , notes : String

    -- Foreign keys
    , rotationGroupId : Maybe RotationGroupId
    }


studentDraftToForm : Maybe StudentDraft -> StudentDraftForm
studentDraftToForm maybeDraft =
    case maybeDraft of
        Just d ->
            { content = d.content
            , notes = Maybe.withDefault "" d.notes
            , status = d.status
            , studentId = Just d.studentId
            , parentDraftId = Just d.parentDraftId
            }

        Nothing ->
            { content = ""
            , notes = ""
            , status = Unreviewed
            , studentId = Nothing
            , parentDraftId = Nothing
            }


type alias StudentDraftForm =
    { content : String
    , notes : String
    , status : DraftStatus

    -- Foreign keys
    , studentId : Maybe UserId
    , parentDraftId : Maybe DraftId
    }


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe encoder maybe = Maybe.withDefault Encode.null <| Maybe.map encoder maybe


encodeGroupDraftForm : GroupDraftForm -> Encode.Value
encodeGroupDraftForm form =
    Encode.object
        [ ( "content", Encode.string form.content )
        , ( "notes", Encode.string form.notes )
        , ( "status", (draftStatusToString >> Encode.string) form.status )
        , ( "rotation_group_id", encodeMaybe (unwrapRotationGroupId >> Encode.int) form.rotationGroupId )
        ]


encodeStudentDraftForm : StudentDraftForm -> Encode.Value
encodeStudentDraftForm form =
    Encode.object
        [ ( "content", Encode.string form.content )
        , ( "notes", Encode.string form.notes )
        , ( "status", (draftStatusToString >> Encode.string) form.status )
        , ( "student_id", encodeMaybe (unwrapUserId >> Encode.int) form.studentId )
        , ( "parent_draft_id", encodeMaybe (unwrapDraftId >> Encode.int) form.parentDraftId )
        ]


updateGroupDraft : Session -> DraftId -> GroupDraftForm -> (APIData GroupDraft -> msg) -> Cmd msg
updateGroupDraft session id form toMsg =
    API.putRemote (Endpoint.draft id) (Session.credential session) (jsonBody <| encodeGroupDraftForm form) (singleDecoder groupDraftDecoder) toMsg


updateStudentDraft : Session -> DraftId -> StudentDraftForm -> (APIData StudentDraft -> msg) -> Cmd msg
updateStudentDraft session id form toMsg =
    API.putRemote (Endpoint.draft id) (Session.credential session) (jsonBody <| encodeStudentDraftForm form) (singleDecoder studentDraftDecoder) toMsg


createGroupDraft : Session -> GroupDraftForm -> (APIData GroupDraft -> msg) -> Cmd msg
createGroupDraft session form toMsg =
    API.postRemote (Endpoint.drafts Nothing Nothing Nothing Nothing) (Session.credential session) (jsonBody <| encodeGroupDraftForm form) (singleDecoder groupDraftDecoder) toMsg


createStudentDraft : Session -> StudentDraftForm -> (APIData StudentDraft -> msg) -> Cmd msg
createStudentDraft session form toMsg =
    API.postRemote (Endpoint.drafts Nothing Nothing Nothing Nothing) (Session.credential session) (jsonBody <| encodeStudentDraftForm form) (singleDecoder studentDraftDecoder) toMsg


deleteDraft : Session -> DraftId -> (APIData () -> msg) -> Cmd msg
deleteDraft session id toMsg =
    API.deleteRemote (Endpoint.draft id) (Session.credential session) toMsg



-- Grades


grades : Session -> DraftId -> (APIData (List Grade) -> msg) -> Cmd msg
grades session draftId toMsg =
    API.getRemote (Endpoint.grades <| Just draftId) (Session.credential session) (multiDecoder gradeDecoder) toMsg


type alias GradeForm =
    { score : Int
    , note : String
    , categoryId : CategoryId
    , draftId : DraftId
    }


gradeToForm : Grade -> GradeForm
gradeToForm g =
    { score = g.score
    , note = Maybe.withDefault "" g.note
    , categoryId = g.categoryId
    , draftId = g.draftId
    }


encodeGradeForm : GradeForm -> Encode.Value
encodeGradeForm form =
    Encode.object
        [ ( "score", Encode.int form.score )
        , ( "note", Encode.string form.note )
        , ( "category_id", (unwrapCategoryId >> Encode.int) form.categoryId )
        , ( "draft_id", (unwrapDraftId >> Encode.int) form.draftId )
        ]


createGrade : Session -> GradeForm -> (APIData Grade -> msg) -> Cmd msg
createGrade session form toMsg =
    API.postRemote (Endpoint.grades Nothing) (Session.credential session) (jsonBody <| encodeGradeForm form) (singleDecoder gradeDecoder) toMsg


updateGrade : Session -> GradeId -> GradeForm -> (APIData Grade -> msg) -> Cmd msg
updateGrade session id form toMsg =
    API.putRemote (Endpoint.grade id) (Session.credential session) (jsonBody <| encodeGradeForm form) (singleDecoder gradeDecoder) toMsg



-- Comments


comments : Session -> DraftId -> (APIData (List Comment) -> msg) -> Cmd msg
comments session draftId toMsg =
    API.getRemote (Endpoint.comments <| Just draftId) (Session.credential session) (multiDecoder commentDecoder) toMsg


type alias CommentForm =
    { content : String
    , userId : UserId
    , draftId : DraftId
    }


commentToForm : Comment -> CommentForm
commentToForm c =
    { content = c.content
    , userId = c.userId
    , draftId = c.draftId
    }


encodeCommentForm : CommentForm -> Encode.Value
encodeCommentForm form =
    Encode.object
        [ ( "content", Encode.string form.content )
        , ( "user_id", (unwrapUserId >> Encode.int) form.userId )
        , ( "draft_id", (unwrapDraftId >> Encode.int) form.draftId )
        ]


createComment : Session -> CommentForm -> (APIData Comment -> msg) -> Cmd msg
createComment session form toMsg =
    API.postRemote (Endpoint.comments Nothing) (Session.credential session) (jsonBody <| encodeCommentForm form) (singleDecoder commentDecoder) toMsg


updateComment : Session -> CommentId -> CommentForm -> (APIData Comment -> msg) -> Cmd msg
updateComment session id form toMsg =
    API.putRemote (Endpoint.comment id) (Session.credential session) (jsonBody <| encodeCommentForm form) (singleDecoder commentDecoder) toMsg
