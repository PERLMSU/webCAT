module Route exposing (Route)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, int, oneOf, s, string, top)
import Url.Parser.Query as Query



-- ID Types


type alias ClassroomID =
    Int


type alias SemesterID =
    Int


type alias SectionID =
    Int


type alias RotationID =
    Int


type alias RotationGroupID =
    Int


type alias UserID =
    Int


type alias DraftID =
    Int


type alias PasswordResetToken =
    String


type alias LoginToken =
    String


type Route
    = Dashboard (Maybe ClassroomID)
      -- Login routes
    | Login (Maybe LoginToken)
    | ForgotPassword (Maybe PasswordResetToken)
      -- Classroom control panel
    | Classrooms
    | Classroom ClassroomID
    | NewClassroom
    | EditClassroom ClassroomID
      -- Semester control panel
    | Semesters (Maybe ClassroomID)
    | Semester SemesterID
    | NewSemester (Maybe ClassroomID)
    | EditSemester SemesterID
      -- Section control panel
    | Sections (Maybe SemesterID)
    | Section SectionID
    | NewSection (Maybe SemesterID)
    | EditSection SectionID
      -- Rotation control panel
    | Rotations (Maybe SectionID)
    | Rotation RotationID
    | NewRotation (Maybe SectionID)
    | EditRotation RotationID
      -- Rotation Group control panel
    | RotationGroups (Maybe RotationID)
    | RotationGroup RotationGroupID
    | NewRotationGroup (Maybe RotationID)
    | EditRotationGroup RotationGroupID
      -- User control panel
    | Users
    | User UserID
    | NewUser
    | EditUser UserID
      -- Import
    | Import
      -- Feedback System
    | Feedback
      -- Draft inbox
    | Drafts
    | Draft DraftID
    | NewDraft RotationGroupID UserID
    | EditDraft DraftID
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


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Dashboard (top <?> Query.string "classroom_id")

        -- Login
        , Parser.map Login (s "login" <?> Query.string "login_token")
        , Parser.map ForgotPassword (s "forgot_password" <?> Query.string "reset_token")

        -- Classroom control panel
        , s "classrooms"
            </> oneOf
                    [ Parser.map Classrooms top
                    , Parser.map Classroom int
                    , Parser.map NewClassroom (s "new")
                    , Parser.map EditClassroom (s "edit" </> int)
                    ]
        , s "semesters"
            </> oneOf
                    [ Parser.map Semesters top
                    , Parser.map Semester int
                    , Parser.map NewClassroom (s "new")
                    , Parser.map EditClassroom (s "edit" </> int)
                    ]
        , s "sections"
            </> oneOf
                    [ Parser.map Sections top
                    , Parser.map Section int
                    , Parser.map NewSection (s "new")
                    , Parser.map EditClassroom (s "edit" </> int)
                    ]
        , s "rotations"
            </> oneOf
                    [ Parser.map Rotations top
                    , Parser.map Rotation int
                    , Parser.map NewRotation (s "new")
                    , Parser.map EditRotation (s "edit" </> int)
                    ]
        , s "rotation_groups"
            </> oneOf
                    [ Parser.map RotationGroups top
                    , Parser.map RotationGroup int
                    , Parser.map NewRotation (s "new")
                    , Parser.map EditRotation (s "edit" </> int)
                    ]
        , s "users"
            </> oneOf
                    [ Parser.map Users top
                    , Parser.map User int
                    , Parser.map NewUser (s "new")
                    , Parser.map EditUser (s "edit" </> int)
                    ]

        -- Import
        , Parser.map Import (s "import")

        -- Feedback
        , Parser.map Feedback (s "feedback")

        -- Inbox
        , s "drafts"
            </> oneOf
                    [ Parser.map Drafts top
                    , Parser.map Draft int
                    , Parser.map NewDraft (s "new" </> int </> int)
                    , Parser.map EditDraft (s "edit" </> int)
                    ]
        , Parser.map Profile (s "profile")
        ]
