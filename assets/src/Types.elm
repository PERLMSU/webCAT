module Types exposing (Categories(..), Category, CategoryId(..), Classroom, ClassroomId(..), Classrooms(..), Comment, CommentId(..), Comments(..), Draft, DraftId(..), DraftStatus(..), Email, EmailId(..), Explanation, ExplanationId(..), Explanations(..), Feedback, FeedbackId(..), FeedbackList(..), Grade, GradeId(..), Grades(..), Observation, ObservationId(..), ObservationType(..), Observations(..), ParentCategory(..), Role, Rotation, RotationGroup, RotationGroupId(..), RotationGroups(..), RotationId(..), Rotations(..), Section, SectionId(..), Sections(..), Semester, SemesterId(..), Semesters(..), StudentFeedback, User, UserId(..), Users(..), observationTypeDecoder, roleDecoder, userDecoder)

import Json.Decode as Decode exposing (Decoder, bool, decodeString, field, float, int, lazy, list, map, nullable, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Time as Time



-- Rotation types


type ClassroomId
    = ClassroomId Int


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type Classrooms
    = Classrooms (List Classroom)


classroomDecoder : Decoder Classroom
classroomDecoder =
    Decode.succeed Classroom
        |> required "id" (map ClassroomId int)
        |> required "courseCode" string
        |> required "name" string
        |> required "description" (nullable string)
        |> required "semesters" (nullable (map Semesters (list (lazy (\_ -> semesterDecoder)))))
        |> required "categories" (nullable (map Categories (list (lazy (\_ -> categoryDecoder)))))
        |> required "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type SemesterId
    = SemesterId Int


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type Semesters
    = Semesters (List Semester)


semesterDecoder : Decoder Semester
semesterDecoder =
    Decode.succeed Semester
        |> required "id" (map SemesterId int)
        |> required "name" string
        |> required "description" (nullable string)
        |> required "startDate" (map Time.millisToPosix int)
        |> required "endDate" (map Time.millisToPosix int)
        |> required "classroomId" (map ClassroomId int)
        |> required "classroom" (nullable (lazy (\_ -> classroomDecoder)))
        |> required "sections" (nullable (map Sections (list (lazy (\_ -> sectionDecoder)))))
        |> required "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type SectionId
    = SectionId Int


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type Sections
    = Sections (List Section)


sectionDecoder : Decoder Section
sectionDecoder =
    Decode.succeed Section
        |> required "id" (map SectionId int)
        |> required "number" string
        |> required "description" (nullable string)
        |> required "semesterId" (map SemesterId int)
        |> required "semester" (nullable (lazy (\_ -> semesterDecoder)))
        |> required "rotations" (nullable (map Rotations (list (lazy (\_ -> rotationDecoder)))))
        |> required "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type RotationId
    = RotationId Int


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type Rotations
    = Rotations (List Rotation)


rotationDecoder : Decoder Rotation
rotationDecoder =
    Decode.succeed Rotation
        |> required "id" (map RotationId int)
        |> required "number" int
        |> required "description" (nullable string)
        |> required "startDate" (map Time.millisToPosix int)
        |> required "endDate" (map Time.millisToPosix int)
        |> required "sectionId" (map SectionId int)
        |> required "section" (nullable (lazy (\_ -> sectionDecoder)))
        |> required "rotationGroups" (nullable (map RotationGroups (list (lazy (\_ -> rotationGroupDecoder)))))
        |> required "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type RotationGroupId
    = RotationGroupId Int


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type RotationGroups
    = RotationGroups (List RotationGroup)


rotationGroupDecoder : Decoder RotationGroup
rotationGroupDecoder =
    Decode.succeed RotationGroup
        |> required "id" (map RotationGroupId int)
        |> required "number" int
        |> required "description" (nullable string)
        |> required "rotationId" (map RotationId int)
        |> required "rotation" (nullable (lazy (\_ -> rotationDecoder)))
        |> required "users" (nullable (map Users (list (lazy (\_ -> userDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))



-- Account types


type UserId
    = UserId Int


type alias Role =
    { identifier : String
    , name : String
    }


roleDecoder : Decoder Role
roleDecoder =
    Decode.succeed Role
        |> required "identifier" string
        |> required "name" string


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type Users
    = Users (List User)


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "id" (map UserId int)
        |> required "email" string
        |> required "firstName" string
        |> required "middleName" (nullable string)
        |> required "lastName" string
        |> required "nickName" (nullable string)
        |> required "active" bool
        |> required "roles" (nullable (list (lazy (\_ -> roleDecoder))))
        |> required "classrooms" (nullable (map Classrooms (list (lazy (\_ -> classroomDecoder)))))
        |> required "sections" (nullable (map Sections (list (lazy (\_ -> sectionDecoder)))))
        |> required "rotationGroups" (nullable (map RotationGroups (list (lazy (\_ -> rotationGroupDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))



-- Feedback types


type CategoryId
    = CategoryId Int


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type ParentCategory
    = ParentCategory Category


type Categories
    = Categories (List Category)


categoryDecoder : Decoder Category
categoryDecoder =
    Decode.succeed Category
        |> required "id" (map CategoryId int)
        |> required "name" string
        |> required "description" (nullable string)
        |> required "parentCategoryId" (nullable (map CategoryId int))
        |> required "classroomId" (map ClassroomId int)
        |> required "parentCategory" (nullable (map ParentCategory (lazy (\_ -> categoryDecoder))))
        |> required "classroom" (nullable (lazy (\_ -> classroomDecoder)))
        |> required "subCategories" (nullable (map Categories (list (lazy (\_ -> categoryDecoder)))))
        |> required "observations" (nullable (map Observations (list (lazy (\_ -> observationDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type ObservationId
    = ObservationId Int


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type Observations
    = Observations (List Observation)


observationDecoder : Decoder Observation
observationDecoder =
    Decode.succeed Observation
        |> required "id" (map ObservationId int)
        |> required "content" string
        |> required "type" observationTypeDecoder
        |> required "categoryId" (map CategoryId int)
        |> required "subCategories" (nullable (map FeedbackList (list (lazy (\_ -> feedbackDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type FeedbackId
    = FeedbackId Int


type alias Feedback =
    { id : FeedbackId
    , content : String

    -- Foreign keys
    , observationId : ObservationId

    -- Related data
    , observation : Maybe Observation
    , explanations : Maybe Explanations

    -- Timestamp data
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type FeedbackList
    = FeedbackList (List Feedback)


feedbackDecoder : Decoder Feedback
feedbackDecoder =
    Decode.succeed Feedback
        |> required "id" (map FeedbackId int)
        |> required "content" string
        |> required "observationId" (map ObservationId int)
        |> required "observation" (nullable (lazy (\_ -> observationDecoder)))
        |> required "explanations" (nullable (map Explanations (list (lazy (\_ -> explanationDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type ExplanationId
    = ExplanationId Int


type alias Explanation =
    { id : ExplanationId
    , content : String

    -- Foreign keys
    , feedbackId : FeedbackId

    -- Related data
    , feedback : Maybe Feedback

    -- Timestamp data
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type Explanations
    = Explanations (List Explanation)

explanationDecoder : Decoder Explanation
explanationDecoder =
    Decode.succeed Explanation
        |> required "id" (map ExplanationId int)
        |> required "content" string
        |> required "feedbackId" (map FeedbackId int)
        |> required "feedback" (nullable (lazy (\_ -> feedbackDecoder)))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type DraftId
    = DraftId Int


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
                    "unreviewed" -> Decode.succeed Unreviewed
                    "reviewing" -> Decode.succeed Reviewing
                    "needs_revision" -> Decode.succeed NeedsRevision
                    "approved" -> Decode.succeed Approved
                    "emailed" -> Decode.succeed Emailed


                    else_ ->
                        Decode.fail <| "Unknown draft status: " ++ else_
            )

type alias Draft =
    { id : DraftId
    , content : String
    , status : DraftStatus

    -- Foreign keys
    , userId : UserId
    , rotationGroupId : RotationGroupId

    -- Related data
    , user : Maybe User
    , rotationGroup : Maybe RotationGroup
    , comments : Maybe Comments
    , grades : Maybe Grades

    -- Timestamp data
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }

draftDecoder : Decoder Draft
draftDecoder =
    Decode.succeed Draft
        |> required "id" (map DraftId int)
        |> required "content" string
        |> required "status" draftStatusDecoder
        |> required "userId" (map UserId int)
        |> required "rotationGroupId" (map RotationGroupId int)
        |> required "user" (nullable (lazy (\_ -> userDecoder)))
        |> required "rotationGroup" (nullable (lazy (\_ -> rotationGroupDecoder)))
        |> required "comments" (nullable (map Comments (list (lazy (\_ -> commentDecoder)))))
        |> required "grades" (nullable (map Grades (list (lazy (\_ -> gradeDecoder)))))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))

type CommentId
    = CommentId Int


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type Comments
    = Comments (List Comment)

commentDecoder : Decoder Comment
commentDecoder =
    Decode.succeed Comment
        |> required "id" (map CommentId int)
        |> required "content" string
        |> required "draftId" (map DraftId int)
        |> required "userId" (map UserId int)
        |> required "draft" (nullable (lazy (\_ -> draftDecoder)))
        |> required "user" (nullable (lazy (\_ -> userDecoder)))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type GradeId
    = GradeId Int


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
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


gradeDecoder : Decoder Grade
gradeDecoder =
    Decode.succeed Grade
        |> required "id" (map GradeId int)
        |> required "score" int
        |> required "note" (nullable string)
        |> required "categoryId" (map CategoryId int)
        |> required "draftId" (map DraftId int)
        |> required "category" (nullable (lazy (\_ -> categoryDecoder)))
        |> required "draft" (nullable (lazy (\_ -> draftDecoder)))
        |> required "insertedAt" (nullable (map Time.millisToPosix int))
        |> required "updatedAt" (nullable (map Time.millisToPosix int))


type Grades
    = Grades (List Grade)


type EmailId
    = EmailId Int


type alias Email =
    { id : EmailId
    , status : String

    -- Foreign keys
    , draftIf : DraftId

    -- Related data
    , draft : Maybe Draft

    -- Timestamp data
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }


type alias StudentFeedback =
    { userId : UserId
    , rotationGroupId : RotationGroupId
    , feedbackId : FeedbackId

    -- Related data
    , user : Maybe User
    , rotationGroup : Maybe RotationGroup
    , feedback : Maybe Feedback

    -- Timestamp data
    , insertedAt : Maybe Time.Posix
    , updatedAt : Maybe Time.Posix
    }
