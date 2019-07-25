module Main exposing (main)

import API as API exposing (Credential, credentialDecoder)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Page
import Page.Blank as Blank
import Page.Classrooms as Classrooms
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
    | Classrooms Classrooms.Model



-- UPDATE


type Msg
    = ChangedRoute (Maybe Route)
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLoginMsg Login.Msg
    | GotClassroomsMsg Classrooms.Msg
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

        Classrooms classrooms ->
            Classrooms.toSession classrooms


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Root ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Classrooms )

        Just (Route.Login maybeToken) ->
            Login.init session
                |> updateWith Login GotLoginMsg model

        Just Route.Logout ->
            ( model, API.logout )

        Just Route.Classrooms ->
            Classrooms.init session
                |> updateWith Classrooms GotClassroomsMsg model

        Just _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
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

        ( GotClassroomsMsg subMsg, Classrooms classrooms ) ->
            Classrooms.update subMsg classrooms
                |> updateWith Classrooms GotClassroomsMsg model

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

        Classrooms classrooms ->
            Sub.map GotClassroomsMsg (Classrooms.subscriptions classrooms)



-- VIEW


view : Model -> Document Msg
view model =
    let
        maybeUser =
            Maybe.map API.credentialUser (Session.credential (toSession model))
    in
    case maybeUser of
        Just user ->
            let
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
                    Page.viewPublic Blank.view

                NotFound _ ->
                    Page.viewPublic NotFound.view

                -- Login shouldn't be visible when authenticated.
                Login _ ->
                    Page.viewPublic NotFound.view

                Classrooms classrooms ->
                    viewPage Page.Classrooms GotClassroomsMsg (Classrooms.view classrooms)

        Nothing ->
            let
                viewPage toMsg config =
                    let
                        { title, body } =
                            Page.viewPublic config
                    in
                    { title = title
                    , body = List.map (Html.map toMsg) body
                    }
            in
            case model of
                Redirect _ ->
                    Page.viewPublic Blank.view

                NotFound _ ->
                    Page.viewPublic NotFound.view

                Login login ->
                    viewPage GotLoginMsg (Login.view login)

                Classrooms _ ->
                    Page.viewPublic NotFound.view
