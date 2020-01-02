module Main exposing (main)

import API as API exposing (Credential, credentialDecoder)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Either exposing (..)
import Html exposing (..)
import Json.Decode as Decode exposing (Value)
import Page
import Page.Blank as Blank
import Page.Dashboard as Dashboard
import Page.Draft as Draft
import Page.DraftClassrooms as DraftClassrooms
import Page.DraftRotations as DraftRotations
import Page.EditFeedback as EditFeedback
import Page.GroupDrafts as GroupDrafts
import Page.Login as Login
import Page.NotFound as NotFound
import Page.Profile as Profile
import Page.ResetPassword as ResetPassword
import Page.Classroom as Classroom
import Page.Section as Section
import Page.Rotation as Rotation
import Page.RotationGroup as RotationGroup
import Page.Semester as Semester
import Page.Category as Category
import Page.Observation as Observation
import Page.Feedback as Feedback
-- import Page.Explanation as Explanation
import Route exposing (Route(..))
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
    | ResetPassword ResetPassword.Model
    | DraftClassrooms DraftClassrooms.Model
    | DraftRotations DraftRotations.Model
    | GroupDrafts GroupDrafts.Model
    | EditFeedback EditFeedback.Model
    | Draft Draft.Model
    | Dashboard Dashboard.Model
    | Classroom Classroom.Model
    | Section Section.Model
    | Rotation Rotation.Model
    | RotationGroup RotationGroup.Model
    | Semester Semester.Model
    | Category Category.Model
    | Observation Observation.Model
    | Feedback Feedback.Model
    -- | Explanation Explanation.Model
    | Profile Profile.Model



-- UPDATE


type Msg
    = ChangedRoute (Maybe Route)
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLoginMsg Login.Msg
    | GotResetPasswordMsg ResetPassword.Msg
    | GotDraftClassroomsMsg DraftClassrooms.Msg
    | GotDraftRotationsMsg DraftRotations.Msg
    | GotGroupDraftsMsg GroupDrafts.Msg
    | GotEditFeedbackMsg EditFeedback.Msg
    | GotDraftMsg Draft.Msg
    | GotDashboardMsg Dashboard.Msg
    | GotClassroomMsg Classroom.Msg
    | GotSectionMsg Section.Msg
    | GotRotationMsg Rotation.Msg
    | GotRotationGroupMsg RotationGroup.Msg
    | GotSemesterMsg Semester.Msg
    | GotCategoryMsg Category.Msg
    | GotObservationMsg Observation.Msg
    | GotFeedbackMsg Feedback.Msg
    -- | GotExplanationMsg Explanation.Msg
    | GotProfileMsg Profile.Msg
    | GotSession Session


toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Login model ->
            Login.toSession model

        ResetPassword model ->
            ResetPassword.toSession model

        DraftClassrooms model ->
            DraftClassrooms.toSession model

        DraftRotations model ->
            DraftRotations.toSession model

        GroupDrafts model ->
            GroupDrafts.toSession model

        EditFeedback model ->
            EditFeedback.toSession model

        Draft model ->
            Draft.toSession model

        Profile model ->
            Profile.toSession model

        Dashboard model ->
            Dashboard.toSession model

        Classroom model ->
            Classroom.toSession model

        Section model ->
            Section.toSession model

        Rotation model ->
            Rotation.toSession model

        RotationGroup model ->
            RotationGroup.toSession model

        Semester model ->
            Semester.toSession model

        Category model ->
            Category.toSession model

        Observation model ->
            Observation.toSession model

        Feedback model ->
            Feedback.toSession model

        -- -- Explanation model ->
        -- --     Explanation.toSession model


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
            ( model, Route.replaceUrl (Session.navKey session) Route.Dashboard )

        Just Route.Login ->
            Login.init session
                |> updateWith Login GotLoginMsg model

        Just (Route.ResetPassword maybeToken) ->
            ResetPassword.init session maybeToken
                |> updateWith ResetPassword GotResetPasswordMsg model

        Just Route.Logout ->
            ( model, API.logout )

        Just Route.Dashboard ->
            Dashboard.init session
                |> updateWith Dashboard GotDashboardMsg model

        Just (Route.Classroom classroomId) ->
            Classroom.init session classroomId
                |> updateWith Classroom GotClassroomMsg model

        Just (Route.Section sectionId) ->
            Section.init session sectionId
                |> updateWith Section GotSectionMsg model

        Just (Route.Rotation rotationId) ->
            Rotation.init session rotationId
                |> updateWith Rotation GotRotationMsg model

        Just (Route.RotationGroup rotationGroupId) ->
            RotationGroup.init session rotationGroupId
                |> updateWith RotationGroup GotRotationGroupMsg model

        Just (Route.Semester semesterId) ->
            Semester.init session semesterId
                |> updateWith Semester GotSemesterMsg model

        Just (Route.Category categoryId) ->
            Category.init session categoryId
                |> updateWith Category GotCategoryMsg model

        Just (Route.Observation observationId) ->
            Observation.init session observationId
                |> updateWith Observation GotObservationMsg model

        Just (Route.FeedbackItem feedbackId) ->
            Feedback.init session feedbackId
                |> updateWith Feedback GotFeedbackMsg model

        -- Just (Route.Explanation explanationId) ->
        --     Explanation.init session explanationId
        --         |> updateWith Explanation GotExplanationMsg model

        Just Route.DraftClassrooms ->
            DraftClassrooms.init session
                |> updateWith DraftClassrooms GotDraftClassroomsMsg model

        Just (Route.DraftRotations sectionId) ->
            DraftRotations.init session sectionId
                |> updateWith DraftRotations GotDraftRotationsMsg model

        Just (Route.GroupDrafts rotationGroupId) ->
            GroupDrafts.init session rotationGroupId
                |> updateWith GroupDrafts GotGroupDraftsMsg model

        Just (Route.EditFeedback draftId maybeCategoryId) ->
            EditFeedback.init session draftId maybeCategoryId
                |> updateWith EditFeedback GotEditFeedbackMsg model

        Just (Route.Draft rotationGroupId draftId) ->
            Draft.init rotationGroupId draftId session
                |> updateWith Draft GotDraftMsg model

        Just Route.Profile ->
            Profile.init session
                |> updateWith Profile GotProfileMsg model

        Just _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update appMsg appModel =
    case ( appMsg, appModel ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( appModel
                    , Nav.pushUrl (Session.navKey (toSession appModel)) (Url.toString url)
                    )

                Browser.External href ->
                    ( appModel
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) appModel

        ( ChangedRoute route, _ ) ->
            changeRouteTo route appModel

        ( GotLoginMsg msg, Login model ) ->
            Login.update msg model
                |> updateWith Login GotLoginMsg appModel

        ( GotResetPasswordMsg msg, ResetPassword model ) ->
            ResetPassword.update msg model
                |> updateWith ResetPassword GotResetPasswordMsg appModel

        ( GotDashboardMsg msg, Dashboard model ) ->
            Dashboard.update msg model
                |> updateWith Dashboard GotDashboardMsg appModel

        ( GotClassroomMsg msg, Classroom model ) ->
            Classroom.update msg model
                |> updateWith Classroom GotClassroomMsg appModel

        ( GotSectionMsg msg, Section model ) ->
            Section.update msg model
                |> updateWith Section GotSectionMsg appModel

        ( GotRotationMsg msg, Rotation model ) ->
            Rotation.update msg model
                |> updateWith Rotation GotRotationMsg appModel

        ( GotRotationGroupMsg msg, RotationGroup model ) ->
            RotationGroup.update msg model
                |> updateWith RotationGroup GotRotationGroupMsg appModel

        ( GotSemesterMsg msg, Semester model ) ->
            Semester.update msg model
                |> updateWith Semester GotSemesterMsg appModel

        ( GotCategoryMsg msg, Category model ) ->
            Category.update msg model
                |> updateWith Category GotCategoryMsg appModel

        ( GotObservationMsg msg, Observation model ) ->
            Observation.update msg model
                |> updateWith Observation GotObservationMsg appModel

        ( GotFeedbackMsg msg, Feedback model ) ->
            Feedback.update msg model
                |> updateWith Feedback GotFeedbackMsg appModel

        -- ( GotExplanationMsg msg, Explanation model ) ->
        --     Explanation.update msg model
        --         |> updateWith Explanation GotExplanationMsg appModel

        ( GotDraftClassroomsMsg msg, DraftClassrooms model ) ->
            DraftClassrooms.update msg model
                |> updateWith DraftClassrooms GotDraftClassroomsMsg appModel

        ( GotDraftRotationsMsg msg, DraftRotations model ) ->
            DraftRotations.update msg model
                |> updateWith DraftRotations GotDraftRotationsMsg appModel

        ( GotGroupDraftsMsg msg, GroupDrafts model ) ->
            GroupDrafts.update msg model
                |> updateWith GroupDrafts GotGroupDraftsMsg appModel

        ( GotEditFeedbackMsg msg, EditFeedback model ) ->
            EditFeedback.update msg model
                |> updateWith EditFeedback GotEditFeedbackMsg appModel

        ( GotDraftMsg msg, Draft model ) ->
            Draft.update msg model
                |> updateWith Draft GotDraftMsg appModel

        ( GotProfileMsg msg, Profile model ) ->
            Profile.update msg model
                |> updateWith Profile GotProfileMsg appModel

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( appModel, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions appModel =
    case appModel of
        NotFound _ ->
            Sub.none

        Redirect _ ->
            Session.changes GotSession (Session.navKey (toSession appModel))

        Login model ->
            Sub.map GotLoginMsg (Login.subscriptions model)

        ResetPassword model ->
            Sub.map GotResetPasswordMsg (ResetPassword.subscriptions model)

        DraftClassrooms model ->
            Sub.map GotDraftClassroomsMsg (DraftClassrooms.subscriptions model)

        DraftRotations model ->
            Sub.map GotDraftRotationsMsg (DraftRotations.subscriptions model)

        GroupDrafts model ->
            Sub.map GotGroupDraftsMsg (GroupDrafts.subscriptions model)

        EditFeedback model ->
            Sub.map GotEditFeedbackMsg (EditFeedback.subscriptions model)

        Draft model ->
            Sub.map GotDraftMsg (Draft.subscriptions model)

        Profile model ->
            Sub.map GotProfileMsg (Profile.subscriptions model)

        Dashboard model ->
            Sub.map GotDashboardMsg (Dashboard.subscriptions model)

        Classroom model ->
            Sub.map GotClassroomMsg (Classroom.subscriptions model)

        Section model ->
            Sub.map GotSectionMsg (Section.subscriptions model)

        Rotation model ->
            Sub.map GotRotationMsg (Rotation.subscriptions model)

        RotationGroup model ->
            Sub.map GotRotationGroupMsg (RotationGroup.subscriptions model)

        Semester model ->
            Sub.map GotSemesterMsg (Semester.subscriptions model)

        Category model ->
            Sub.map GotCategoryMsg (Category.subscriptions model)

        Observation model ->
            Sub.map GotObservationMsg (Observation.subscriptions model)

        Feedback model ->
            Sub.map GotFeedbackMsg (Feedback.subscriptions model)

        -- Explanation model ->
        --     Sub.map GotExplanationMsg (Explanation.subscriptions model)



-- VIEW


view : Model -> Document Msg
view appModel =
    let
        maybeUser =
            Maybe.map API.credentialUser (Session.credential (toSession appModel))
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
            case appModel of
                Redirect _ ->
                    Page.viewPublic Blank.view

                NotFound _ ->
                    Page.viewPublic NotFound.view

                -- Login shouldn't be visible when authenticated.
                Login _ ->
                    Page.viewPublic NotFound.view

                ResetPassword _ ->
                    Page.viewPublic NotFound.view

                Dashboard model ->
                    viewPage Page.Dashboard GotDashboardMsg (Dashboard.view model)

                Classroom model ->
                    viewPage Page.Classroom GotClassroomMsg (Classroom.view model)

                Section model ->
                    viewPage Page.Section GotSectionMsg (Section.view model)

                Rotation model ->
                    viewPage Page.Rotation GotRotationMsg (Rotation.view model)

                RotationGroup model ->
                    viewPage Page.RotationGroup GotRotationGroupMsg (RotationGroup.view model)

                Semester model ->
                    viewPage Page.Semester GotSemesterMsg (Semester.view model)

                Category model ->
                    viewPage Page.Category GotCategoryMsg (Category.view model)

                Observation model ->
                    viewPage Page.Observation GotObservationMsg (Observation.view model)

                Feedback model ->
                    viewPage Page.Feedback GotFeedbackMsg (Feedback.view model)

                -- Explanation model ->
                --     viewPage Page.Explanation GotExplanationMsg (Explanation.view model)

                DraftClassrooms model ->
                    viewPage Page.DraftClassrooms GotDraftClassroomsMsg (DraftClassrooms.view model)

                DraftRotations model ->
                    viewPage Page.DraftRotations GotDraftRotationsMsg (DraftRotations.view model)

                GroupDrafts model ->
                    viewPage Page.GroupDrafts GotGroupDraftsMsg (GroupDrafts.view model)

                EditFeedback model ->
                    viewPage Page.EditFeedback GotEditFeedbackMsg (EditFeedback.view model)

                Draft model ->
                    viewPage Page.Draft GotDraftMsg (Draft.view model)

                Profile model ->
                    viewPage Page.Profile GotProfileMsg (Profile.view model)

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
            case appModel of
                Login login ->
                    viewPage GotLoginMsg (Login.view login)

                ResetPassword reset ->
                    viewPage GotResetPasswordMsg (ResetPassword.view reset)

                _ ->
                    Page.viewPublic NotFound.view
