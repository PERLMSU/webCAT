module Route exposing (LoginToken(..), PasswordResetToken(..), Route(..), fromUrl, href, pushUrl, replaceUrl, routeToString)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Types exposing (CategoryId(..), ClassroomId(..), DraftId(..), RotationGroupId(..), RotationId(..), SectionId(..), SemesterId(..), UserId(..))
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
    | Logout
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
      -- Feedback System
    | DraftClassrooms
    | DraftRotations SectionId
    | Draft DraftId
    | EditFeedback DraftId (Maybe CategoryId)
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


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


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


applicationRoot : String
applicationRoot =
    "app"


appAbsolute : List String -> List Builder.QueryParameter -> String
appAbsolute paths query =
    absolute (applicationRoot :: paths) query


parser : Parser (Route -> a) a
parser =
    s applicationRoot
        </> oneOf
                [ Parser.map Root top
                , Parser.map Dashboard (s "dashboard" <?> idQueryParser ClassroomId "classroomId")

                -- Login
                , Parser.map Login (s "login" <?> tokenQueryParser LoginToken "loginToken")
                , Parser.map Logout (s "logout")
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


                -- Inbox
                , s "drafts"
                    </> oneOf
                            [ Parser.map DraftClassrooms top
                            , Parser.map DraftRotations (s "sections" </> Parser.map SectionId int)
                            , Parser.map Draft (Parser.map DraftId int)
                            , Parser.map EditFeedback (Parser.map DraftId int </> s "feedback" <?> idQueryParser CategoryId "categoryId")
                            ]
                , Parser.map Profile (s "profile")
                ]


routeToString : Route -> String
routeToString route =
    case route of
        Root ->
            appAbsolute [] []

        Dashboard maybeId ->
            appAbsolute [ "dashboard" ] (Maybe.withDefault [] (Maybe.map (\(ClassroomId id) -> [ Builder.int "classroomId" id ]) maybeId))

        Login maybeToken ->
            appAbsolute [ "login" ] (Maybe.withDefault [] (Maybe.map (\(LoginToken token) -> [ Builder.string "loginToken" token ]) maybeToken))

        Logout ->
            appAbsolute [ "logout" ] []

        ForgotPassword maybeToken ->
            appAbsolute [ "forgotPassword" ] (Maybe.withDefault [] (Maybe.map (\(PasswordResetToken token) -> [ Builder.string "resetToken" token ]) maybeToken))

        -- Classrooms
        Classrooms ->
            appAbsolute [ "classrooms" ] []

        Classroom (ClassroomId id) ->
            appAbsolute [ "classrooms", String.fromInt id ] []

        NewClassroom ->
            appAbsolute [ "classrooms", "new" ] []

        EditClassroom (ClassroomId id) ->
            appAbsolute [ "classrooms", String.fromInt id, "edit" ] []

        -- Semesters
        Semesters maybeId ->
            appAbsolute [ "semesters" ] (Maybe.withDefault [] (Maybe.map (\(ClassroomId id) -> [ Builder.int "classroomId" id ]) maybeId))

        Semester (SemesterId id) ->
            appAbsolute [ "semesters", String.fromInt id ] []

        NewSemester maybeId ->
            appAbsolute [ "semesters", "new" ] (Maybe.withDefault [] (Maybe.map (\(ClassroomId id) -> [ Builder.int "classroomId" id ]) maybeId))

        EditSemester (SemesterId id) ->
            appAbsolute [ "semesters", String.fromInt id, "edit" ] []

        -- Sections
        Sections maybeId ->
            appAbsolute [ "sections" ] (Maybe.withDefault [] (Maybe.map (\(SemesterId id) -> [ Builder.int "semesterId" id ]) maybeId))

        Section (SectionId id) ->
            appAbsolute [ "sections", String.fromInt id ] []

        NewSection maybeId ->
            appAbsolute [ "sections", "new" ] (Maybe.withDefault [] (Maybe.map (\(SemesterId id) -> [ Builder.int "semesterId" id ]) maybeId))

        EditSection (SectionId id) ->
            appAbsolute [ "sections", String.fromInt id, "edit" ] []

        -- Rotations
        Rotations maybeId ->
            appAbsolute [ "rotations" ] (Maybe.withDefault [] (Maybe.map (\(SectionId id) -> [ Builder.int "sectionId" id ]) maybeId))

        Rotation (RotationId id) ->
            appAbsolute [ "rotations", String.fromInt id ] []

        NewRotation maybeId ->
            appAbsolute [ "rotations", "new" ] (Maybe.withDefault [] (Maybe.map (\(SectionId id) -> [ Builder.int "sectionId" id ]) maybeId))

        EditRotation (RotationId id) ->
            appAbsolute [ "rotations", String.fromInt id, "edit" ] []

        -- Rotation Groups
        RotationGroups maybeId ->
            appAbsolute [ "rotationGroups" ] (Maybe.withDefault [] (Maybe.map (\(RotationId id) -> [ Builder.int "rotationId" id ]) maybeId))

        RotationGroup (RotationGroupId id) ->
            appAbsolute [ "rotationGroups", String.fromInt id ] []

        NewRotationGroup maybeId ->
            appAbsolute [ "rotationGroups", "new" ] (Maybe.withDefault [] (Maybe.map (\(RotationId id) -> [ Builder.int "rotationId" id ]) maybeId))

        EditRotationGroup (RotationGroupId id) ->
            appAbsolute [ "rotationGroups", String.fromInt id, "edit" ] []

        -- Users
        Users ->
            appAbsolute [ "users" ] []

        User (UserId id) ->
            appAbsolute [ "users", String.fromInt id ] []

        NewUser ->
            appAbsolute [ "users", "new" ] []

        EditUser (UserId id) ->
            appAbsolute [ "users", String.fromInt id, "edit" ] []

        -- Drafts
        DraftClassrooms ->
            appAbsolute [ "drafts" ] []

        DraftRotations (SectionId id) ->
            appAbsolute ["drafts", "sections", String.fromInt id] []

        Draft (DraftId id) ->
            appAbsolute [ "drafts", String.fromInt id ] []


        EditFeedback (DraftId draftId) maybeCategoryId ->
            appAbsolute [ "drafts", String.fromInt draftId, "feedback"] (Maybe.withDefault [] (Maybe.map (\(CategoryId id) -> [ Builder.int "categoryId" id ]) maybeCategoryId))
        -- Profile
        Profile ->
            appAbsolute [ "profile" ] []
