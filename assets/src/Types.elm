module Types exposing (..)

import Json.Decode as Decode exposing (Decoder, bool, decodeString, field, float, int, lazy, list, map, nullable, string)
import Json.Decode.Pipeline exposing (optional, required)
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
    , semesters : Maybe Semesters
    , categories : Maybe Categories
    , users : Maybe Users

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type Classrooms
    = Classrooms (List Classroom)


unwrapClassrooms : Classrooms -> List Classroom
unwrapClassrooms (Classrooms l) =
    l


classroomDecoder : Decoder Classroom
classroomDecoder =
    Decode.succeed Classroom
        |> required "id" (map ClassroomId int)
        |> required "course_code" string
        |> required "name" string
        |> optionalMaybe "description" (nullable string)
        |> optionalMaybe "semesters" (nullable (map Semesters (list (lazy (\_ -> semesterDecoder)))))
        |> optionalMaybe "categories" (nullable (map Categories (list (lazy (\_ -> categoryDecoder)))))
        |> optionalMaybe "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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

    -- Foreign keys
    , classroomId : ClassroomId

    -- Related data
    , classroom : Maybe Classroom
    , sections : Maybe Sections
    , users : Maybe Users

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type Semesters
    = Semesters (List Semester)


unwrapSemesters : Semesters -> List Semester
unwrapSemesters (Semesters l) =
    l


semesterDecoder : Decoder Semester
semesterDecoder =
    Decode.succeed Semester
        |> required "id" (map SemesterId int)
        |> required "name" string
        |> optionalMaybe "description" (nullable string)
        |> required "start_date" (map Time.millisToPosix int)
        |> required "end_date" (map Time.millisToPosix int)
        |> required "classroom_id" (map ClassroomId int)
        |> optionalMaybe "classroom" (nullable (lazy (\_ -> classroomDecoder)))
        |> optionalMaybe "sections" (nullable (map Sections (list (lazy (\_ -> sectionDecoder)))))
        |> optionalMaybe "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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

    -- Related data
    , semester : Maybe Semester
    , rotations : Maybe Rotations
    , users : Maybe Users

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type Sections
    = Sections (List Section)


unwrapSections : Sections -> List Section
unwrapSections (Sections l) =
    l


sectionDecoder : Decoder Section
sectionDecoder =
    Decode.succeed Section
        |> required "id" (map SectionId int)
        |> required "number" string
        |> optionalMaybe "description" (nullable string)
        |> required "semester_id" (map SemesterId int)
        |> optionalMaybe "semester" (nullable (lazy (\_ -> semesterDecoder)))
        |> optionalMaybe "rotations" (nullable (map Rotations (list (lazy (\_ -> rotationDecoder)))))
        |> optionalMaybe "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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
    , section : Maybe Section
    , rotationGroups : Maybe RotationGroups
    , users : Maybe Users

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type Rotations
    = Rotations (List Rotation)


unwrapRotations : Rotations -> List Rotation
unwrapRotations (Rotations l) =
    l


rotationDecoder : Decoder Rotation
rotationDecoder =
    Decode.succeed Rotation
        |> required "id" (map RotationId int)
        |> required "number" int
        |> optionalMaybe "description" (nullable string)
        |> required "start_date" (map Time.millisToPosix int)
        |> required "end_date" (map Time.millisToPosix int)
        |> required "section_id" (map SectionId int)
        |> optionalMaybe "section" (nullable (lazy (\_ -> sectionDecoder)))
        |> optionalMaybe "rotation_groups" (nullable (map RotationGroups (list (lazy (\_ -> rotationGroupDecoder)))))
        |> optionalMaybe "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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
    , rotation : Maybe Rotation
    , users : Maybe Users

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type RotationGroups
    = RotationGroups (List RotationGroup)


unwrapRotationGroups : RotationGroups -> List RotationGroup
unwrapRotationGroups (RotationGroups l) =
    l


rotationGroupDecoder : Decoder RotationGroup
rotationGroupDecoder =
    Decode.succeed RotationGroup
        |> required "id" (map RotationGroupId int)
        |> required "number" int
        |> optionalMaybe "description" (nullable string)
        |> required "rotation_id" (map RotationId int)
        |> optionalMaybe "rotation" (nullable (lazy (\_ -> rotationDecoder)))
        |> optionalMaybe "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)



-- Account types


type UserId
    = UserId Int


unwrapUserId : UserId -> Int
unwrapUserId (UserId id) =
    id


type RoleId
    = RoleId Int


unwrapRoleId : RoleId -> Int
unwrapRoleId (RoleId id) =
    id


type alias Role =
    { id : RoleId
    , identifier : String
    , name : String
    , abilities : List String
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


roleDecoder : Decoder Role
roleDecoder =
    Decode.succeed Role
        |> required "id" (map RoleId int)
        |> required "identifier" string
        |> required "name" string
        |> required "abilities" (list string)
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


roleEncoder : Role -> Value
roleEncoder role =
    Encode.object
        [ ( "identifier", Encode.string role.identifier )
        , ( "name", Encode.string role.name )
        , ( "abilities", Encode.list Encode.string role.abilities )
        , ( "inserted_at", encodePosix role.insertedAt )
        , ( "updated_at", encodePosix role.updatedAt )
        ]


type alias User =
    { id : UserId
    , email : String
    , firstName : String
    , middleName : Maybe String
    , lastName : String
    , nickname : Maybe String
    , active : Bool

    -- Related data
    , roles : Maybe (List Role)
    , classrooms : Maybe Classrooms
    , sections : Maybe Sections
    , rotationGroups : Maybe RotationGroups

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type Users
    = Users (List User)


unwrapUsers : Users -> List User
unwrapUsers (Users l) =
    l


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "id" (map UserId int)
        |> required "email" string
        |> required "first_name" string
        |> optionalMaybe "middle_name" (nullable string)
        |> required "last_name" string
        |> optionalMaybe "nickname" (nullable string)
        |> required "active" bool
        |> optionalMaybe "roles" (nullable (list (lazy (\_ -> roleDecoder))))
        |> optionalMaybe "classrooms" (nullable (map Classrooms (list (lazy (\_ -> classroomDecoder)))))
        |> optionalMaybe "sections" (nullable (map Sections (list (lazy (\_ -> sectionDecoder)))))
        |> optionalMaybe "rotation_groups" (nullable (map RotationGroups (list (lazy (\_ -> rotationGroupDecoder)))))
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
        , ( "roles", encodeMaybe (Encode.list roleEncoder) user.roles )

        -- Related data @TODO
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
    , classroomId : ClassroomId

    -- Related data
    , parentCategory : Maybe ParentCategory
    , classroom : Maybe Classroom
    , subCategories : Maybe Categories
    , observations : Maybe Observations

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type ParentCategory
    = ParentCategory Category


type Categories
    = Categories (List Category)


unwrapCategories : Categories -> List Category
unwrapCategories (Categories l) =
    l


categoryDecoder : Decoder Category
categoryDecoder =
    Decode.succeed Category
        |> required "id" (map CategoryId int)
        |> required "name" string
        |> required "description" (nullable string)
        |> optionalMaybe "parent_category_id" (nullable (map CategoryId int))
        |> required "classroom_id" (map ClassroomId int)
        |> optionalMaybe "parent_category" (nullable (map ParentCategory (lazy (\_ -> categoryDecoder))))
        |> optionalMaybe "classroom" (nullable (lazy (\_ -> classroomDecoder)))
        |> optionalMaybe "sub_categories" (nullable (map Categories (list (lazy (\_ -> categoryDecoder)))))
        |> optionalMaybe "observations" (nullable (map Observations (list (lazy (\_ -> observationDecoder)))))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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


type alias Observation =
    { id : ObservationId
    , content : String
    , type_ : ObservationType

    -- Foreign keys
    , categoryId : CategoryId

    -- Related data
    , feedback : Maybe FeedbackList

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type Observations
    = Observations (List Observation)


unwrapObservations : Observations -> List Observation
unwrapObservations (Observations l) =
    l


observationDecoder : Decoder Observation
observationDecoder =
    Decode.succeed Observation
        |> required "id" (map ObservationId int)
        |> required "content" string
        |> required "type" observationTypeDecoder
        |> required "category_id" (map CategoryId int)
        |> optionalMaybe "feedback" (nullable (map FeedbackList (list (lazy (\_ -> feedbackDecoder)))))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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
    , observation : Maybe Observation
    , explanations : Maybe Explanations

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type FeedbackList
    = FeedbackList (List Feedback)


unwrapFeedback : FeedbackList -> List Feedback
unwrapFeedback (FeedbackList l) =
    l


feedbackDecoder : Decoder Feedback
feedbackDecoder =
    Decode.succeed Feedback
        |> required "id" (map FeedbackId int)
        |> required "content" string
        |> required "observation_id" (map ObservationId int)
        |> optionalMaybe "observation" (nullable (lazy (\_ -> observationDecoder)))
        |> optionalMaybe "explanations" (nullable (map Explanations (list (lazy (\_ -> explanationDecoder)))))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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

    -- Related data
    , feedback : Maybe Feedback

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type Explanations
    = Explanations (List Explanation)


unwrapExplanations : Explanations -> List Explanation
unwrapExplanations (Explanations l) =
    l


explanationDecoder : Decoder Explanation
explanationDecoder =
    Decode.succeed Explanation
        |> required "id" (map ExplanationId int)
        |> required "content" string
        |> required "feedback_id" (map FeedbackId int)
        |> optionalMaybe "feedback" (nullable (lazy (\_ -> feedbackDecoder)))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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


type alias Draft =
    { id : DraftId
    , content : String
    , status : DraftStatus

    -- Foreign keys
    , studentId : UserId
    , reviewerId : Maybe UserId
    , rotationGroupId : RotationGroupId

    -- Related data
    , student : Maybe User
    , reviewer : Maybe User
    , rotationGroup : Maybe RotationGroup
    , authors : Maybe Users
    , comments : Maybe Comments
    , grades : Maybe Grades

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


draftDecoder : Decoder Draft
draftDecoder =
    Decode.succeed Draft
        |> required "id" (map DraftId int)
        |> required "content" string
        |> required "status" draftStatusDecoder
        |> required "student_id" (map UserId int)
        |> optionalMaybe "reviewer_id" (nullable <| map UserId int)
        |> required "rotation_group_id" (map RotationGroupId int)
        |> optionalMaybe "student" (nullable <| lazy <| \_ -> userDecoder)
        |> optionalMaybe "reviewer" (nullable <| lazy <| \_ -> userDecoder)
        |> optionalMaybe "rotation_group" (nullable (lazy (\_ -> rotationGroupDecoder)))
        |> optionalMaybe "authors" (nullable <| map Users <| list <| lazy <| \_ -> userDecoder)
        |> optionalMaybe "comments" (nullable <| map Comments <| list <| lazy <| \_ -> commentDecoder)
        |> optionalMaybe "grades" (nullable <| map Grades <| list <| lazy <| \_ -> gradeDecoder)
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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

    -- Related data
    , draft : Maybe Draft
    , user : Maybe User

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


type Comments
    = Comments (List Comment)


commentDecoder : Decoder Comment
commentDecoder =
    Decode.succeed Comment
        |> required "id" (map CommentId int)
        |> required "content" string
        |> required "draft_id" (map DraftId int)
        |> required "user_id" (map UserId int)
        |> optionalMaybe "draft" (nullable (lazy (\_ -> draftDecoder)))
        |> optionalMaybe "user" (nullable (lazy (\_ -> userDecoder)))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


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

    -- Related data
    , category : Maybe Category
    , draft : Maybe Draft

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


gradeDecoder : Decoder Grade
gradeDecoder =
    Decode.succeed Grade
        |> required "id" (map GradeId int)
        |> required "score" int
        |> optionalMaybe "note" (nullable string)
        |> required "category_id" (map CategoryId int)
        |> required "draft_id" (map DraftId int)
        |> optionalMaybe "category" (nullable (lazy (\_ -> categoryDecoder)))
        |> optionalMaybe "draft" (nullable (lazy (\_ -> draftDecoder)))
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


type Grades
    = Grades (List Grade)


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

    -- Related data
    , draft : Maybe Draft

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


emailDecoder : Decoder Email
emailDecoder =
    Decode.succeed Email
        |> required "id" (map EmailId int)
        |> required "status" string
        |> required "draft_id" (map DraftId int)
        |> optionalMaybe "draft" (nullable draftDecoder)
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


type alias StudentFeedback =
    { studentId : UserId
    , rotationGroupId : RotationGroupId
    , feedbackId : FeedbackId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


studentFeedbackDecoder : Decoder StudentFeedback
studentFeedbackDecoder =
    Decode.succeed StudentFeedback
        |> required "student_id" (map UserId int)
        |> required "rotation_group_id" (map RotationGroupId int)
        |> required "feedback_id" (map FeedbackId int)
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)


type alias StudentExplanation =
    { studentId : UserId
    , rotationGroupId : RotationGroupId
    , feedbackId : FeedbackId
    , explanationId : ExplanationId

    -- Timestamp data
    , insertedAt : Time.Posix
    , updatedAt : Time.Posix
    }


studentExplanationDecoder : Decoder StudentExplanation
studentExplanationDecoder =
    Decode.succeed StudentExplanation
        |> required "student_id" (map UserId int)
        |> required "rotation_group_id" (map RotationGroupId int)
        |> required "feedback_id" (map FeedbackId int)
        |> required "explanation_id" (map ExplanationId int)
        |> required "inserted_at" (map Time.millisToPosix int)
        |> required "updated_at" (map Time.millisToPosix int)



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
