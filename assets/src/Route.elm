module Route exposing (LoginToken(..), PasswordResetToken(..), Route(..), fromUrl, pushUrl, replaceUrl)

import Browser.Navigation as Nav
import Types exposing (ClassroomId(..), DraftId(..), RotationGroupId(..), RotationId(..), SectionId(..), SemesterId(..), UserId(..))
import Url exposing (Url)
import Url.Builder as Builder exposing (absolute)
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
    | Root


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (routeToString route)


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
        [ Parser.map Root top
        , Parser.map Dashboard (s "dashboard" <?> idQueryParser ClassroomId "classroomId")

        -- Login
        , Parser.map Login (s "login" <?> tokenQueryParser LoginToken "loginToken")
        , Parser.map ForgotPassword (s "forgotPassword" <?> tokenQueryParser PasswordResetToken "resetToken")

        -- Classroom control panel
        , s "classrooms"
            </> oneOf
                    [ Parser.map Classrooms top
                    , Parser.map Classroom (Parser.map ClassroomId int)
                    , Parser.map NewClassroom (s "new")
                    , Parser.map EditClassroom (Parser.map ClassroomId int </> s "edit")
                    ]
        , s "semesters"
            </> oneOf
                    [ Parser.map Semesters (top <?> idQueryParser ClassroomId "classroomId")
                    , Parser.map Semester (Parser.map SemesterId int)
                    , Parser.map NewSemester (s "new" <?> idQueryParser ClassroomId "classroomId")
                    , Parser.map EditSemester (Parser.map SemesterId int </> s "edit")
                    ]
        , s "sections"
            </> oneOf
                    [ Parser.map Sections (top <?> idQueryParser SemesterId "semesterId")
                    , Parser.map Section (Parser.map SectionId int)
                    , Parser.map NewSection (s "new" <?> idQueryParser SemesterId "semesterId")
                    , Parser.map EditSection (Parser.map SectionId int </> s "edit")
                    ]
        , s "rotations"
            </> oneOf
                    [ Parser.map Rotations (top <?> idQueryParser SectionId "sectionId")
                    , Parser.map Rotation (Parser.map RotationId int)
                    , Parser.map NewRotation (s "new" <?> idQueryParser SectionId "sectionId")
                    , Parser.map EditRotation (Parser.map RotationId int </> s "edit")
                    ]
        , s "rotationGroups"
            </> oneOf
                    [ Parser.map RotationGroups (top <?> idQueryParser RotationId "rotationId")
                    , Parser.map RotationGroup (Parser.map RotationGroupId int)
                    , Parser.map NewRotationGroup (s "new" <?> idQueryParser RotationId "rotationId")
                    , Parser.map EditRotationGroup (Parser.map RotationGroupId int </> s "edit")
                    ]
        , s "users"
            </> oneOf
                    [ Parser.map Users top
                    , Parser.map User (Parser.map UserId int)
                    , Parser.map NewUser (s "new")
                    , Parser.map EditUser (Parser.map UserId int </> s "edit")
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
                    , Parser.map EditDraft (Parser.map DraftId int </> s "edit")
                    ]
        , Parser.map Profile (s "profile")
        ]


routeToString : Route -> String
routeToString route =
    case route of
        Root ->
            absolute [] []

        Dashboard maybeId ->
            absolute [ "dashboard" ] (Maybe.withDefault [] (Maybe.map (\(ClassroomId id) -> [ Builder.int "classroomId" id ]) maybeId))

        Login maybeToken ->
            absolute [ "login" ] (Maybe.withDefault [] (Maybe.map (\(LoginToken token) -> [ Builder.string "loginToken" token ]) maybeToken))

        ForgotPassword maybeToken ->
            absolute [ "forgotPassword" ] (Maybe.withDefault [] (Maybe.map (\(PasswordResetToken token) -> [ Builder.string "loginToken" token ]) maybeToken))

        -- Classrooms
        Classrooms ->
            absolute [ "classrooms" ] []

        Classroom (ClassroomId id) ->
            absolute [ "classrooms", String.fromInt id ] []

        NewClassroom ->
            absolute [ "classrooms", "new" ] []

        EditClassroom (ClassroomId id) ->
            absolute [ "classrooms", String.fromInt id, "edit" ] []

        -- Semesters
        Semesters maybeId ->
            absolute [ "semesters" ] (Maybe.withDefault [] (Maybe.map (\(ClassroomId id) -> [ Builder.int "classroomId" id ]) maybeId))

        Semester (SemesterId id) ->
            absolute [ "semesters", String.fromInt id ] []

        NewSemester maybeId ->
            absolute [ "semesters", "new" ] (Maybe.withDefault [] (Maybe.map (\(ClassroomId id) -> [ Builder.int "classroomId" id ]) maybeId))

        EditSemester (SemesterId id) ->
            absolute [ "semesters", String.fromInt id, "edit" ] []

        -- Sections
        Sections maybeId ->
            absolute [ "sections" ] (Maybe.withDefault [] (Maybe.map (\(SemesterId id) -> [ Builder.int "semesterId" id ]) maybeId))

        Section (SectionId id) ->
            absolute [ "sections", String.fromInt id ] []

        NewSection maybeId ->
            absolute [ "sections", "new" ] (Maybe.withDefault [] (Maybe.map (\(SemesterId id) -> [ Builder.int "semesterId" id ]) maybeId))

        EditSection (SectionId id) ->
            absolute [ "sections", String.fromInt id, "edit" ] []

        -- Rotations
        Rotations maybeId ->
            absolute [ "rotations" ] (Maybe.withDefault [] (Maybe.map (\(SectionId id) -> [ Builder.int "sectionId" id ]) maybeId))

        Rotation (RotationId id) ->
            absolute [ "rotations", String.fromInt id ] []

        NewRotation maybeId ->
            absolute [ "rotations", "new" ] (Maybe.withDefault [] (Maybe.map (\(SectionId id) -> [ Builder.int "sectionId" id ]) maybeId))

        EditRotation (RotationId id) ->
            absolute [ "rotations", String.fromInt id, "edit" ] []

        -- Rotation Groups
        RotationGroups maybeId ->
            absolute [ "rotationGroups" ] (Maybe.withDefault [] (Maybe.map (\(RotationId id) -> [ Builder.int "rotationId" id ]) maybeId))

        RotationGroup (RotationGroupId id) ->
            absolute [ "rotationGroups", String.fromInt id ] []

        NewRotationGroup maybeId ->
            absolute [ "rotationGroups", "new" ] (Maybe.withDefault [] (Maybe.map (\(RotationId id) -> [ Builder.int "rotationId" id ]) maybeId))

        EditRotationGroup (RotationGroupId id) ->
            absolute [ "rotationGroups", String.fromInt id, "edit" ] []

        -- Users
        Users ->
            absolute [ "users" ] []

        User (UserId id) ->
            absolute [ "users", String.fromInt id ] []

        NewUser ->
            absolute [ "users", "new" ] []

        EditUser (UserId id) ->
            absolute [ "users", String.fromInt id, "edit" ] []

        -- Users
        Drafts ->
            absolute [ "drafts" ] []

        Draft (DraftId id) ->
            absolute [ "drafts", String.fromInt id ] []

        NewDraft (RotationGroupId groupId) (UserId userId) ->
            absolute [ "drafts", "new" ] []

        EditDraft (DraftId id) ->
            absolute [ "drafts", String.fromInt id, "edit" ] []

        Import ->
            absolute [ "import" ] []

        Feedback ->
            absolute [ "feedback" ] []

        Profile ->
            absolute [ "profile" ] []
