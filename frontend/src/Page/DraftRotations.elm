module Page.DraftRotations exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

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
    , sectionId : SectionId
    }


type Msg
    = GotSession Session


init : SectionId -> Session -> ( Model, Cmd Msg )
init sectionId session =
    if Session.isAuthenticated session then
        ( { session = session
          , sectionId = sectionId
          }
        , Cmd.none
        )

    else
        ( { session = session
          , sectionId = sectionId
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
            init model.sectionId session


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Sections"
    , content =
        div []
            [ Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ h1 [ class "text-4xl text-gray-400 font-display" ] [ text "Sections" ]
                    ]
                ]
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
