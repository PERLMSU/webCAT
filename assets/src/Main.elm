module Main exposing (main)

import API as API exposing (Credential, credentialDecoder)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Page
import Page.Blank as Blank
import Page.Dashboard as Dashboard
import Page.Login as Login
import Page.NotFound as NotFound
import Route exposing (LoginToken, Route(..))
import Session exposing (Session)
import Task
import Time
import Url exposing (Url)



-- MAIN


main : Program Value Model Msg
main =
    API.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : Maybe Credential -> Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeCred url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.fromCredential navKey maybeCred))



-- MODEL


type Model
    = Redirect Session
    | NotFound Session
    | Login Login.Model
    | Dashboard Dashboard.Model



-- UPDATE


type Msg
    = ChangedRoute (Maybe Route)
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLoginMsg Login.Msg
    | GotDashboardMsg Dashboard.Msg
    | GotSession Session


toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Login login ->
            Login.toSession login

        Dashboard dashboard ->
            Dashboard.toSession dashboard


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model

        _ =
            Debug.log "session" session
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Root ->
            ( model, Route.replaceUrl (Session.navKey session) (Route.Dashboard Nothing) )

        Just (Route.Login maybeToken) ->
            Login.init session
                |> updateWith Login GotLoginMsg model

        Just (Route.Dashboard maybeId) ->
            Dashboard.init session maybeId
                |> updateWith Dashboard GotDashboardMsg model

        Just _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            ( model, Cmd.none )

                        Just _ ->
                            ( model
                            , Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                            )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ChangedRoute route, _ ) ->
            changeRouteTo route model

        ( GotLoginMsg subMsg, Login login ) ->
            Login.update subMsg login
                |> updateWith Login GotLoginMsg model

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        NotFound _ ->
            Sub.none

        Redirect _ ->
            Session.changes GotSession (Session.navKey (toSession model))

        Login login ->
            Sub.map GotLoginMsg (Login.subscriptions login)

        Dashboard dashboard ->
            Sub.map GotDashboardMsg (Dashboard.subscriptions dashboard)



-- VIEW


view : Model -> Document Msg
view model =
    let
        user =
            Maybe.map API.credentialUser (Session.credential (toSession model))

        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view user page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            Page.view user Page.Other Blank.view

        NotFound _ ->
            Page.view user Page.Other NotFound.view

        Login login ->
            viewPage Page.Login GotLoginMsg (Login.view login)

        Dashboard dashboard ->
            viewPage Page.Dashboard GotDashboardMsg (Dashboard.view dashboard)
