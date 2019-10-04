module Page.Dashboard exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import Html exposing (..)
import Route
import Session exposing (Session)
import Types exposing (ClassroomId)


type alias Model =
    { session : Session
    , classroomId : Maybe ClassroomId
    }


type Msg
    = GotSession Session


init : Session -> Maybe ClassroomId -> ( Model, Cmd Msg )
init session maybeClassroomId =
    case Session.credential session of
        Nothing ->
            ( { session = session, classroomId = maybeClassroomId }, Route.replaceUrl (Session.navKey session) (Route.Login Nothing) )

        Just _ ->
            ( { session = session, classroomId = maybeClassroomId }, Cmd.none )


toSession : Model -> Session
toSession model =
    model.session


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Dashboard"
    , content = h1 [] [ text "hello world" ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.classroomId



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
