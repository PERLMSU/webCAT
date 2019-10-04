module Page.Profile exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Feedback exposing (..)
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Modal as Modal
import Components.Table as Table
import Html exposing (..)
import Html.Attributes exposing (..)
import RemoteData exposing (RemoteData(..))
import Route
import Session as Session exposing (Session)
import Types exposing (Classroom, ClassroomId)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session }


type Msg
    = GotSession Session


init : Session -> ( Model, Cmd Msg )
init session =
    if Session.isAuthenticated session then
        ( { session = session
          }
        , Cmd.none
        )

    else
        ( { session = session
          }
        , Route.replaceUrl (Session.navKey session) (Route.Login Nothing)
        )


toSession : Model -> Session
toSession model =
    model.session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Profile"
    , content =
        div []
            [ Common.panel
                []
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
