module API.Drafts exposing (DraftForm, deleteDraft, draft, draftToForm, drafts, editDraft, encodeDraftForm, newDraft)

import API exposing (APIData, APIResult)
import API.Endpoint as Endpoint
import Http exposing (jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Session exposing (Session)
import Time as Time
import Types exposing (..)



-- Drafts


draft : Session -> DraftId -> (APIData Draft -> msg) -> Cmd msg
draft session draftId toMsg =
    API.getRemote (Endpoint.draft draftId) (Session.credential session) draftDecoder toMsg


drafts : Session -> Maybe DraftStatus -> Maybe UserId -> Maybe RotationGroupId -> (APIData (List Draft) -> msg) -> Cmd msg
drafts session maybeStatus maybeUser maybeGroup toMsg =
    API.getRemote (Endpoint.drafts maybeStatus maybeUser maybeGroup) (Session.credential session) (Decode.list draftDecoder) toMsg


draftToForm : Draft -> DraftForm
draftToForm d =
    { content = d.content
    , status = d.status
    , studentId = Just d.studentId
    , reviewerId = d.reviewerId
    , rotationGroupId = Just d.rotationGroupId
    , authors = Maybe.withDefault [] <| Maybe.map (unwrapUsers >> List.map .id) d.authors
    }


type alias DraftForm =
    { content : String
    , status : DraftStatus

    -- Foreign keys
    , studentId : Maybe UserId
    , reviewerId : Maybe UserId
    , rotationGroupId : Maybe RotationGroupId
    , authors : List UserId
    }


encodeDraftForm : DraftForm -> Encode.Value
encodeDraftForm form =
    Encode.object
        [ ( "content", Encode.string form.content )
        , ( "status", (draftStatusToString >> Encode.string) form.status )
        , ( "student_id", encodeMaybe (unwrapUserId >> Encode.int) form.studentId )
        , ( "reviewer_id", encodeMaybe (unwrapUserId >> Encode.int) form.reviewerId )
        , ( "rotation_group_id", encodeMaybe (unwrapRotationGroupId >> Encode.int) form.rotationGroupId )
        , ( "authors", Encode.list (unwrapUserId >> Encode.int) form.authors )
        ]


editDraft : Session -> DraftId -> DraftForm -> (APIData Draft -> msg) -> Cmd msg
editDraft session id form toMsg =
    API.putRemote (Endpoint.draft id) (Session.credential session) (jsonBody <| encodeDraftForm form) draftDecoder toMsg


newDraft : Session -> DraftForm -> (APIData Draft -> msg) -> Cmd msg
newDraft session form toMsg =
    API.postRemote (Endpoint.drafts Nothing Nothing Nothing) (Session.credential session) (jsonBody <| encodeDraftForm form) draftDecoder toMsg


deleteDraft : Session -> DraftId -> (APIData () -> msg) -> Cmd msg
deleteDraft session id toMsg =
    API.deleteRemote (Endpoint.draft id) (Session.credential session) toMsg
