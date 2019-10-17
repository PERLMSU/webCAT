module Page.EditFeedback exposing (Model, Msg(..), init, subscriptions, toSession, update, view)

import API exposing (APIData, APIResult, Error(..))
import API.Feedback exposing (..)
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
import Either exposing (Either(..))

type alias Model =
    { session : Session
    , draftId : DraftId
    , parentCategoryId : Maybe CategoryId
    -- Remote data
    , categories : APIData (List Category)
    , studentFeedback : APIData (List StudentFeedback)
    , studentExplanations : APIData (List StudentExplanation)
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
     -- Init stuff
    | GotDraft (APIData (Either GroupDraft StudentDraft))


init : Session -> DraftId -> Maybe CategoryId -> ( Model, Cmd Msg )
init session draftId maybeCategoryId =
    if Session.isAuthenticated session then
        let
            feedbackCommands =
                [ studentFeedback session draftId GotStudentFeedback
                , studentExplanations session draftId Nothing GotStudentExplanations
                ]
        in
        case maybeCategoryId of
            Just parentCategoryId ->
                ( { session = session
                  , draftId = draftId
                  , parentCategoryId = maybeCategoryId
                  , studentFeedback = Loading
                  , studentExplanations = Loading
                  , categories = Loading
                  }
                , Cmd.batch <| category session parentCategoryId GotCategory :: feedbackCommands
                )

            Nothing ->
                ( { session = session
                  , draftId = draftId
                  , parentCategoryId = maybeCategoryId
                  , studentFeedback = Loading
                  , studentExplanations = Loading
                  , categories = Loading
                  }
                , Cmd.batch <| draft session draftId GotDraft :: feedbackCommands
                )

    else
        ( { session = session
          , draftId = draftId
          , parentCategoryId = maybeCategoryId
          , categories = NotAsked
          , studentFeedback = NotAsked
          , studentExplanations = NotAsked
          }
        , Route.replaceUrl (Session.navKey session) (Route.Login )
        )


toSession : Model -> Session
toSession model =
    model.session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            init session model.draftId model.parentCategoryId

        GotCategories categories ->
            ( { model | categories = categories }, Cmd.none )

        GotStudentFeedback feedback ->
            ( { model | studentFeedback = feedback }, Cmd.none )

        GotStudentExplanations explanations ->
            ( { model | studentExplanations = explanations }, Cmd.none )

        GotCategory category ->
            ( { model | categories = RemoteData.map List.singleton category }, Cmd.none )

        SubCategorySelected id ->
            ( model, Route.pushUrl (Session.navKey model.session) (Route.EditFeedback model.draftId (Just id)) )

        FeedbackChecked feedbackId isChecked ->
            case isChecked of
                True ->
                    ( model, createStudentFeedback model.session model.draftId feedbackId GotAddFeedbackResult )

                False ->
                    --( model, deleteStudentFeedback model.session model.draftId feedbackId (GotDeleteFeedbackResult feedbackId) )
                    (model, Cmd.none)

        ExplanationChecked feedbackId explanationId isChecked ->
            case isChecked of
                True ->
                    ( model, createStudentExplanation model.session model.draftId feedbackId explanationId GotAddExplanationResult )

                False ->
                    -- ( model, deleteStudentExplanation model.session model.draftId feedbackId explanationId (GotDeleteExplanationResult explanationId) )
                    (model, Cmd.none)

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

        GotDraft result ->
           case result of
               Success draft ->
                   case draft of
                       Left groupDraft -> (model, Cmd.batch <| List.map (\id-> category model.session id GotCategory) groupDraft.categories)
                       Right studentDraft -> (model, Cmd.none)
               Failure error ->
                   -- TODO: Work out showing error states way better
                   (model, Cmd.none)
               _ -> (model, Cmd.none)


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
                [ div [ class "py-1 flex flex-row content-center" ]
                    [ input
                        [ type_ "checkbox"
                        , class "self-center leading-tight mr-2"
                        , onCheck <| ExplanationChecked explanation.feedbackId explanation.id
                        , checked <| hasExplanation model explanation.id

                        -- Only enable if the parent feedback item is checked
                        , disabled <| not <| hasFeedbackItem model explanation.feedbackId
                        ]
                        []
                    , span [] [ text explanation.content ]
                    ]
                ]

        viewFeedback feedback =
            li []
                [ div [ class "py-1 flex flex-row content-center" ]
                    [ input
                        [ type_ "checkbox"
                        , class "self-center leading-tight mr-2"
                        , onCheck <| FeedbackChecked feedback.id
                        , checked <| hasFeedbackItem model feedback.id
                        ]
                        []
                    , span [] [ text feedback.content ]
                    ]
                , ul [ class "ml-4" ] []
                --, ul [ class "ml-4" ] <| List.map viewExplanation <| unwrapMaybeDefault unwrapExplanations feedback.explanations
                ]

        viewObservation observation =
            li [ class "text-l text-gray-500" ]
                [ text observation.content
                , ul [ class "ml-4" ] []
                --, ul [ class "ml-4" ] <| List.map viewFeedback <| unwrapMaybeDefault unwrapFeedback observation.feedback
                ]

        viewSubcategory category =
            li [ class "text-l text-gray-500" ] [ button [ onClick (SubCategorySelected category.id) ] [ text category.name ] ]

        viewCategory category =
            Common.panel
                [ div [ class "mx-4 my-2 flex" ]
                    [ Common.header category.name ]
                , h3 [ class "text-xl text-gray-400 ml-4" ] [ text "Sub-categories" ]
                , ul [ class "mx-4" ] []
                --, ul [ class "mx-4" ] <| List.map viewSubcategory <| List.sortBy .name <| unwrapMaybeDefault unwrapCategories category.subCategories
                , h3 [ class "text-xl text-gray-400 ml-4" ] [ text "Observations" ]
                , ul [ class "mx-4" ] []
                --, ul [ class "mx-4" ] <| List.map viewObservation <| List.sortBy .content <| unwrapMaybeDefault unwrapObservations category.observations
                ]
    in
    div [] <| List.map viewCategory <| List.sortBy .name categories


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
