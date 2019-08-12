module Page.EditFeedback exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, APIResult, Error(..))
import API.Feedback exposing (..)
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
    , groupId : RotationGroupId
    , studentId : UserId
    , categories : APIData (List Category)
    , studentFeedback : APIData (List StudentFeedback)
    , studentExplanations : APIData (List StudentExplanation)
    , parentCategoryId : Maybe CategoryId
    }


type Msg
    = GotSession Session
    | GotStudentFeedback (APIData (List StudentFeedback))
    | GotStudentExplanations (APIData (List StudentExplanation))
    | GotCategories (APIData (List Category))
    | GotCategory (APIData Category)
    | GotAddFeedbackResult (APIResult StudentFeedback)
    | GotDeleteFeedbackResult FeedbackId (APIResult ())
    | GotAddExplanationResult (APIResult StudentExplanation)
    | GotDeleteExplanationResult ExplanationId (APIResult ())
      -- Buttons
    | SubCategorySelected CategoryId
      -- Checkboxes
    | FeedbackChecked FeedbackId Bool
    | ExplanationChecked FeedbackId ExplanationId Bool


init : Session -> RotationGroupId -> UserId -> Maybe CategoryId -> ( Model, Cmd Msg )
init session groupId studentId maybeCategoryId =
    if Session.isAuthenticated session then
        let
            feedbackCommands =
                [ studentFeedback session groupId studentId GotStudentFeedback
                , studentExplanations session groupId studentId GotStudentExplanations
                ]
        in
        case maybeCategoryId of
            Just categoryId ->
                ( { session = session
                  , groupId = groupId
                  , studentId = studentId
                  , parentCategoryId = maybeCategoryId
                  , studentFeedback = Loading
                  , studentExplanations = Loading
                  , categories = Loading
                  }
                , Cmd.batch <| category session categoryId GotCategory :: feedbackCommands
                )

            Nothing ->
                ( { session = session
                  , groupId = groupId
                  , studentId = studentId
                  , parentCategoryId = maybeCategoryId
                  , studentFeedback = Loading
                  , studentExplanations = Loading
                  , categories = Loading
                  }
                , Cmd.batch <| rotationGroupClassroomCategories session groupId GotCategories :: feedbackCommands
                )

    else
        ( { session = session
          , groupId = groupId
          , studentId = studentId
          , parentCategoryId = maybeCategoryId
          , categories = NotAsked
          , studentFeedback = NotAsked
          , studentExplanations = NotAsked
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
            init session model.groupId model.studentId model.parentCategoryId

        GotCategories categories ->
            ( { model | categories = categories }, Cmd.none )

        GotStudentFeedback feedback ->
            ( { model | studentFeedback = feedback }, Cmd.none )

        GotStudentExplanations explanations ->
            ( { model | studentExplanations = explanations }, Cmd.none )

        GotCategory category ->
            ( { model | categories = RemoteData.map List.singleton category }, Cmd.none )

        SubCategorySelected id ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.EditFeedback model.groupId model.studentId (Just id)) )

        FeedbackChecked feedbackId isChecked ->
            case isChecked of
                True ->
                    ( model, addStudentFeedback model.session model.groupId model.studentId feedbackId GotAddFeedbackResult )

                False ->
                    ( model, deleteStudentFeedback model.session model.groupId model.studentId feedbackId (GotDeleteFeedbackResult feedbackId) )

        ExplanationChecked feedbackId explanationId isChecked ->
            case isChecked of
                True ->
                    ( model, addStudentExplanation model.session model.groupId model.studentId feedbackId explanationId GotAddExplanationResult )

                False ->
                    ( model, deleteStudentExplanation model.session model.groupId model.studentId feedbackId explanationId (GotDeleteExplanationResult explanationId) )

        GotAddFeedbackResult result ->
            case result of
                Ok value ->
                    ( { model | studentFeedback = RemoteData.map ((::) value) model.studentFeedback }, Cmd.none )

                Err error ->
                    -- TODO: Work out global message passing for errors to the main process
                    ( model, Cmd.none )

        GotDeleteFeedbackResult id result ->
            case result of
                Ok _ ->
                    ( { model
                        | studentFeedback = RemoteData.map (List.filter (\fb -> fb.feedbackId /= id)) model.studentFeedback
                        , studentExplanations = RemoteData.map (List.filter (\ex -> ex.feedbackId /= id)) model.studentExplanations
                      }
                    , Cmd.none
                    )

                Err error ->
                    -- TODO: Work out global message passing for errors to the main process
                    ( model, Cmd.none )

        GotAddExplanationResult result ->
            case result of
                Ok value ->
                    ( { model | studentExplanations = RemoteData.map ((::) value) model.studentExplanations }, Cmd.none )

                Err error ->
                    -- TODO: Work out global message passing for errors to the main process
                    ( model, Cmd.none )

        GotDeleteExplanationResult id result ->
            case result of
                Ok _ ->
                    ( { model | studentExplanations = RemoteData.map (List.filter (\ex -> ex.explanationId /= id)) model.studentExplanations }, Cmd.none )

                Err error ->
                    -- TODO: Work out global message passing for errors to the main process
                    ( model, Cmd.none )


hasFeedbackItem : Model -> FeedbackId -> Bool
hasFeedbackItem model id =
    case model.studentFeedback of
        Success feedback ->
            List.any (\item -> item.feedbackId == id) feedback

        _ ->
            False


hasExplanation : Model -> ExplanationId -> Bool
hasExplanation model id =
    case model.studentExplanations of
        Success explanations ->
            List.any (\item -> item.explanationId == id) explanations

        _ ->
            False


viewCategories : Model -> List Category -> Html Msg
viewCategories model categories =
    let
        unwrapMaybeDefault fun maybe =
            Maybe.withDefault [] <| Maybe.map fun maybe

        viewExplanation explanation =
            li []
                [ input
                    [ type_ "checkbox"
                    , onCheck <| ExplanationChecked explanation.feedbackId explanation.id
                    , checked <| hasExplanation model explanation.id

                    -- Only enable if the parent feedback item is checked
                    , disabled <| not <| hasFeedbackItem model explanation.feedbackId
                    ]
                    []
                , text explanation.content
                ]

        viewFeedback feedback =
            li []
                [ div []
                    [ input
                        [ type_ "checkbox"
                        , onCheck <| FeedbackChecked feedback.id
                        , checked <| hasFeedbackItem model feedback.id
                        ]
                        []
                    , text feedback.content
                    ]
                , ul [ class "ml-4" ] <| List.map viewExplanation <| unwrapMaybeDefault unwrapExplanations feedback.explanations
                ]

        viewObservation observation =
            li []
                [ text observation.content
                , ul [ class "ml-4" ] <| List.map viewFeedback <| unwrapMaybeDefault unwrapFeedback observation.feedback
                ]

        viewSubcategory category =
            li [] [ button [ onClick (SubCategorySelected category.id) ] [ text category.name ] ]

        viewCategory category =
            Common.panel
                [ div [ class "mx-4 my-2 flex" ]
                    [ Common.header category.name ]
                , h3 [] [ text "sub categories" ]
                , ul [] <| List.map viewSubcategory <| unwrapMaybeDefault unwrapCategories category.subCategories
                , h3 [] [ text "observations" ]
                , ul [] <| List.map viewObservation <| unwrapMaybeDefault unwrapObservations category.observations
                ]
    in
    div [] <| List.map viewCategory categories


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Edit Feedback"
    , content =
        div []
            [ case model.categories of
                NotAsked ->
                    text ""

                Loading ->
                    Common.panel [ Common.loading ]

                Success c ->
                    viewCategories model c

                Failure e ->
                    div [ class "mx-4 my-2 flex" ] [ div [ class "text-danger text-bold" ] [ text <| API.errorBodyToString <| API.getErrorBody e ] ]
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
