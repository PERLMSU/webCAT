module Page.DraftRotations exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Classrooms exposing (..)
import API.Drafts exposing (..)
import API.Users exposing (..)
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Text as Text
import Bootstrap.ListGroup as ListGroup
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Modal as Modal
import Components.Table as Table
import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as ListExtra
import RemoteData exposing (RemoteData(..))
import Route
import Session as Session exposing (Session)
import Task
import Time
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , sectionId : SectionId

    -- Remote data
    , rotations : APIData (List Rotation)
    , rotationGroups : APIData (List RotationGroup)
    , users : APIData (List User)

    -- Timezone
    , timezone : Time.Zone
    }


type Msg
    = GotSession Session
    | GotRotations (APIData (List Rotation))
    | GotRotationGroups (APIData (List RotationGroup))
    | GotUsers (APIData (List User))
    | GotTimezone Time.Zone


init : Session -> SectionId -> ( Model, Cmd Msg )
init session sectionId =
    case Session.credential session of
        Just cred ->
            let
                user =
                    API.credentialUser cred
            in
            if user.role == Admin || user.role == Faculty then
                ( { session = session
                  , sectionId = sectionId
                  , rotations = Loading
                  , rotationGroups = Loading
                  , users = Loading
                  , timezone = Time.utc
                  }
                , Cmd.batch
                    [ rotations session (Just sectionId) GotRotations
                    , rotationGroups session Nothing GotRotationGroups
                    , users session GotUsers
                    , Task.perform GotTimezone Time.here
                    ]
                )

            else
                ( { session = session
                  , sectionId = sectionId
                  , rotations = Loading
                  , rotationGroups = Loading
                  , users = Loading
                  , timezone = Time.utc
                  }
                , Cmd.batch
                    [ rotations session (Just sectionId) GotRotations
                    , Task.perform GotTimezone Time.here
                    ]
                )

        Nothing ->
            ( { session = session
              , sectionId = sectionId
              , rotations = NotAsked
              , rotationGroups = NotAsked
              , users = NotAsked
              , timezone = Time.utc
              }
            , Route.replaceUrl (Session.navKey session) Route.Login
            )


toSession : Model -> Session
toSession model =
    model.session


viewRotationGroups : Model -> Rotation -> List (Grid.Column Msg)
viewRotationGroups model rotation =
    case model.rotationGroups of
        Success rotationGroups ->
            let
                viewStudents group =
                    case model.users of
                        Success users ->
                            let
                                students = List.filter (\user->user.role == Student) users 
                            in
                            Card.listGroup <| List.map (\user -> ListGroup.li [] [text <| user.firstName ++ " " ++ user.lastName]) students

                        Failure error ->
                            Card.block [] [ Block.text [] [ (API.getErrorBody >> API.errorBodyToString >> text) error ] ]

                        _ ->
                            Card.block [] [ Block.custom Common.loading ]

                renderRotationGroup group =
                    Grid.col []
                        [ Card.config []
                            |> Card.headerH3 [] [ a [Route.href (Route.GroupDrafts group.id)] [ text <| "Group " ++ (.number >> String.fromInt) group ] ]
                            |> viewStudents group
                            |> Card.view
                        ]
            in
            List.map renderRotationGroup rotationGroups

        Failure error ->
            [ Grid.col [] [ (API.getErrorBody >> API.errorBodyToString >> text) error ] ]

        _ ->
            [ Grid.col [] [ Common.loading ] ]


viewRotations : Model -> List (Html Msg)
viewRotations model =
    case model.rotations of
        Success rotations ->
            let
                renderRotation rotation =
                    Grid.simpleRow <|
                        [ Grid.col []
                            [ h3 [] [ text <| "Rotation " ++ String.fromInt rotation.number ]
                            , h5 [ class "text-secondary" ] [ text <| "(" ++ Date.posixToDate model.timezone rotation.startDate ++ " to " ++ Date.posixToDate model.timezone rotation.endDate ++ ")" ]
                            ]
                        , Grid.colBreak []
                        ]
                            ++ viewRotationGroups model rotation
            in
            List.map renderRotation rotations

        Failure error ->
            [ (API.getErrorBody >> API.errorBodyToString >> text) error ]

        _ ->
            [ Common.loading ]


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Sections"
    , content =
        Grid.container [] <| viewRotations model
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.sectionId

        GotTimezone tz ->
            ( { model | timezone = tz }, Cmd.none )

        GotRotations result ->
            API.handleRemoteError result { model | rotations = RemoteData.map (List.sortBy (.startDate >> Time.posixToMillis) >> List.reverse) result } Cmd.none

        GotRotationGroups result ->
            API.handleRemoteError result { model | rotationGroups = RemoteData.map (List.sortBy .number) result } Cmd.none

        GotUsers result ->
            API.handleRemoteError result { model | users = RemoteData.map (List.sortBy .firstName) result } Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
