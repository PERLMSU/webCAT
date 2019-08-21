module Page.Drafts exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

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
    , drafts : APIData (List Draft)
    }


type Msg
    = GotSession Session
    | GotDrafts (APIData (List Draft))
      -- Table messages
    | DraftSelected Draft
    | TableEditClicked Draft
    | TableDeleteClicked Draft


init : Session -> ( Model, Cmd Msg )
init session =
    if Session.isAuthenticated session then
        ( { session = session
          , drafts = Loading
          }
        , drafts session Nothing Nothing Nothing GotDrafts
        )

    else
        ( { session = session
          , drafts = NotAsked
          }
        , Route.replaceUrl (Session.navKey session) (Route.Login Nothing)
        )


toSession : Model -> Session
toSession model =
    model.session


tableConfig : Table.Config Draft Msg
tableConfig =
    let
        render item =
            [ draftStatusToString item.status, Maybe.withDefault "NO STUDENT???" <| Maybe.map (\student -> student.firstName ++ " " ++ student.lastName) item.student ]
    in
    { render = render
    , headers = [ "Status", "Student" ]
    , tableClass = "w-full table-auto"
    , headerClass = "text-left text-gray-400"
    , rowClass = "border-t-1 border-gray-500 text-gray-400 cursor-pointer hover:bg-slate py-1"
    , onClick = DraftSelected
    , onEdit = TableEditClicked
    , onDelete = TableDeleteClicked
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session

        GotDrafts drafts ->
            API.handleRemoteError drafts { model | drafts = drafts } Cmd.none

        DraftSelected draft ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.Draft draft.id) )

        TableEditClicked draft ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.EditDraft draft.id) )

        TableDeleteClicked draft ->
            ( model, Cmd.none )


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Drafts"
    , content =
        div []
            [ Common.panel
                [ div [ class "flex justify-between items-center mx-4" ]
                    [ h1 [ class "text-4xl text-gray-400 font-display" ] [ text "Drafts" ]
                    ]
                , case model.drafts of
                    NotAsked ->
                        text ""

                    Loading ->
                        Common.loading

                    Failure e ->
                        div [ class "mx-4 my-2" ] [ div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ] ]

                    Success drafts ->
                        div [ class "mx-4 my-2 flex" ] [ Table.view tableConfig drafts ]
                ]
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
