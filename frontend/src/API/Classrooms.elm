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


formFromClassroom : Classroom -> ClassroomForm
formFromClassroom classroom =
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


updateClassroom : Session -> ClassroomId -> ClassroomForm -> (APIData Classroom -> msg) -> Cmd msg
updateClassroom session id form toMsg =
    API.putRemote (Endpoint.classroom id) (Session.credential session) (jsonBody <| encodeClassroomForm form) (singleDecoder classroomDecoder) toMsg


createClassroom : Session -> ClassroomForm -> (APIData Classroom -> msg) -> Cmd msg
createClassroom session form toMsg =
    API.postRemote Endpoint.classrooms (Session.credential session) (jsonBody <| encodeClassroomForm form) (singleDecoder classroomDecoder) toMsg


deleteClassroom : Session -> ClassroomId -> (APIData () -> msg) -> Cmd msg
deleteClassroom session id toMsg =
    API.deleteRemote (Endpoint.classroom id) (Session.credential session) toMsg



-- Semesters


semesters : Session -> (APIData (List Semester) -> msg) -> Cmd msg
semesters session toMsg =
    API.getRemote Endpoint.semesters (Session.credential session) (multiDecoder semesterDecoder) toMsg


-- Sections
sections : Session -> Maybe ClassroomId -> Maybe SemesterId -> (APIData (List Section) -> msg) -> Cmd msg
sections session classroomId semesterId toMsg =
    API.getRemote (Endpoint.sections classroomId semesterId) (Session.credential session) (multiDecoder sectionDecoder) toMsg

-- Rotation Groups


getRotationGroup : Session -> RotationGroupId -> (APIData RotationGroup -> msg) -> Cmd msg
getRotationGroup session id toMsg =
    API.getRemote (Endpoint.rotationGroup id) (Session.credential session) (singleDecoder rotationGroupDecoder) toMsg
