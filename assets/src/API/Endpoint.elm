module API.Endpoint exposing (..)

import Http
import Url.Builder exposing (QueryParameter)

{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { body : Http.Body
    , expect : Http.Expect a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    , withCredentials : Bool
    }
    -> Http.Request a
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = unwrap config.url
        , withCredentials = config.withCredentials
        }


-- TYPES


{-| Get a URL to the WebCAT API.
This is not publicly exposed, because we want to make sure the only way to get one of these URLs is from this module.
-}
type Endpoint
    = Endpoint String

unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
   Endpoint <| Url.Builder.absolute ("api" :: paths) queryParams

-- ENDPOINTS

csrf : Endpoint
csrf = url ["auth", "csrf"] []

login : Endpoint
login = url ["auth", "login"] []

password_reset : Endpoint
password_reset = url ["auth", "password_reset"] []

password_reset_finish : Endpoint
password_reset_finish = url ["auth", "password_reset", "finish"] []

-- Accounts/Profile
profile : Endpoint
profile = url ["user"] []

user : UserId -> Endpoint
user (UserId id) = url ["users", String.fromInt id]

users : Endpoint
users = url ["users"]

-- Classrooms
classroom : ClassroomId -> Endpoint
classroom (ClassroomId id) = url ["classrooms", String.fromInt id ] []

classrooms : Endpoint
classrooms = url ["classrooms"] []


-- Semesters

semester : SemesterId -> Endpoint
semester (SemesterId id) = url ["semesters", String.fromInt id ] []

semesters : Endpoint
semesters = url ["semesters"] []

-- Sections
section : SectionId -> Endpoint
section (SectionId id) = url ["sections", String.fromInt id ] []

sections : Endpoint
sections = url ["sections"] []

-- Rotations

rotation : RotationId -> Endpoint
rotation (RotationId id) = url ["rotations", String.fromInt id ] []

rotations : Endpoint
rotations = url ["rotations"] []

-- Rotation groups
rotation_group : RotationGroupId -> Endpoint
rotation_group (RotationGroupId id) = url ["rotation_groups", String.fromInt id ] []

rotation_groups : Endpoint
rotation_groups = url ["rotation_groups"] []

-- Import
import_ : ImportId -> Endpoint
import_ (ImportId id) = url ["imports", String.fromInt id] []

imports : Endpoint
imports = url ["imports"] []

-- Categories
category : CategoryId -> Endpoint
category (CategoryId id) = url ["categories", String.fromInt id ] []

categories : Endpoint
categories = url ["categories"] []


-- Observations

observation : ObservationId -> Endpoint
observation (ObservationId id) = url ["observations", String.fromInt id ] []

observations : Endpoint
observations = url ["observations"] []

-- Feedback
feedback : FeedbackId -> Endpoint
rotation (FeedbackId id) = url ["feedback", String.fromInt id ] []

rotations : Endpoint
rotations = url ["feedback"] []


-- Drafts


-- Drafts/Comments


-- Drafts/Grades



































