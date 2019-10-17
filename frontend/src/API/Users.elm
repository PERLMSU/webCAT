module API.Users exposing (UserForm, deleteUser, editUser, encodeUserForm, newUser, user, users)

import API exposing (APIData, APIResult)
import API.Endpoint as Endpoint
import Http exposing (jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Session exposing (Session)
import Time as Time
import Types exposing (..)



-- Users


user : Session -> UserId -> (APIData User -> msg) -> Cmd msg
user session id toMsg =
    API.getRemote (Endpoint.user id) (Session.credential session) (singleDecoder userDecoder) toMsg


users : Session -> (APIData (List User) -> msg) -> Cmd msg
users session toMsg =
    API.getRemote Endpoint.users (Session.credential session) (multiDecoder userDecoder) toMsg


type alias UserForm =
    { email : String
    , firstName : String
    , middleName : String
    , lastName : String
    , nickname : String
    , active : Bool
    , classrooms : List ClassroomId
    , sections : List SectionId
    , rotationGroups : List RotationGroupId
    , role : Role
    }


encodeUserForm : UserForm -> Encode.Value
encodeUserForm form =
    Encode.object
        [ ( "email", Encode.string form.email )
        , ( "first_name", Encode.string form.firstName )
        , ( "middle_name", Encode.string form.middleName )
        , ( "last_name", Encode.string form.lastName )
        , ( "nickname", Encode.string form.nickname )
        , ( "active", Encode.bool form.active )
        , ( "classrooms", Encode.list (unwrapClassroomId >> Encode.int) form.classrooms )
        , ( "sections", Encode.list (unwrapSectionId >> Encode.int) form.sections )
        , ( "rotation_groups", Encode.list (unwrapRotationGroupId >> Encode.int) form.rotationGroups )
        , ( "roles", (roleToString >> Encode.string) form.role)
        ]


editUser : Session -> UserId -> UserForm -> (APIData User -> msg) -> Cmd msg
editUser session id form toMsg =
    API.putRemote (Endpoint.user id) (Session.credential session) (jsonBody <| encodeUserForm form) (singleDecoder userDecoder) toMsg


newUser : Session -> UserForm -> (APIData User -> msg) -> Cmd msg
newUser session form toMsg =
    API.postRemote Endpoint.users (Session.credential session) (jsonBody <| encodeUserForm form) (singleDecoder userDecoder) toMsg


deleteUser : Session -> UserId -> (APIData () -> msg) -> Cmd msg
deleteUser session id toMsg =
    API.deleteRemote (Endpoint.user id) (Session.credential session) toMsg

