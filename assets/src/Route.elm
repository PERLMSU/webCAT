module Route exposing (Route)

import Browser.Navigation as Nav
import Types exposing (ClassroomId(..), DraftId(..), RotationGroupId(..), RotationId(..), SectionId(..), SemesterId(..), UserId(..))
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, int, map, oneOf, s, string, top)
import Url.Parser.Query as Query


type PasswordResetToken
    = PasswordResetToken String


type LoginToken
    = LoginToken String


type Route
    = Dashboard (Maybe ClassroomId)
      -- Login routes
    | Login (Maybe LoginToken)
    | ForgotPassword (Maybe PasswordResetToken)
      -- Classroom control panel
    | Classrooms
    | Classroom ClassroomId
    | NewClassroom
    | EditClassroom ClassroomId
      -- Semester control panel
    | Semesters (Maybe ClassroomId)
    | Semester SemesterId
    | NewSemester (Maybe ClassroomId)
    | EditSemester SemesterId
      -- Section control panel
    | Sections (Maybe SemesterId)
    | Section SectionId
    | NewSection (Maybe SemesterId)
    | EditSection SectionId
      -- Rotation control panel
    | Rotations (Maybe SectionId)
    | Rotation RotationId
    | NewRotation (Maybe SectionId)
    | EditRotation RotationId
      -- Rotation Group control panel
    | RotationGroups (Maybe RotationId)
    | RotationGroup RotationGroupId
    | NewRotationGroup (Maybe RotationId)
    | EditRotationGroup RotationGroupId
      -- User control panel
    | Users
    | User UserId
    | NewUser
    | EditUser UserId
      -- Import
    | Import
      -- Feedback System
    | Feedback
      -- Draft inbox
    | Drafts
    | Draft DraftId
    | NewDraft RotationGroupId UserId
    | EditDraft DraftId
      -- Profile
    | Profile
      -- Utility
    | NotFound


toRoute : String -> Route
toRoute string =
    case Url.fromString string of
        Nothing ->
            NotFound

        Just url ->
            Maybe.withDefault NotFound (Parser.parse parser url)


idQueryParser : (Int -> a) -> String -> Query.Parser (Maybe a)
idQueryParser id key =
    Query.custom key <|
        \stringList ->
            case stringList of
                [ str ] ->
                    case String.toInt str of
                        Just int ->
                            Just (id int)

                        _ ->
                            Nothing

                _ ->
                    Nothing


tokenQueryParser : (String -> a) -> String -> Query.Parser (Maybe a)
tokenQueryParser id key =
    Query.custom key <|
        \stringList ->
            case stringList of
                [ str ] ->
                    Just (id str)

                _ ->
                    Nothing


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Dashboard (s "dashboard" <?> idQueryParser ClassroomId "classroomId")

        -- Login
        , Parser.map Login (s "login" <?> tokenQueryParser LoginToken "loginToken")
        , Parser.map ForgotPassword (s "forgotPassword" <?> tokenQueryParser PasswordResetToken "resetToken")

        -- Classroom control panel
        , s "classrooms"
            </> oneOf
                    [ Parser.map Classrooms top
                    , Parser.map Classroom (Parser.map ClassroomId int)
                    , Parser.map NewClassroom (s "new")
                    , Parser.map EditClassroom (s "edit" </> Parser.map ClassroomId int)
                    ]
        , s "semesters"
            </> oneOf
                    [ Parser.map Semesters (top <?> idQueryParser ClassroomId "classroomId")
                    , Parser.map Semester (Parser.map SemesterId int)
                    , Parser.map NewSemester (s "new" <?> idQueryParser ClassroomId "classroomId")
                    , Parser.map EditSemester (s "edit" </> Parser.map SemesterId int)
                    ]
        , s "sections"
            </> oneOf
                    [ Parser.map Sections (top <?> idQueryParser SemesterId "semesterId")
                    , Parser.map Section (Parser.map SectionId int)
                    , Parser.map NewSection (s "new" <?> idQueryParser SemesterId "semesterId")
                    , Parser.map EditSection (s "edit" </> Parser.map SectionId int)
                    ]
        , s "rotations"
            </> oneOf
                    [ Parser.map Rotations (top <?> idQueryParser SectionId "sectionId")
                    , Parser.map Rotation (Parser.map RotationId int)
                    , Parser.map NewRotation (s "new" <?> idQueryParser SectionId "sectionId")
                    , Parser.map EditRotation (s "edit" </> Parser.map RotationId int)
                    ]
        , s "rotation_groups"
            </> oneOf
                    [ Parser.map RotationGroups (top <?> idQueryParser RotationId "rotationId")
                    , Parser.map RotationGroup (Parser.map RotationGroupId int)
                    , Parser.map NewRotationGroup (s "new" <?> idQueryParser RotationId "rotationId")
                    , Parser.map EditRotationGroup (s "edit" </> Parser.map RotationGroupId int)
                    ]
        , s "users"
            </> oneOf
                    [ Parser.map Users top
                    , Parser.map User (Parser.map UserId int)
                    , Parser.map NewUser (s "new")
                    , Parser.map EditUser (s "edit" </> Parser.map UserId int)
                    ]

        -- Import
        , Parser.map Import (s "import")

        -- Feedback
        , Parser.map Feedback (s "feedback")

        -- Inbox
        , s "drafts"
            </> oneOf
                    [ Parser.map Drafts top
                    , Parser.map Draft (Parser.map DraftId int)
                    , Parser.map NewDraft (s "new" </> Parser.map RotationGroupId int </> Parser.map UserId int)
                    , Parser.map EditDraft (s "edit" </> Parser.map DraftId int)
                    ]
        , Parser.map Profile (s "profile")
        ]
