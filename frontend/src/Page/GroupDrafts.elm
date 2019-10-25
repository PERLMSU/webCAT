module Page.GroupDrafts exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, Error(..))
import API.Classrooms exposing (..)
import API.Drafts exposing (..)
import API.Feedback exposing (..)
import Bootstrap.Alert as Alert
import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Modal as Modal
import Bootstrap.Text as Text
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


type ModalState
    = Hidden
    | DeleteDraftShown DraftId (APIData ()) Modal.Visibility


type alias Model =
    { session : Session
    , rotationGroupId : RotationGroupId
    , rotationGroup : APIData RotationGroup
    , groupDrafts : APIData (List GroupDraft)
    , newDraft : APIData GroupDraft
    , timezone : Time.Zone
    , alertVisibility : Alert.Visibility
    , modalState : ModalState
    }


type Msg
    = GotSession Session
    | GotRotationGroup (APIData RotationGroup)
    | GotDrafts (APIData (List GroupDraft))
    | NewDraftClicked
    | DeleteDraftClicked DraftId
    | DeleteDraftSubmitted
    | NewDraftResult (APIData GroupDraft)
    | GotTimezone Time.Zone
      -- Alerts and modal
    | AlertMsg Alert.Visibility
    | ModalClose
    | ModalAnimate Modal.Visibility
    | GotDeleteDraftResult (APIData ())


init : Session -> RotationGroupId -> ( Model, Cmd Msg )
init session rotationGroupId =
    if Session.isAuthenticated session then
        ( { session = session
          , rotationGroupId = rotationGroupId
          , rotationGroup = Loading
          , groupDrafts = Loading
          , newDraft = NotAsked
          , timezone = Time.utc
          , alertVisibility = Alert.closed
          , modalState = Hidden
          }
        , Cmd.batch
            [ getRotationGroup session rotationGroupId GotRotationGroup
            , groupDrafts session (Just rotationGroupId) GotDrafts
            , Task.perform GotTimezone Time.here
            ]
        )

    else
        ( { session = session
          , rotationGroupId = rotationGroupId
          , rotationGroup = NotAsked
          , groupDrafts = NotAsked
          , newDraft = NotAsked
          , timezone = Time.utc
          , alertVisibility = Alert.closed
          , modalState = Hidden
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

        GotTimezone zone ->
            ( { model | timezone = zone }, Cmd.none )

        GotRotationGroup result ->
            API.handleRemoteError result { model | rotationGroup = result } Cmd.none

        GotDrafts result ->
            API.handleRemoteError result { model | groupDrafts = RemoteData.map (List.sortBy (.insertedAt >> Time.posixToMillis) >> List.reverse) result } Cmd.none

        NewDraftClicked ->
            ( { model | newDraft = Loading }, createGroupDraft model.session { content = "Insert Draft Content Here", status = Unreviewed, rotationGroupId = model.rotationGroupId } NewDraftResult )

        NewDraftResult result ->
            case result of
                Success newDraft ->
                    ( { model | newDraft = result }, Route.pushUrl (Session.navKey model.session) (Route.Draft newDraft.id) )

                Failure _ ->
                    API.handleRemoteError result { model | alertVisibility = Alert.shown, newDraft = result } Cmd.none

                _ ->
                    API.handleRemoteError result { model | newDraft = result } Cmd.none

        AlertMsg visibility ->
            ( { model | alertVisibility = visibility }, Cmd.none )

        DeleteDraftClicked id ->
            ( { model | modalState = DeleteDraftShown id NotAsked Modal.shown }, Cmd.none )

        DeleteDraftSubmitted ->
            case model.modalState of
                DeleteDraftShown id _ _ ->
                    ( model, deleteDraft model.session id GotDeleteDraftResult )

                Hidden ->
                    ( model, Cmd.none )

        ModalClose ->
            case model.modalState of
                DeleteDraftShown id remote _ ->
                    ( { model | modalState = DeleteDraftShown id remote Modal.hidden }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        ModalAnimate visibility ->
            case model.modalState of
                DeleteDraftShown id remote _ ->
                    ( { model | modalState = DeleteDraftShown id remote visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )

        GotDeleteDraftResult result ->
            case model.modalState of
                DeleteDraftShown id _ visibility ->
                    case result of
                        Success _ ->
                            ( { model | modalState = DeleteDraftShown id result Modal.hidden }, groupDrafts model.session (Just model.rotationGroupId) GotDrafts )

                        _ ->
                            ( { model | modalState = DeleteDraftShown id result visibility }, Cmd.none )

                Hidden ->
                    ( model, Cmd.none )


viewDeleteModal : APIData () -> Modal.Visibility -> Html Msg
viewDeleteModal result visibility =
    Modal.config ModalClose
        |> Modal.withAnimation ModalAnimate
        |> Modal.small
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "Delete Draft" ]
        |> Modal.body []
            [ case result of
                  Failure error -> p [class "text-danger"] [(API.getErrorBody >> API.errorBodyToString >> text) error]
                  _ -> text ""
            , p [] [ text <| "Are you sure you want to delete this draft?" ]
            , p [] [ text "Deleting this draft will also delete its recorded observations, notes, and explanations." ]
            ]
        |> Modal.footer []
            [ Button.button
                [ Button.outlineDanger
                , Button.attrs [ onClick DeleteDraftSubmitted ]
                ]
                [ case result of
                      Loading -> Common.loading
                      _ -> text "Delete"
                ]
            ]
        |> Modal.view visibility


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Group Drafts"
    , content =
        let
            renderDraft draft =
                Grid.simpleRow
                    [ Grid.col []
                        [ Card.config []
                            |> Card.headerH3 []
                                [ text <| "Draft - " ++ Date.posixToDate model.timezone draft.insertedAt
                                , case draft.status of
                                    Unreviewed ->
                                        Badge.badgeDanger [] [ text "Unreviewed" ]

                                    Reviewing ->
                                        Badge.badgeInfo [] [ text "Reviewing" ]

                                    NeedsRevision ->
                                        Badge.badgeWarning [] [ text "Needs Revision" ]

                                    Approved ->
                                        Badge.badgeSuccess [] [ text "Approved" ]

                                    Emailed ->
                                        Badge.badgeSecondary [] [ text "Emailed" ]
                                ]
                            |> Card.block []
                                [ Block.titleH5 [] [ text <| "Last updated " ++ Date.posixToDate model.timezone draft.updatedAt ++ " at " ++ Date.posixToClockTime model.timezone draft.updatedAt ]
                                , Block.custom <|
                                    div []
                                        [ Button.linkButton [ Button.info, Button.attrs [ Route.href (Route.Draft draft.id) ] ] [ text "Edit" ]
                                        , Button.button [ Button.danger, Button.onClick <| DeleteDraftClicked draft.id ] [ text "Delete" ]
                                        ]
                                ]
                            |> Card.view
                        ]
                    ]

            viewDrafts =
                case model.groupDrafts of
                    Success drafts ->
                        if List.isEmpty drafts then
                            [ Grid.simpleRow
                                [ Grid.col []
                                    [ h5 [ class "text-warning" ] [ text "No drafts for group" ] ]
                                ]
                            ]

                        else
                            List.map renderDraft drafts

                    Failure error ->
                        [ Grid.simpleRow [ Grid.col [] [ (API.getErrorBody >> API.errorBodyToString >> text) error ] ] ]

                    _ ->
                        [ Grid.simpleRow [ Grid.col [] [ Common.loading ] ] ]
        in
        Grid.container [] <|
            [ case model.modalState of
                DeleteDraftShown _ result visibility ->
                    viewDeleteModal result visibility

                Hidden ->
                    text ""
            , case model.newDraft of
                Failure error ->
                    let
                        { title, message } =
                            API.getErrorBody error
                    in
                    dangerAlert title (Maybe.withDefault "" message) model.alertVisibility

                _ ->
                    text ""
            , Grid.simpleRow <|
                case model.rotationGroup of
                    Success group ->
                        [ Grid.col [ Col.lg11 ] [ h2 [] [ text <| "Rotation Group " ++ String.fromInt group.number ++ " - Drafts" ] ]
                        , Grid.col [ Col.lg1 ] [ Button.button [ Button.onClick NewDraftClicked, Button.success ] [ text "New" ] ]
                        ]

                    Failure error ->
                        [ Grid.col [] [ (API.getErrorBody >> API.errorBodyToString >> text) error ] ]

                    _ ->
                        [ Grid.col [] [ Common.loading ] ]
            ]
                ++ viewDrafts
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (Session.navKey model.session)
        , case model.modalState of
            DeleteDraftShown _ _ visibility ->
                Modal.subscriptions visibility ModalAnimate

            Hidden ->
                Sub.none
        ]


dangerAlert : String -> String -> Alert.Visibility -> Html Msg
dangerAlert title message visibility =
    Alert.config |> Alert.danger |> Alert.dismissableWithAnimation AlertMsg |> Alert.children [ Alert.h4 [] [ text title ], Alert.h6 [] [ text message ] ] |> Alert.view visibility
