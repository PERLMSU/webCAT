module API.Classrooms exposing (ClassroomForm, RotationForm, RotationGroupForm, SectionForm, SemesterForm, classrooms, createClassroom, createRotation, createRotationGroup, createSection, createSemester, deleteClassroom, deleteRotation, deleteRotationGroup, deleteSection, deleteSemester, getClassroom, getRotation, getRotationGroup, getSection, getSemester, importUsersClassroom, initClassroomForm, initRotationForm, initRotationGroupForm, initSectionForm, initSemesterForm, rotationGroups, rotations, sections, semesters, updateClassroom, updateRotation, updateRotationGroup, updateSection, updateSemester)

import API exposing (APIData, APIResult)
import API.Endpoint as Endpoint
import Either exposing (..)
import File exposing (..)
import Http exposing (fileBody, jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Session exposing (Session)
import Time as Time
import Types exposing (..)



-- Classrooms


type alias ClassroomForm =
    { courseCode : String
    , name : String
    , description : String
    , categories : List CategoryId
    }


initClassroomForm : Maybe Classroom -> ClassroomForm
initClassroomForm maybeClassroom =
    case maybeClassroom of
        Nothing ->
            { courseCode = ""
            , name = ""
            , description = ""
            , categories = []
            }

        Just classroom ->
            { courseCode = classroom.courseCode
            , name = classroom.name
            , description = Maybe.withDefault "" classroom.description
            , categories = classroom.categories
            }


classrooms : Session -> (APIData (List Classroom) -> msg) -> Cmd msg
classrooms session toMsg =
    API.getRemote Endpoint.classrooms (Session.credential session) (multiDecoder classroomDecoder) toMsg


getClassroom : Session -> ClassroomId -> (APIData Classroom -> msg) -> Cmd msg
getClassroom session id toMsg =
    API.getRemote (Endpoint.classroom id) (Session.credential session) (singleDecoder classroomDecoder) toMsg


encodeClassroomForm : ClassroomForm -> Encode.Value
encodeClassroomForm form =
    Encode.object
        [ ( "course_code", Encode.string form.courseCode )
        , ( "name", Encode.string form.name )
        , ( "description", Encode.string form.description )
        , ( "categories", Encode.list (unwrapCategoryId >> Encode.int) form.categories )
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


type alias SemesterForm =
    { name : String, description : String, startDate : Time.Posix, endDate : Time.Posix }


initSemesterForm : Maybe Semester -> Maybe Time.Posix -> SemesterForm
initSemesterForm maybeSemester maybeTime =
    case maybeSemester of
        Just semester ->
            { name = semester.name
            , description = Maybe.withDefault "" semester.description
            , startDate = semester.startDate
            , endDate = semester.endDate
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
        , ( "start_date", (Time.posixToMillis >> Encode.int) form.startDate )
        , ( "end_date", (Time.posixToMillis >> Encode.int) form.endDate )
        ]


semesters : Session -> (APIData (List Semester) -> msg) -> Cmd msg
semesters session toMsg =
    API.getRemote Endpoint.semesters (Session.credential session) (multiDecoder semesterDecoder) toMsg


getSemester : Session -> SemesterId -> (APIData Semester -> msg) -> Cmd msg
getSemester session id toMsg =
    API.getRemote (Endpoint.semester id) (Session.credential session) (singleDecoder semesterDecoder) toMsg


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


type alias SectionForm =
    { number : String, description : String, semesterId : Maybe SemesterId, classroomId : Maybe ClassroomId }


initSectionForm : Either Section ClassroomId -> SectionForm
initSectionForm maybeSection =
    case maybeSection of
        Left section ->
            { number = section.number
            , description = Maybe.withDefault "" section.description
            , classroomId = Just section.classroomId
            , semesterId = Just section.semesterId
            }

        Right classroomId ->
            { number = ""
            , description = ""
            , classroomId = Just classroomId
            , semesterId = Nothing
            }


encodeSectionForm : SectionForm -> Encode.Value
encodeSectionForm form =
    Encode.object
        [ ( "number", Encode.string form.number )
        , ( "description", Encode.string form.description )
        , ( "classroom_id", encodeMaybe (unwrapClassroomId >> Encode.int) form.classroomId )
        , ( "semester_id", encodeMaybe (unwrapSemesterId >> Encode.int) form.semesterId )
        ]


sections : Session -> Maybe ClassroomId -> Maybe SemesterId -> (APIData (List Section) -> msg) -> Cmd msg
sections session classroomId semesterId toMsg =
    API.getRemote (Endpoint.sections classroomId semesterId) (Session.credential session) (multiDecoder sectionDecoder) toMsg


getSection : Session -> SectionId -> (APIData Section -> msg) -> Cmd msg
getSection session id toMsg =
    API.getRemote (Endpoint.section id) (Session.credential session) (singleDecoder sectionDecoder) toMsg


createSection : Session -> SectionForm -> (APIData Section -> msg) -> Cmd msg
createSection session form toMsg =
    API.postRemote (Endpoint.sections Nothing Nothing) (Session.credential session) (jsonBody <| encodeSectionForm form) (singleDecoder sectionDecoder) toMsg


updateSection : Session -> SectionId -> SectionForm -> (APIData Section -> msg) -> Cmd msg
updateSection session id form toMsg =
    API.putRemote (Endpoint.section id) (Session.credential session) (jsonBody <| encodeSectionForm form) (singleDecoder sectionDecoder) toMsg


deleteSection : Session -> SectionId -> (APIData () -> msg) -> Cmd msg
deleteSection session id toMsg =
    API.deleteRemote (Endpoint.section id) (Session.credential session) toMsg


importUsersClassroom : Session -> SectionId -> File -> (APIData (List User) -> msg) -> Cmd msg
importUsersClassroom session id file toMsg =
    API.postRemote (Endpoint.sectionImport id) (Session.credential session) (fileBody file) (multiDecoder userDecoder) toMsg



-- Rotations


type alias RotationForm =
    { number : Int
    , description : String
    , startDate : Time.Posix
    , endDate : Time.Posix
    , sectionId : SectionId
    }


initRotationForm : Either Rotation SectionId -> Maybe Time.Posix -> RotationForm
initRotationForm either maybeTime =
    case either of
        Left rotation ->
            { number = rotation.number
            , description = Maybe.withDefault "" rotation.description
            , sectionId = rotation.sectionId
            , startDate = rotation.startDate
            , endDate = rotation.endDate
            }

        Right id ->
            { number = 0
            , description = ""
            , startDate = Maybe.withDefault (Time.millisToPosix 0) maybeTime
            , endDate = Maybe.withDefault (Time.millisToPosix 0) maybeTime
            , sectionId = id
            }


encodeRotationForm : RotationForm -> Encode.Value
encodeRotationForm form =
    Encode.object
        [ ( "number", Encode.int form.number )
        , ( "description", Encode.string form.description )
        , ( "start_date", (Time.posixToMillis >> Encode.int) form.startDate )
        , ( "end_date", (Time.posixToMillis >> Encode.int) form.endDate )
        , ( "section_id", (unwrapSectionId >> Encode.int) form.sectionId )
        ]


rotations : Session -> Maybe SectionId -> (APIData (List Rotation) -> msg) -> Cmd msg
rotations session sectionId toMsg =
    API.getRemote (Endpoint.rotations sectionId) (Session.credential session) (multiDecoder rotationDecoder) toMsg


getRotation : Session -> RotationId -> (APIData Rotation -> msg) -> Cmd msg
getRotation session id toMsg =
    API.getRemote (Endpoint.rotation id) (Session.credential session) (singleDecoder rotationDecoder) toMsg


createRotation : Session -> RotationForm -> (APIData Rotation -> msg) -> Cmd msg
createRotation session form toMsg =
    API.postRemote (Endpoint.rotations Nothing) (Session.credential session) (jsonBody <| encodeRotationForm form) (singleDecoder rotationDecoder) toMsg


updateRotation : Session -> RotationId -> RotationForm -> (APIData Rotation -> msg) -> Cmd msg
updateRotation session id form toMsg =
    API.putRemote (Endpoint.rotation id) (Session.credential session) (jsonBody <| encodeRotationForm form) (singleDecoder rotationDecoder) toMsg


deleteRotation : Session -> RotationId -> (APIData () -> msg) -> Cmd msg
deleteRotation session id toMsg =
    API.deleteRemote (Endpoint.rotation id) (Session.credential session) toMsg



-- Rotation Groups


type alias RotationGroupForm =
    { number : Int
    , description : String
    , rotationId : RotationId
    , users : List UserId
    }


initRotationGroupForm : Either RotationGroup RotationId -> RotationGroupForm
initRotationGroupForm either =
    case either of
        Left group ->
            { number = group.number
            , description = Maybe.withDefault "" group.description
            , rotationId = group.rotationId
            , users = group.users
            }

        Right id ->
            { number = 0
            , description = ""
            , rotationId = id
            , users = []
            }


encodeRotationGroupForm : RotationGroupForm -> Encode.Value
encodeRotationGroupForm form =
    Encode.object
        [ ( "number", Encode.int form.number )
        , ( "description", Encode.string form.description )
        , ( "rotation_id", (unwrapRotationId >> Encode.int) form.rotationId )
        , ( "users", Encode.list (unwrapUserId >> Encode.int) form.users )
        ]


rotationGroups : Session -> Maybe RotationId -> (APIData (List RotationGroup) -> msg) -> Cmd msg
rotationGroups session rotationId toMsg =
    API.getRemote (Endpoint.rotationGroups rotationId) (Session.credential session) (multiDecoder rotationGroupDecoder) toMsg


getRotationGroup : Session -> RotationGroupId -> (APIData RotationGroup -> msg) -> Cmd msg
getRotationGroup session id toMsg =
    API.getRemote (Endpoint.rotationGroup id) (Session.credential session) (singleDecoder rotationGroupDecoder) toMsg


createRotationGroup : Session -> RotationGroupForm -> (APIData RotationGroup -> msg) -> Cmd msg
createRotationGroup session form toMsg =
    API.postRemote (Endpoint.rotationGroups Nothing) (Session.credential session) (jsonBody <| encodeRotationGroupForm form) (singleDecoder rotationGroupDecoder) toMsg


updateRotationGroup : Session -> RotationGroupId -> RotationGroupForm -> (APIData RotationGroup -> msg) -> Cmd msg
updateRotationGroup session id form toMsg =
    API.putRemote (Endpoint.rotationGroup id) (Session.credential session) (jsonBody <| encodeRotationGroupForm form) (singleDecoder rotationGroupDecoder) toMsg


deleteRotationGroup : Session -> RotationGroupId -> (APIData () -> msg) -> Cmd msg
deleteRotationGroup session id toMsg =
    API.deleteRemote (Endpoint.rotationGroup id) (Session.credential session) toMsg
