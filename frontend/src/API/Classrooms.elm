module API.Classrooms exposing (..)

import API exposing (APIData, APIResult)
import API.Endpoint as Endpoint
import Http exposing (jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Session exposing (Session)
import Time as Time
import Types exposing (..)



-- Classrooms


listClassrooms : Session -> (APIData (List Classroom) -> msg) -> Cmd msg
listClassrooms session toMsg =
    API.getRemote Endpoint.classrooms (Session.credential session) (multiDecoder classroomDecoder) toMsg


getClassroom : Session -> ClassroomId -> (APIData Classroom -> msg) -> Cmd msg
getClassroom session id toMsg =
    API.getRemote (Endpoint.classroom id) (Session.credential session) (singleDecoder classroomDecoder) toMsg


type alias ClassroomForm =
    { courseCode : String, name : String, description : String }


initClassroomForm : Maybe Classroom -> ClassroomForm
initClassroomForm maybeClassroom =
    case maybeClassroom of
        Nothing ->
            { courseCode = ""
            , name = ""
            , description = ""}

        Just classroom ->
            { courseCode = classroom.courseCode
            , name = classroom.name
            , description = Maybe.withDefault "" classroom.description
            }


encodeClassroomForm : ClassroomForm -> Encode.Value
encodeClassroomForm form =
    Encode.object
        [ ( "course_code", Encode.string form.courseCode )
        , ( "name", Encode.string form.name )
        , ( "description", Encode.string form.description )
        ]


createClassroom : Session -> ClassroomForm -> (APIData Classroom -> msg) -> Cmd msg
createClassroom session form toMsg =
    API.postRemote Endpoint.classrooms (Session.credential session) (jsonBody <| encodeClassroomForm form) (singleDecoder classroomDecoder) toMsg


updateClassroom : Session -> ClassroomId -> ClassroomForm -> (APIData Classroom -> msg) -> Cmd msg
updateClassroom session id form toMsg =
    API.putRemote (Endpoint.classroom id) (Session.credential session) (jsonBody <| encodeClassroomForm form) (singleDecoder classroomDecoder) toMsg


deleteClassroom : Session -> ClassroomId -> (APIData () -> msg) -> Cmd msg
deleteClassroom session id toMsg =
    API.deleteRemote (Endpoint.classroom id) (Session.credential session) toMsg



-- Semesters


semesters : Session -> (APIData (List Semester) -> msg) -> Cmd msg
semesters session toMsg =
    API.getRemote Endpoint.semesters (Session.credential session) (multiDecoder semesterDecoder) toMsg


type alias SemesterForm =
    { name : String, description : String, startDate : Time.Posix, endDate : Time.Posix }

initSemesterForm : Maybe Semester -> Maybe Time.Posix -> SemesterForm
initSemesterForm maybeSemester maybeTime =
    case maybeSemester of
        Just semester ->
            { name = semester.name
            , description = Maybe.withDefault "" semester.description
            , startDate =  semester.startDate
            , endDate =  semester.endDate
            }
        Nothing ->
            { name = ""
            , description = ""
            , startDate = Maybe.withDefault (Time.millisToPosix 0) maybeTime
            , endDate = Maybe.withDefault (Time.millisToPosix 0) maybeTime
            }

encodeSemesterForm : SemesterForm -> Encode.Value
encodeSemesterForm form =
    Encode.object
        [ ( "name", Encode.string form.name )
        , ( "description", Encode.string form.description )
        , ( "startDate", (Time.posixToMillis >> Encode.int) form.startDate)
        , ( "endDate", (Time.posixToMillis >> Encode.int) form.endDate)
        ]

createSemester : Session -> SemesterForm -> (APIData Semester -> msg) -> Cmd msg
createSemester session form toMsg =
    API.postRemote Endpoint.semesters (Session.credential session) (jsonBody <| encodeSemesterForm form) (singleDecoder semesterDecoder) toMsg


updateSemester : Session -> SemesterId -> SemesterForm -> (APIData Semester -> msg) -> Cmd msg
updateSemester session id form toMsg =
    API.putRemote (Endpoint.semester id) (Session.credential session) (jsonBody <| encodeSemesterForm form) (singleDecoder semesterDecoder) toMsg


deleteSemester : Session -> SemesterId -> (APIData () -> msg) -> Cmd msg
deleteSemester session id toMsg =
    API.deleteRemote (Endpoint.semester id) (Session.credential session) toMsg


-- Sections


sections : Session -> Maybe ClassroomId -> Maybe SemesterId -> (APIData (List Section) -> msg) -> Cmd msg
sections session classroomId semesterId toMsg =
    API.getRemote (Endpoint.sections classroomId semesterId) (Session.credential session) (multiDecoder sectionDecoder) toMsg

-- Rotations
rotations : Session -> Maybe SectionId -> (APIData (List Rotation) -> msg) -> Cmd msg
rotations session sectionId toMsg =
    API.getRemote (Endpoint.rotations sectionId) (Session.credential session) (multiDecoder rotationDecoder) toMsg

-- Rotation Groups

rotationGroups : Session -> Maybe RotationId -> (APIData (List RotationGroup) -> msg) -> Cmd msg
rotationGroups session rotationId toMsg =
    API.getRemote (Endpoint.rotationGroups rotationId) (Session.credential session) (multiDecoder rotationGroupDecoder) toMsg

getRotationGroup : Session -> RotationGroupId -> (APIData RotationGroup -> msg) -> Cmd msg
getRotationGroup session id toMsg =
    API.getRemote (Endpoint.rotationGroup id) (Session.credential session) (singleDecoder rotationGroupDecoder) toMsg
