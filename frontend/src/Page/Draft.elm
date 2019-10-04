module Page.Draft exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Drafts exposing (..)
import Components.Common as Common exposing (Style(..))
import Components.Form as Form
import Components.Modal as Modal
import Components.Table as Table
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (RemoteData(..))
import Route
import Session as Session exposing (Session)
import Types exposing (..)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)


type alias Model =
    { session : Session
    , draft : APIData GroupDraft 
    , draftId : DraftId
    }


type Msg
    = GotSession Session
    | GotDraft (APIData GroupDraft)


init : DraftId -> Session -> ( Model, Cmd Msg )
init draftId session =
    if Session.isAuthenticated session then
        ( { session = session
          , draft = Loading
          , draftId = draftId
          }
        , groupDraft session draftId GotDraft
        )

    else
        ( { session = session
          , draft = NotAsked
          , draftId = draftId
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
            init model.draftId session

        GotDraft draft ->
            API.handleRemoteError draft { model | draft = draft } Cmd.none


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Drafts"
    , content =
        div []
            [ Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ h1 [ class "text-4xl text-gray-400 font-display" ] [ text "Drafts" ]
                    ]
                ]
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
