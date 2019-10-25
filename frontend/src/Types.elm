module Types exposing (..)

import Json.Decode as Decode exposing (Decoder, bool, decodeString, field, float, int, lazy, list, map, nullable, string)
import Json.Decode.Extra exposing (parseInt)
import Json.Decode.Pipeline as Pipeline exposing (optional, optionalAt, required, requiredAt)
import Json.Encode as Encode exposing (Value)
import Time as Time



-- Rotation types


type ClassroomId
    = ClassroomId Int


unwrapClassroomId : ClassroomId -> Int
unwrapClassroomId (ClassroomId id) =
    id


type alias Classroom =
    { id : ClassroomId
    , courseCode : String
    , name : String
    , description : Maybe String

    -- Related data
    , sections : List SectionId
    , categories : List CategoryId
    , users : List UserId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


classroomDecoder : Decoder Classroom
classroomDecoder =
    Decode.succeed Classroom
        |> requiredType "classroom"
        |> required "id" (map ClassroomId parseInt)
        |> requiredAttribute "course_code" string
        |> requiredAttribute "name" string
        |> optionalAttribute "description" (nullable string)
        |> relationship "sections" (list <| field "id" <| map SectionId parseInt) []
        |> relationship "categories" (list <| field "id" <| map CategoryId parseInt) []
        |> relationship "users" (list <| field "id" <| map UserId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type SemesterId
    = SemesterId Int


unwrapSemesterId : SemesterId -> Int
unwrapSemesterId (SemesterId id) =
    id


type alias Semester =
    { id : SemesterId
    , name : String
    , description : Maybe String
    , startDate : Time.Posix
    , endDate : Time.Posix

    -- Related
    , sections : List SectionId
    , users : List UserId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type Semesters
    = Semesters (List Semester)


semesterDecoder : Decoder Semester
semesterDecoder =
    Decode.succeed Semester
        |> requiredType "semester"
        |> required "id" (map SemesterId parseInt)
        |> requiredAttribute "name" string
        |> optionalAttribute "description" (nullable string)
        |> requiredAttribute "start_date" (map Time.millisToPosix int)
        |> requiredAttribute "end_date" (map Time.millisToPosix int)
        |> relationship "sections" (list <| field "id" <| map SectionId parseInt) []
        |> relationship "users" (list <| field "id" <| map UserId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type SectionId
    = SectionId Int


unwrapSectionId : SectionId -> Int
unwrapSectionId (SectionId id) =
    id


type alias Section =
    { id : SectionId
    , number : String
    , description : Maybe String

    -- Foreign keys
    , semesterId : SemesterId
    , classroomId : ClassroomId

    -- Related data
    , rotations : List RotationId
    , users : List UserId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


sectionDecoder : Decoder Section
sectionDecoder =
    Decode.succeed Section
        |> required "id" (map SectionId parseInt)
        |> requiredAttribute "number" string
        |> optionalAttribute "description" (nullable string)
        |> requiredAttribute "semester_id" (map SemesterId int)
        |> requiredAttribute "classroom_id" (map ClassroomId int)
        |> relationship "rotations" (list <| field "id" <| map RotationId parseInt) []
        |> relationship "users" (list <| field "id" <| map UserId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type RotationId
    = RotationId Int


unwrapRotationId : RotationId -> Int
unwrapRotationId (RotationId id) =
    id


type alias Rotation =
    { rotationId : RotationId
    , number : Int
    , description : Maybe String
    , startDate : Time.Posix
    , endDate : Time.Posix

    -- Foreign keys
    , sectionId : SectionId

    -- Related data
    , rotationGroups : List RotationGroupId
    , users : List UserId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


rotationDecoder : Decoder Rotation
rotationDecoder =
    Decode.succeed Rotation
        |> required "id" (map RotationId parseInt)
        |> requiredAttribute "number" int
        |> optionalAttribute "description" (nullable string)
        |> requiredAttribute "start_date" (map Time.millisToPosix int)
        |> requiredAttribute "end_date" (map Time.millisToPosix int)
        |> requiredAttribute "section_id" (map SectionId int)
        |> relationship "rotation_groups" (list <| field "id" <| map RotationGroupId parseInt) []
        |> relationship "users" (list <| field "id" <| map UserId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type RotationGroupId
    = RotationGroupId Int


unwrapRotationGroupId : RotationGroupId -> Int
unwrapRotationGroupId (RotationGroupId id) =
    id


type alias RotationGroup =
    { id : RotationGroupId
    , number : Int
    , description : Maybe String

    -- Foreign keys
    , rotationId : RotationId

    -- Related data
    , users : List UserId
    , classroom : ClassroomId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


rotationGroupDecoder : Decoder RotationGroup
rotationGroupDecoder =
    Decode.succeed RotationGroup
        |> required "id" (map RotationGroupId parseInt)
        |> requiredAttribute "number" int
        |> optionalAttribute "description" (nullable string)
        |> requiredAttribute "rotation_id" (map RotationId int)
        |> relationship "users" (list <| field "id" <| map UserId parseInt) []
        |> requiredRelationship "classroom" (field "id" <| map ClassroomId parseInt)
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)



-- Account types


type UserId
    = UserId Int


unwrapUserId : UserId -> Int
unwrapUserId (UserId id) =
    id



type  Role = Admin | Faculty | TeachingAssistant | LearningAssistant | Student

roleDecoder : Decoder Role
roleDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "admin" ->
                        Decode.succeed Admin

                    "faculty" ->
                        Decode.succeed Faculty

                    "teaching_assistant" ->
                        Decode.succeed TeachingAssistant

                    "learning_assistant" ->
                        Decode.succeed LearningAssistant

                    "student" ->
                        Decode.succeed Student

                    else_ ->
                        Decode.fail <| "Unknown role: " ++ else_
            )


roleToString : Role -> String
roleToString role =
    case role of
        Admin ->
            "admin"

        Faculty ->
            "faculty"

        TeachingAssistant ->
            "teaching_assistant"

        LearningAssistant ->
            "learning_assistant"

        Student ->
            "student"


type alias User =
    { id : UserId
    , email : String
    , firstName : String
    , middleName : Maybe String
    , lastName : String
    , nickname : Maybe String
    , active : Bool

    -- Related data
    , role : Role
    , classrooms : List ClassroomId
    , sections : List SectionId
    , rotationGroups : List RotationGroupId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "id" (map UserId parseInt)
        |> requiredAttribute "email" string
        |> requiredAttribute "first_name" string
        |> optionalAttribute "middle_name" (nullable string)
        |> requiredAttribute "last_name" string
        |> optionalAttribute "nickname" (nullable string)
        |> requiredAttribute "active" bool
        |> requiredAttribute "role" (roleDecoder)
        |> relationship "classrooms" (list <| field "id" <| map ClassroomId parseInt) []
        |> relationship "sections" (list <| field "id" <| map SectionId parseInt) []
        |> relationship "rotation_groups" (list <| field "id" <| map RotationGroupId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


credUserDecoder : Decoder User
credUserDecoder =
    Decode.succeed User
        |> required "id" (map UserId int)
        |> required "email" string
        |> required "first_name" string
        |> optionalMaybe "middle_name" (nullable string)
        |> required "last_name" string
        |> optionalMaybe "nickname" (nullable string)
        |> required "active" bool
        |> required "role" (roleDecoder)
        |> required "classrooms" (list <| map ClassroomId int)
        |> required "sections" (list <| map SectionId int)
        |> required "rotation_groups" (list <| map RotationGroupId int)
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


encodeUser : User -> Value
encodeUser user =
    let
        idEncoder (UserId val) =
            Encode.int val
    in
    Encode.object
        [ ( "id", idEncoder user.id )
        , ( "email", Encode.string user.email )
        , ( "first_name", Encode.string user.firstName )
        , ( "middle_name", encodeMaybe Encode.string user.middleName )
        , ( "last_name", Encode.string user.lastName )
        , ( "nickname", encodeMaybe Encode.string user.nickname )
        , ( "active", Encode.bool user.active )
        , ( "role", (roleToString >> Encode.string) user.role )
        , ( "classrooms", Encode.list (unwrapClassroomId >> Encode.int) user.classrooms )
        , ( "sections", Encode.list (unwrapSectionId >> Encode.int) user.sections )
        , ( "rotation_groups", Encode.list (unwrapRotationGroupId >> Encode.int) user.rotationGroups )
        , ( "inserted_at", encodePosix user.insertedAt )
        , ( "updated_at", encodePosix user.updatedAt )
        ]



-- Feedback types


type CategoryId
    = CategoryId Int


unwrapCategoryId : CategoryId -> Int
unwrapCategoryId (CategoryId id) =
    id


type alias Category =
    { id : CategoryId
    , name : String
    , description : Maybe String

    -- Foreign keys
    , parentCategoryId : Maybe CategoryId

    -- Related data
    , subCategories : List CategoryId
    , observations : List ObservationId
    , classrooms : List ClassroomId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


categoryDecoder : Decoder Category
categoryDecoder =
    Decode.succeed Category
        |> required "id" (map CategoryId parseInt)
        |> requiredAttribute "name" string
        |> optionalAttribute "description" (nullable string)
        |> optionalAttribute "parent_category_id" (nullable (map CategoryId int))
        |> relationship "sub_categories" (list <| field "id" <| map CategoryId parseInt) []
        |> relationship "observations" (list <| field "id" <| map ObservationId parseInt) []
        |> relationship "classrooms" (list <| field "id" <| map ClassroomId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type ObservationId
    = ObservationId Int


unwrapObservationId : ObservationId -> Int
unwrapObservationId (ObservationId id) =
    id


type ObservationType
    = Positive
    | Neutral
    | Negative


observationTypeDecoder : Decoder ObservationType
observationTypeDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "positive" ->
                        Decode.succeed Positive

                    "neutral" ->
                        Decode.succeed Neutral

                    "negative" ->
                        Decode.succeed Negative

                    else_ ->
                        Decode.fail <| "Unknown observation type: " ++ else_
            )

observationTypeToString : ObservationType -> String
observationTypeToString type_ = case type_ of
                                    Positive -> "positive"
                                    Neutral -> "neutral"
                                    Negative -> "negative"

type alias Observation =
    { id : ObservationId
    , content : String
    , type_ : ObservationType

    -- Foreign keys
    , categoryId : CategoryId

    -- Related data
    , feedback : List FeedbackId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


observationDecoder : Decoder Observation
observationDecoder =
    Decode.succeed Observation
        |> required "id" (map ObservationId parseInt)
        |> requiredAttribute "content" string
        |> requiredAttribute "type" observationTypeDecoder
        |> requiredAttribute "category_id" (map CategoryId int)
        |> relationship "feedback" (list <| field "id" <| map FeedbackId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type FeedbackId
    = FeedbackId Int


unwrapFeedbackId : FeedbackId -> Int
unwrapFeedbackId (FeedbackId id) =
    id


type alias Feedback =
    { id : FeedbackId
    , content : String

    -- Foreign keys
    , observationId : ObservationId

    -- Related data
    , explanations : List ExplanationId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


feedbackDecoder : Decoder Feedback
feedbackDecoder =
    Decode.succeed Feedback
        |> required "id" (map FeedbackId parseInt)
        |> requiredAttribute "content" string
        |> requiredAttribute "observation_id" (map ObservationId int)
        |> relationship "explanations" (list <| field "id" <| map ExplanationId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type ExplanationId
    = ExplanationId Int


unwrapExplanationId : ExplanationId -> Int
unwrapExplanationId (ExplanationId id) =
    id


type alias Explanation =
    { id : ExplanationId
    , content : String

    -- Foreign keys
    , feedbackId : FeedbackId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


explanationDecoder : Decoder Explanation
explanationDecoder =
    Decode.succeed Explanation
        |> required "id" (map ExplanationId parseInt)
        |> requiredAttribute "content" string
        |> requiredAttribute "feedback_id" (map FeedbackId int)
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type DraftId
    = DraftId Int


unwrapDraftId : DraftId -> Int
unwrapDraftId (DraftId id) =
    id


type DraftStatus
    = Unreviewed
    | Reviewing
    | NeedsRevision
    | Approved
    | Emailed


draftStatusDecoder : Decoder DraftStatus
draftStatusDecoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "unreviewed" ->
                        Decode.succeed Unreviewed

                    "reviewing" ->
                        Decode.succeed Reviewing

                    "needs_revision" ->
                        Decode.succeed NeedsRevision

                    "approved" ->
                        Decode.succeed Approved

                    "emailed" ->
                        Decode.succeed Emailed

                    else_ ->
                        Decode.fail <| "Unknown draft status: " ++ else_
            )


draftStatusToString : DraftStatus -> String
draftStatusToString status =
    case status of
        Unreviewed ->
            "unreviewed"

        Reviewing ->
            "reviewing"

        NeedsRevision ->
            "needs_revision"

        Approved ->
            "approved"

        Emailed ->
            "emailed"


type alias GroupDraft =
    { id : DraftId
    , content : String
    , notes : Maybe String
    , status : DraftStatus

    -- Foreign keys
    , rotationGroupId : RotationGroupId

    -- Related data
    , comments : List CommentId
    , grades : List GradeId
    , studentDrafts : List DraftId
    , categories : List CategoryId
    , users : List UserId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type alias StudentDraft =
    { id : DraftId
    , content : String
    , notes : Maybe String
    , status : DraftStatus

    -- Foreign keys
    , studentId : UserId
    , parentDraftId : DraftId

    -- Related data
    , comments : List CommentId
    , grades : List GradeId
    , categories : List CategoryId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


groupDraftDecoder : Decoder GroupDraft
groupDraftDecoder =
    Decode.succeed GroupDraft
        |> required "id" (map DraftId parseInt)
        |> requiredAttribute "content" string
        |> requiredAttribute "notes" (nullable string)
        |> requiredAttribute "status" draftStatusDecoder
        |> requiredAttribute "rotation_group_id" (map RotationGroupId int)
        |> relationship "comments" (list <| field "id" <| map CommentId parseInt) []
        |> relationship "grades" (list <| field "id" <| map GradeId parseInt) []
        |> relationship "child_drafts" (list <| field "id" <| map DraftId parseInt) []
        |> relationship "group_categories" (list <| field "id" <| map CategoryId parseInt) []
        |> relationship "group_users" (list <| field "id" <| map UserId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


studentDraftDecoder : Decoder StudentDraft
studentDraftDecoder =
    Decode.succeed StudentDraft
        |> required "id" (map DraftId parseInt)
        |> requiredAttribute "content" string
        |> optionalAttribute "notes" (nullable string)
        |> requiredAttribute "status" draftStatusDecoder
        |> requiredAttribute "student_id" (map UserId int)
        |> requiredAttribute "parent_draft_id" (map DraftId int)
        |> relationship "comments" (list <| field "id" <| map CommentId parseInt) []
        |> relationship "grades" (list <| field "id" <| map GradeId parseInt) []
        |> relationship "student_categories" (list <| field "id" <| map CategoryId parseInt) []
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type CommentId
    = CommentId Int


unwrapCommentId : CommentId -> Int
unwrapCommentId (CommentId id) =
    id


type alias Comment =
    { id : CommentId
    , content : String

    -- Foreign keys
    , draftId : DraftId
    , userId : UserId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


commentDecoder : Decoder Comment
commentDecoder =
    Decode.succeed Comment
        |> required "id" (map CommentId parseInt)
        |> requiredAttribute "content" string
        |> requiredAttribute "draft_id" (map DraftId int)
        |> requiredAttribute "user_id" (map UserId int)
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type GradeId
    = GradeId Int


unwrapGradeId : GradeId -> Int
unwrapGradeId (GradeId id) =
    id


type alias Grade =
    { id : GradeId
    , score : Int
    , note : Maybe String

    -- Foreign keys
    , categoryId : CategoryId
    , draftId : DraftId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


gradeDecoder : Decoder Grade
gradeDecoder =
    Decode.succeed Grade
        |> required "id" (map GradeId parseInt)
        |> requiredAttribute "score" int
        |> optionalMaybe "note" (nullable string)
        |> requiredAttribute "category_id" (map CategoryId int)
        |> requiredAttribute "draft_id" (map DraftId int)
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type EmailId
    = EmailId Int


unwrapEmailId : EmailId -> Int
unwrapEmailId (EmailId id) =
    id


type alias Email =
    { id : EmailId
    , status : String

    -- Foreign keys
    , draftId : DraftId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


emailDecoder : Decoder Email
emailDecoder =
    Decode.succeed Email
        |> required "id" (map EmailId parseInt)
        |> requiredAttribute "status" string
        |> requiredAttribute "draft_id" (map DraftId int)
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type StudentFeedbackId
    = StudentFeedbackId Int


unwrapStudentFeedbackId : StudentFeedbackId -> Int
unwrapStudentFeedbackId (StudentFeedbackId id) =
    id


type alias StudentFeedback =
    { id : StudentFeedbackId
    , draftId : DraftId
    , feedbackId : FeedbackId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


studentFeedbackDecoder : Decoder StudentFeedback
studentFeedbackDecoder =
    Decode.succeed StudentFeedback
        |> required "id" (map StudentFeedbackId parseInt)
        |> requiredAttribute "draft_id" (map DraftId int)
        |> requiredAttribute "feedback_id" (map FeedbackId int)
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)


type StudentExplanationId
    = StudentExplanationId Int


unwrapStudentExplanationId : StudentExplanationId -> Int
unwrapStudentExplanationId (StudentExplanationId id) =
    id


type alias StudentExplanation =
    { id : StudentExplanationId
    , draftId : DraftId
    , feedbackId : FeedbackId
    , explanationId : ExplanationId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


studentExplanationDecoder : Decoder StudentExplanation
studentExplanationDecoder =
    Decode.succeed StudentExplanation
        |> required "id" (map StudentExplanationId parseInt)
        |> requiredAttribute "draft_id" (map DraftId int)
        |> requiredAttribute "feedback_id" (map FeedbackId int)
        |> requiredAttribute "explanation_id" (map ExplanationId int)
        |> requiredAttribute "inserted_at" (map Time.millisToPosix int)
        |> requiredAttribute "updated_at" (map Time.millisToPosix int)



-- Utility


encodeMaybe : (a -> Value) -> Maybe a -> Value
encodeMaybe toValue maybe =
    case maybe of
        Nothing ->
            Encode.null

        Just a ->
            toValue a


encodePosix : Time.Posix -> Value
encodePosix time =
    Encode.int (Time.posixToMillis time)


optionalMaybe : String -> Decoder (Maybe a) -> Decoder (Maybe a -> b) -> Decoder b
optionalMaybe key valDecoder decoder =
    optional key valDecoder Nothing decoder


requiredAttribute : String -> Decoder a -> Decoder (a -> b) -> Decoder b
requiredAttribute key valDecoder decoder =
    requiredAt [ "attributes", key ] valDecoder decoder


requiredRelationship : String -> Decoder a -> Decoder (a -> b) -> Decoder b
requiredRelationship key valDecoder decoder =
    requiredAt [ "relationships", key, "data" ] valDecoder decoder


relationship : String -> Decoder a -> a -> Decoder (a -> b) -> Decoder b
relationship key valDecoder default decoder =
    optionalAt [ "relationships", key, "data" ] valDecoder default decoder


optionalAttribute : String -> Decoder (Maybe a) -> Decoder (Maybe a -> b) -> Decoder b
optionalAttribute key valDecoder decoder =
    optionalAt [ "attributes", key ] valDecoder Nothing decoder


singleDecoder : Decoder a -> Decoder a
singleDecoder =
    field "data"


multiDecoder : Decoder a -> Decoder (List a)
multiDecoder valDecoder =
    field "data" <| list valDecoder


requiredType : String -> Decoder (a -> b) -> Decoder (a -> b)
requiredType reqType decoder =
    Decode.field "type" string
        |> Decode.andThen
            (\type_ ->
                if type_ == reqType then
                    decoder

                else
                    Decode.fail <| "Type of document expected to be " ++ reqType ++ ", got " ++ type_
            )
