module API.Drafts exposing (..)

import API exposing (APIData, APIResult)
import API.Endpoint as Endpoint
import Http exposing (jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Session exposing (Session)
import Time as Time
import Types exposing (..)
import Either exposing (Either)
import Either.Decode exposing (either)


-- Drafts

draft : Session -> DraftId -> (APIData (Either GroupDraft StudentDraft) -> msg) -> Cmd msg
draft session draftId toMsg =
    API.getRemote (Endpoint.draft draftId) (Session.credential session) (either (singleDecoder groupDraftDecoder) (singleDecoder studentDraftDecoder)) toMsg

groupDraft : Session -> DraftId -> (APIData GroupDraft -> msg) -> Cmd msg
groupDraft session draftId toMsg =
    API.getRemote (Endpoint.draft draftId) (Session.credential session) (singleDecoder groupDraftDecoder) toMsg


groupDrafts : Session -> Maybe RotationGroupId -> (APIData (List GroupDraft) -> msg) -> Cmd msg
groupDrafts session maybeGroup toMsg =
    API.getRemote (Endpoint.drafts Nothing Nothing maybeGroup) (Session.credential session) (multiDecoder groupDraftDecoder) toMsg


studentDraft : Session -> DraftId -> (APIData StudentDraft -> msg) -> Cmd msg
studentDraft session draftId toMsg =
    API.getRemote (Endpoint.draft draftId) (Session.credential session) (singleDecoder studentDraftDecoder) toMsg


groupDraftToForm : GroupDraft -> GroupDraftForm
groupDraftToForm d =
    { content = d.content
    , status = d.status
    , rotationGroupId = d.rotationGroupId
    }


type alias GroupDraftForm =
    { content : String
    , status : DraftStatus
    -- Foreign keys
    , rotationGroupId : RotationGroupId
    }

studentDraftToForm : StudentDraft -> StudentDraftForm
studentDraftToForm d =
    { content = d.content
    , status = d.status
    , studentId = d.studentId
    , parentDraftId = d.parentDraftId
    }


type alias StudentDraftForm =
    { content : String
    , status : DraftStatus
    -- Foreign keys
    , studentId : UserId
    , parentDraftId : DraftId
    }


encodeGroupDraftForm : GroupDraftForm -> Encode.Value
encodeGroupDraftForm form =
    Encode.object
        [ ( "content", Encode.string form.content )
        , ( "status", (draftStatusToString >> Encode.string) form.status )
        , ( "rotation_group_id", (unwrapRotationGroupId >> Encode.int) form.rotationGroupId )
        ]

encodeStudentDraftForm : StudentDraftForm -> Encode.Value
encodeStudentDraftForm form =
    Encode.object
        [ ( "content", Encode.string form.content )
        , ( "status", (draftStatusToString >> Encode.string) form.status )
        , ( "student_id", (unwrapUserId >> Encode.int) form.studentId )
        , ( "partent_draft_id", (unwrapDraftId >> Encode.int) form.parentDraftId )
        ]


updateGroupDraft : Session -> DraftId -> GroupDraftForm -> (APIData GroupDraft -> msg) -> Cmd msg
updateGroupDraft session id form toMsg =
    API.putRemote (Endpoint.draft id) (Session.credential session) (jsonBody <| encodeGroupDraftForm form) groupDraftDecoder toMsg

updateStudentDraft : Session -> DraftId -> StudentDraftForm -> (APIData StudentDraft -> msg) -> Cmd msg
updateStudentDraft session id form toMsg =
    API.putRemote (Endpoint.draft id) (Session.credential session) (jsonBody <| encodeStudentDraftForm form) studentDraftDecoder toMsg


createGroupDraft : Session -> GroupDraftForm -> (APIData GroupDraft -> msg) -> Cmd msg
createGroupDraft session form toMsg =
    API.postRemote (Endpoint.drafts Nothing Nothing Nothing) (Session.credential session) (jsonBody <| encodeGroupDraftForm form) groupDraftDecoder toMsg

createStudentDraft : Session -> StudentDraftForm -> (APIData StudentDraft -> msg) -> Cmd msg
createStudentDraft session form toMsg =
    API.postRemote (Endpoint.drafts Nothing Nothing Nothing) (Session.credential session) (jsonBody <| encodeStudentDraftForm form) studentDraftDecoder toMsg


deleteDraft : Session -> DraftId -> (APIData () -> msg) -> Cmd msg
deleteDraft session id toMsg =
    API.deleteRemote (Endpoint.draft id) (Session.credential session) toMsg

-- Grades

grades : Session -> DraftId -> (APIData (List Grade) -> msg) -> Cmd msg
grades session draftId toMsg =
    API.getRemote (Endpoint.grades <| Just draftId) (Session.credential session) (Decode.list gradeDecoder) toMsg

type alias GradeForm =
    { score : Int
    , note : String
    , categoryId: CategoryId
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
        [ ("score", Encode.int form.score)
        , ("note", Encode.string form.note)
        , ("category_id", (unwrapCategoryId >> Encode.int) form.categoryId)
        , ("draft_id", (unwrapDraftId >> Encode.int) form.draftId)
        ]

createGrade : Session -> GradeForm -> (APIData Grade -> msg) -> Cmd msg
createGrade session form toMsg =
    API.postRemote (Endpoint.grades Nothing) (Session.credential session) (jsonBody <| encodeGradeForm form) gradeDecoder toMsg

updateGrade : Session -> GradeId -> GradeForm -> (APIData Grade -> msg) -> Cmd msg
updateGrade session id form toMsg =
    API.putRemote (Endpoint.grade id) (Session.credential session) (jsonBody <| encodeGradeForm form) gradeDecoder toMsg

-- Comments

comments : Session -> DraftId -> (APIData (List Comment) -> msg) -> Cmd msg
comments session draftId toMsg =
    API.getRemote (Endpoint.comments <| Just draftId) (Session.credential session) (multiDecoder commentDecoder) toMsg

type alias CommentForm =
    { content : String
    , userId: UserId
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
        [("content", Encode.string form.content)
        , ("user_id", (unwrapUserId >> Encode.int) form.userId)
        , ("draft_id", (unwrapDraftId >> Encode.int) form.draftId)
        ]

createComment : Session -> CommentForm -> (APIData Comment -> msg) -> Cmd msg
createComment session form toMsg =
    API.postRemote (Endpoint.comments Nothing) (Session.credential session) (jsonBody <| encodeCommentForm form) commentDecoder toMsg

updateComment : Session -> CommentId -> CommentForm -> (APIData Comment -> msg) -> Cmd msg
updateComment session id form toMsg =
    API.putRemote (Endpoint.comment id) (Session.credential session) (jsonBody <| encodeCommentForm form) commentDecoder toMsg

