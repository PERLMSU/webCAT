module Page.DraftClassrooms exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Classrooms exposing (..)
import API.Drafts exposing (..)
import Alert exposing (Alert, dismiss)
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.ListGroup as ListGroup
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Table as Table
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (RemoteData(..))
import Route
import Session as Session exposing (Session)
import Task
import Time
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , classrooms : APIData (List Classroom)
    , semesters : APIData (List Semester)
    , sections : APIData (List Section)
    , alerts : List Alert
    , timezone : Time.Zone
    }


type Msg
    = GotSession Session
    | GotClassroom (APIData Classroom)
    | GotClassrooms (APIData (List Classroom))
    | GotRotationGroup (APIData RotationGroup)
    | GotSemesters (APIData (List Semester))
    | GotSections (APIData (List Section))
      -- Time
    | GotTimezone Time.Zone
      -- Alert dismissal
    | DismissAlert Alert


init : Session -> ( Model, Cmd Msg )
init session =
    case Session.credential session of
        Just cred ->
            let
                model =
                    { session = session, classrooms = Loading, semesters = Loading, sections = Loading, alerts = [], timezone = Time.utc }

                user =
                    API.credentialUser cred

                isAdmin =
                    user.role == Admin

                isAssistant =
                    user.role == LearningAssistant
            in
            if isAdmin then
                ( model, Cmd.batch <| [ Task.perform GotTimezone Time.here, semesters session GotSemesters, classrooms session GotClassrooms ] )

            else if isAssistant then
                ( model, Cmd.batch <| [ Task.perform GotTimezone Time.here, semesters session GotSemesters ] ++ List.map (\id -> getRotationGroup session id GotRotationGroup) user.rotationGroups )

            else
                ( model, Route.replaceUrl (Session.navKey session) Route.Login )

        Nothing ->
            ( { session = session
              , alerts = []
              , classrooms = NotAsked
              , semesters = NotAsked
              , sections = NotAsked
              , timezone = Time.utc
              }
            , Route.replaceUrl (Session.navKey session) Route.Login
            )


toSession : Model -> Session
toSession model =
    model.session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session

        GotTimezone zone ->
            ( { model | timezone = zone }, Cmd.none )

        GotClassroom result ->
            case result of
                RemoteData.Success classroom ->
                    if RemoteData.isSuccess model.classrooms then
                        ( { model | classrooms = RemoteData.map (\l -> classroom :: l) model.classrooms }, Cmd.none )

                    else
                        ( { model | classrooms = RemoteData.succeed [ classroom ] }, Cmd.none )

                Failure error ->
                    ( { model | alerts = Alert.fromAPIError error :: model.alerts }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotClassrooms result ->
            case result of
                Success classrooms ->
                    ( { model | classrooms = result }, Cmd.batch <| List.map (\{ id } -> sections model.session (Just id) Nothing GotSections) classrooms )

                _ ->
                    ( { model | classrooms = result }, Cmd.none )

        GotSemesters result ->
            ( { model | semesters = RemoteData.map (List.sortBy (.endDate >> Time.posixToMillis) >> List.reverse) result }, Cmd.none )

        GotSections result ->
            case result of
                RemoteData.Success sections ->
                    if RemoteData.isSuccess model.sections then
                        ( { model | sections = RemoteData.map (\l -> sections ++ l) model.sections }, Cmd.none )

                    else
                        ( { model | sections = RemoteData.succeed sections }, Cmd.none )

                Failure error ->
                    ( { model | alerts = Alert.fromAPIError error :: model.alerts }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotRotationGroup result ->
            case result of
                RemoteData.Success rotationGroup ->
                    ( model, getClassroom model.session rotationGroup.classroom GotClassroom )

                Failure error ->
                    ( { model | alerts = Alert.fromAPIError error :: model.alerts }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        DismissAlert alert ->
            ( { model | alerts = Alert.dismiss alert model.alerts }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



viewSemesters : Model -> Html Msg
viewSemesters model =
    case model.semesters of
        Success semesters ->
            case model.sections of
                Success sections ->
                    case model.classrooms of
                        Success classrooms ->
                            let
                                renderSection section =
                                    ListGroup.li [] [ a [ Route.href <| Route.DraftRotations section.id ] [ text <| "Section " ++ section.number ] ]

                                renderClassroom semesterId classroom =
                                    let
                                        renderedSections =
                                            List.map renderSection <| List.filter (\s -> s.classroomId == classroom.id && s.semesterId == semesterId) sections

                                        cardContent =
                                            if List.isEmpty renderedSections then
                                                Card.block [ Block.warning ] [ Block.titleH4 [] [ text "No sections for classroom" ] ]

                                            else
                                                Card.listGroup renderedSections
                                    in
                                    Grid.col []
                                        [ Card.config []
                                            |> Card.headerH3 [] [ text classroom.courseCode, text " - ", text classroom.name ]
                                            |> cardContent
                                            |> Card.view
                                        ]

                                renderSemester semester =
                                    Grid.row [] <|
                                        [ Grid.col []
                                            [ h3 [] [ text <| semester.name ++ " " ++ (Time.toYear model.timezone >> String.fromInt) semester.startDate ]
                                            ]
                                        , Grid.colBreak []
                                        ]
                                            ++ (List.map (renderClassroom semester.id) <| List.filter (\{ id } -> List.any (\s -> s.classroomId == id && s.semesterId == semester.id) sections) classrooms)
                            in
                            Grid.container [] <| List.map renderSemester semesters

                        _ ->
                            text ""

                _ ->
                    text ""

        _ ->
            text ""


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Drafts - Classrooms"
    , content =
        let
            alerts =
                div [] <| List.map (Alert.render DismissAlert) model.alerts
        in
        div []
            [ alerts
            , viewSemesters model
            ]
    }
