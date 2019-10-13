module Main exposing (main)

import API as API exposing (Credential, credentialDecoder)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Either exposing (..)
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Page
import Page.Blank as Blank
import Page.Classrooms as Classrooms
import Page.Dashboard as Dashboard
import Page.Draft as Draft
import Page.DraftClassrooms as DraftClassrooms
import Page.EditFeedback as EditFeedback
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Profile as Profile
import Page.Users as Users
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
    | Users Users.Model
    | DraftClassrooms DraftClassrooms.Model
    | EditFeedback EditFeedback.Model
    | Draft Draft.Model
    | Profile Profile.Model



-- UPDATE


type Msg
    = ChangedRoute (Maybe Route)
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLoginMsg Login.Msg
    | GotClassroomsMsg Classrooms.Msg
    | GotUsersMsg Users.Msg
    | GotDraftClassroomsMsg DraftClassrooms.Msg
    | GotEditFeedbackMsg EditFeedback.Msg
    | GotDraftMsg Draft.Msg
    | GotProfileMsg Profile.Msg
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

        Users users ->
            Users.toSession users

        DraftClassrooms classrooms ->
            DraftClassrooms.toSession classrooms

        EditFeedback feedback ->
            EditFeedback.toSession feedback

        Draft draft ->
            Draft.toSession draft

        Profile profile ->
            Profile.toSession profile


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

        Just Route.Users ->
            Users.init session
                |> updateWith Users GotUsersMsg model

        Just Route.DraftClassrooms ->
            DraftClassrooms.init session
                |> updateWith DraftClassrooms GotDraftClassroomsMsg model

        Just (Route.EditFeedback draftId maybeCategoryId) ->
            EditFeedback.init session draftId maybeCategoryId
                |> updateWith EditFeedback GotEditFeedbackMsg model

        Just (Route.Draft draftId) ->
            Draft.init draftId session
                |> updateWith Draft GotDraftMsg model

        Just Route.Profile ->
            Profile.init session
                |> updateWith Profile GotProfileMsg model

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

        ( GotUsersMsg subMsg, Users users ) ->
            Users.update subMsg users
                |> updateWith Users GotUsersMsg model

        ( GotDraftClassroomsMsg subMsg, DraftClassrooms classrooms ) ->
            DraftClassrooms.update subMsg classrooms
                |> updateWith DraftClassrooms GotDraftClassroomsMsg model

        ( GotEditFeedbackMsg subMsg, EditFeedback feedback ) ->
            EditFeedback.update subMsg feedback
                |> updateWith EditFeedback GotEditFeedbackMsg model

        ( GotDraftMsg subMsg, Draft draft ) ->
            Draft.update subMsg draft
                |> updateWith Draft GotDraftMsg model

        ( GotProfileMsg subMsg, Profile profile ) ->
            Profile.update subMsg profile
                |> updateWith Profile GotProfileMsg model

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

        DraftClassrooms classrooms ->
            Sub.map GotDraftClassroomsMsg (DraftClassrooms.subscriptions classrooms)

        EditFeedback feedback ->
            Sub.map GotEditFeedbackMsg (EditFeedback.subscriptions feedback)

        Draft draft ->
            Sub.map GotDraftMsg (Draft.subscriptions draft)

        Profile profile ->
            Sub.map GotProfileMsg (Profile.subscriptions profile)

        Users users ->
            Sub.map GotUsersMsg (Users.subscriptions users)



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

                DraftClassrooms classrooms ->
                    viewPage Page.DraftClassrooms GotDraftClassroomsMsg (DraftClassrooms.view classrooms)

                EditFeedback feedback ->
                    viewPage Page.EditFeedback GotEditFeedbackMsg (EditFeedback.view feedback)

                Draft draft ->
                    viewPage Page.Draft GotDraftMsg (Draft.view draft)

                Profile profile ->
                    viewPage Page.Profile GotProfileMsg (Profile.view profile)

                Users users ->
                    viewPage Page.Users GotUsersMsg (Users.view users)

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
                Login login ->
                    viewPage GotLoginMsg (Login.view login)

                _ ->
                    Page.viewPublic NotFound.view