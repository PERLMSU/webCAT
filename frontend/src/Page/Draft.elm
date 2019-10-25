module Page.Draft exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Drafts exposing (..)
import API.Users exposing (..)
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Table as Table
import Date
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
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.ListGroup as ListGroup


type alias Model =
    { session : Session
    , timezone : Time.Zone
    , groupDraft : APIData GroupDraft
    , studentDrafts : APIData (List StudentDraft)
    , students : APIData (List User)
    , draftId : DraftId
    }


type Msg
    = GotSession Session
    | GotDraft (APIData GroupDraft)
    | GotStudentDrafts (APIData (List StudentDraft))
    | GotCreatedStudentDraft (APIData StudentDraft)
    | GotStudent (APIData User)
    | GotTimezone Time.Zone


init : DraftId -> Session -> ( Model, Cmd Msg )
init draftId session =
    if Session.isAuthenticated session then
        ( { session = session
          , groupDraft = Loading
          , studentDrafts = Loading
          , students = Loading
          , draftId = draftId
          , timezone = Time.utc
          }
        , Cmd.batch [ studentDrafts session (Just draftId) GotStudentDrafts
                    , Task.perform GotTimezone Time.here
                    ]
        )

    else
        ( { session = session
          , groupDraft = Loading
          , draftId = draftId
          , studentDrafts = Loading
          , students = Loading
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
            init model.draftId session

        GotDraft result ->
            case result of
                Success draft ->
                    ( { model | groupDraft = result }, Cmd.batch <| List.map (\id -> user model.session id GotStudent) draft.users )

                _ ->
                    API.handleRemoteError result { model | groupDraft = result } Cmd.none

        GotTimezone zone ->
            ( { model | timezone = zone }, Cmd.none )

        GotStudentDrafts result ->
            API.handleRemoteError result { model | studentDrafts = result } <| groupDraft model.session model.draftId GotDraft 

        GotStudent result ->
            let
                mapped =
                    case model.students of
                        Success students ->
                            RemoteData.map
                                (\student ->
                                    if student.role == Student then
                                        student :: students

                                    else
                                        students
                                )
                                result

                        Loading ->
                            RemoteData.map
                                (\student ->
                                    if student.role == Student then
                                        [ student ]

                                    else
                                        []
                                )
                                result

                        _ ->
                            model.students
                command = case result of
                              Success student ->
                                  if student.role == Student then
                                      case model.studentDrafts of
                                          Success drafts ->
                                              if List.any (\draft->draft.studentId == student.id) drafts then
                                                  Cmd.none
                                              else
                                                  createStudentDraft model.session {content = "Insert content here", status = Unreviewed, studentId = student.id, parentDraftId = model.draftId } GotCreatedStudentDraft
                                          _ -> Cmd.none
                                  else
                                      Cmd.none
                              _ -> Cmd.none
            in
            API.handleRemoteError result { model | students = mapped } command

        GotCreatedStudentDraft result ->
            case result of
                Success draft ->
                    ({model | studentDrafts = RemoteData.map ((::) draft) model.studentDrafts}, Cmd.none)
                
                _ -> API.handleRemoteError result model Cmd.none





view : Model -> { title : String, content : Html Msg }
view model =
    { title =
        case model.groupDraft of
            Success draft ->
                "Edit Draft"

            _ ->
                "Loading Draft"
    , content =
        Grid.container []
            []
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
