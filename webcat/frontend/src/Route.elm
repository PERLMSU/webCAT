module Route exposing (Route(..), fromUrl, href, pushUrl, replaceUrl, routeToString)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Maybe.Extra exposing (..)
import Types exposing (..)
import Url exposing (Url)
import Url.Builder as Builder exposing (absolute)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, int, map, oneOf, s, string, top)
import Url.Parser.Query as Query


type alias PasswordResetToken =
    String


type Route
    = Dashboard
      -- Login routes
    | Login
    | Logout
    | ResetPassword (Maybe PasswordResetToken)
      -- Classroom control panel
    | Classrooms
    | Classroom ClassroomId
      -- Semester control panel
    | Semesters
    | Semester SemesterId
      -- Section control panel
    | Sections (Maybe ClassroomId) (Maybe SemesterId)
    | Section SectionId
      -- Rotation control panel
    | Rotations (Maybe SectionId)
    | Rotation RotationId
      -- Rotation Group control panel
    | RotationGroups (Maybe RotationId)
    | RotationGroup RotationGroupId
      -- Categories
    | Categories (Maybe CategoryId)
    | Category CategoryId
      -- Observations
    | Observations (Maybe CategoryId)
    | Observation ObservationId
      -- Feedback
    | Feedback (Maybe ObservationId)
    | FeedbackItem FeedbackId
      -- Explanations
    | Explanations (Maybe FeedbackId)
    | Explanation ExplanationId
      -- User control panel
    | Users
    | User UserId
      -- Feedback System
    | DraftClassrooms
    | DraftRotations SectionId
    | GroupDrafts RotationGroupId
    | Draft RotationGroupId DraftId
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
                , Parser.map Dashboard (s "dashboard")

                -- Login
                , Parser.map Login (s "login")
                , Parser.map Logout (s "logout")
                , Parser.map ResetPassword (s "forgotPassword" <?> Query.string "token")

                -- Classroom control panel
                , s "classrooms"
                    </> oneOf
                            [ Parser.map Classrooms top
                            , Parser.map Classroom (Parser.map ClassroomId int)
                            ]
                , s "semesters"
                    </> oneOf
                            [ Parser.map Semesters top
                            , Parser.map Semester (Parser.map SemesterId int)
                            ]
                , s "sections"
                    </> oneOf
                            [ Parser.map Sections (top <?> idQueryParser ClassroomId "classroomId" <?> idQueryParser SemesterId "semesterId")
                            , Parser.map Section (Parser.map SectionId int)
                            ]
                , s "rotations"
                    </> oneOf
                            [ Parser.map Rotations (top <?> idQueryParser SectionId "sectionId")
                            , Parser.map Rotation (Parser.map RotationId int)
                            ]
                , s "rotationGroups"
                    </> oneOf
                            [ Parser.map RotationGroups (top <?> idQueryParser RotationId "rotationId")
                            , Parser.map RotationGroup (Parser.map RotationGroupId int)
                            ]
                , s "categories"
                    </> oneOf
                            [ Parser.map Categories (top <?> idQueryParser CategoryId "parentCategoryId")
                            , Parser.map Category (Parser.map CategoryId int)
                            ]
                , s "observations"
                    </> oneOf
                            [ Parser.map Observations (top <?> idQueryParser CategoryId "categoryId")
                            , Parser.map Observation (Parser.map ObservationId int)
                            ]
                , s "feedback"
                    </> oneOf
                            [ Parser.map Feedback (top <?> idQueryParser ObservationId "observationId")
                            , Parser.map FeedbackItem (Parser.map FeedbackId int)
                            ]
                , s "explanations"
                    </> oneOf
                            [ Parser.map Explanations (top <?> idQueryParser FeedbackId "feedbackId")
                            , Parser.map Explanation (Parser.map ExplanationId int)
                            ]
                , s "users"
                    </> oneOf
                            [ Parser.map Users top
                            , Parser.map User (Parser.map UserId int)
                            ]

                -- Inbox
                , s "drafts"
                    </> oneOf
                            [ Parser.map DraftClassrooms top
                            , Parser.map DraftRotations (s "sections" </> Parser.map SectionId int)
                            , Parser.map GroupDrafts (s "groups" </> Parser.map RotationGroupId int)
                            , Parser.map Draft (s "groups" </> Parser.map RotationGroupId int </> Parser.map DraftId int)
                            , Parser.map EditFeedback (Parser.map DraftId int </> s "feedback" <?> idQueryParser CategoryId "categoryId")
                            ]
                , Parser.map Profile (s "profile")
                ]


routeToString : Route -> String
routeToString route =
    case route of
        Root ->
            appAbsolute [] []

        Dashboard ->
            appAbsolute [ "dashboard" ] []

        Login ->
            appAbsolute [ "login" ] []

        Logout ->
            appAbsolute [ "logout" ] []

        ResetPassword maybeToken ->
            appAbsolute [ "forgotPassword" ] <| toList (Maybe.map (Builder.string "token") maybeToken)

        -- Classrooms
        Classrooms ->
            appAbsolute [ "classrooms" ] []

        Classroom (ClassroomId id) ->
            appAbsolute [ "classrooms", String.fromInt id ] []

        -- Semesters
        Semesters ->
            appAbsolute [ "semesters" ] []

        Semester (SemesterId id) ->
            appAbsolute [ "semesters", String.fromInt id ] []

        -- Sections
        Sections maybeClassroomId maybeSemesterId ->
            appAbsolute [ "sections" ] <| values [ Maybe.map (unwrapClassroomId >> Builder.int "classroomId") maybeClassroomId, Maybe.map (unwrapSemesterId >> Builder.int "semesterId") maybeSemesterId ]

        Section (SectionId id) ->
            appAbsolute [ "sections", String.fromInt id ] []

        -- Rotations
        Rotations maybeId ->
            appAbsolute [ "rotations" ] <| toList (Maybe.map (unwrapSectionId >> Builder.int "sectionId") maybeId)

        Rotation (RotationId id) ->
            appAbsolute [ "rotations", String.fromInt id ] []

        -- Rotation Groups
        RotationGroups maybeId ->
            appAbsolute [ "rotationGroups" ] <| toList (Maybe.map (unwrapRotationId >> Builder.int "rotationId") maybeId)

        RotationGroup (RotationGroupId id) ->
            appAbsolute [ "rotationGroups", String.fromInt id ] []

        -- Categories
        Categories maybeId ->
            appAbsolute [ "categories" ] <| toList (Maybe.map (unwrapCategoryId >> Builder.int "parentCategoryId") maybeId)

        Category (CategoryId id) ->
            appAbsolute [ "categories", String.fromInt id ] []

        -- Observations 
        Observations maybeId ->
            appAbsolute [ "observations" ] <| toList (Maybe.map (unwrapCategoryId >> Builder.int "categoryId") maybeId)

        Observation (ObservationId id) ->
            appAbsolute [ "observations", String.fromInt id ] []

        -- Feedback
        Feedback maybeId ->
            appAbsolute [ "feedback" ] <| toList (Maybe.map (unwrapObservationId >> Builder.int "observationId") maybeId)

        FeedbackItem (FeedbackId id) ->
            appAbsolute [ "feedback", String.fromInt id ] []

        -- Feedback
        Explanations maybeId ->
            appAbsolute [ "explanations" ] <| toList (Maybe.map (unwrapFeedbackId >> Builder.int "feedbackId") maybeId)

        Explanation (ExplanationId id) ->
            appAbsolute [ "explanations", String.fromInt id ] []

        -- Users
        Users ->
            appAbsolute [ "users" ] []

        User (UserId id) ->
            appAbsolute [ "users", String.fromInt id ] []

        -- Drafts
        DraftClassrooms ->
            appAbsolute [ "drafts" ] []

        DraftRotations (SectionId id) ->
            appAbsolute [ "drafts", "sections", String.fromInt id ] []

        GroupDrafts (RotationGroupId id) ->
            appAbsolute [ "drafts", "groups", String.fromInt id ] []

        Draft (RotationGroupId rotationGroupId) (DraftId draftId) ->
            appAbsolute [ "drafts", "groups", String.fromInt rotationGroupId, String.fromInt draftId ] []

        EditFeedback (DraftId draftId) maybeCategoryId ->
            appAbsolute [ "drafts", String.fromInt draftId, "feedback" ] (Maybe.withDefault [] (Maybe.map (\(CategoryId id) -> [ Builder.int "categoryId" id ]) maybeCategoryId))

        -- Profile
        Profile ->
            appAbsolute [ "profile" ] []
