module Page.GroupDrafts exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Feedback exposing (..)
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Text as Text
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Modal as Modal
import Components.Table as Table
import Html exposing (..)
import Html.Attributes exposing (..)
import RemoteData exposing (RemoteData(..))
import Route
import Session as Session exposing (Session)
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , rotationGroupId : RotationGroupId

    , rotationGroup : APIData RotationGroup
    , users : APIData (List User)
    }


type Msg
    = GotSession Session


init : Session -> RotationGroupId -> ( Model, Cmd Msg )
init session rotationGroupId =
    if Session.isAuthenticated session then
        ( { session = session
          , rotationGroupId = rotationGroupId
          , rotationGroup = Loading
          , users = Loading
          }
        , Cmd.none
        )

    else
        ( { session = session
          , rotationGroupId = rotationGroupId
          , rotationGroup = NotAsked
          , users = NotAsked
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
            init session model.rotationGroupId


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Group Drafts"
    , content =
        Grid.container []
            [ Grid.simpleRow [Grid.col [] [h2 [] [text ""]]]
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
