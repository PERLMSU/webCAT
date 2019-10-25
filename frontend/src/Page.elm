module Page exposing (Page(..), view, viewPublic)

import API exposing (Credential)
import API.Endpoint as Endpoint
import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, src, style)
import Html.Events exposing (onClick)
import Route exposing (Route)
import Session exposing (Session)
import Types exposing (..)


type Page
    = Other
    | Dashboard
    | Login
    | Classrooms
    | Users
    | DraftClassrooms
    | DraftRotations
    | GroupDrafts
    | Draft
    | EditFeedback
    | Profile


view : User -> Page -> { title : String, content : Html msg } -> Document msg
view user page { title, content } =
    { title = title ++ " - WebCAT"
    , body =
        let
            viewFooter =
                footer [ class "footer mt-auto py-3" ]
                    [ div [ class "container d-flex flex-row justify-content-center" ]
                        [ span [ class "mx-2" ] [ text "Version 1.0.0-dev" ]
                        , span [ class "mx-2" ] [ text "|" ]
                        , span [ class "mx-2" ] [ text "Built on 2019-10-25 at 8:50am EST" ]
                        ]
                    ]
        in
        [ div [ class "d-flex flex-column h-100" ]
            [ viewMenu page user
            , main_ [ attribute "role" "main", class "flex-shrink-0" ] [ content ]
            , viewFooter
            ]
        ]
    }


viewPublic : { title : String, content : Html msg } -> Document msg
viewPublic { title, content } =
    { title = title ++ " - WebCAT"
    , body = [ content ]
    }


viewMenu : Page -> User -> Html msg
viewMenu page user =
    let
        navItem route text_ =
            li [ classList [ ( "nav-item", True ), ( "active", isActive page route ) ] ] [ a [ class "nav-link", Route.href route ] [ text text_ ] ]
    in
    nav [ class "navbar navbar-expand-md navbar-dark bg-primary mb-4" ]
        [ a [ href "#", class "navbar-brand" ] [ text "WebCAT" ]
        , div [ class "collapse navbar-collapse", id "navbarCollapse" ]
            [ ul [ class "navbar-nav mr-auto" ] <|
                case user.role of
                    LearningAssistant ->
                        [ navItem Route.DraftClassrooms "Feedback Editor" ]

                    Student ->
                        []

                    _ ->
                        [ navItem Route.Dashboard "Dashboard"
                        , navItem Route.DraftClassrooms "Feedback Editor"
                        ]
            , a [ Route.href Route.Profile, class "d-flex flex-row align-items-center" ]
                [ img
                    [ Endpoint.src <| Endpoint.profilePicture user.id
                    , class "rounded-circle"
                    , style "width" "2.5rem"
                    , style "height" "2.5rem"
                    ]
                    []
                , span [ class "ml-2" ] [ text <| user.firstName ++ " " ++ user.lastName ]
                ]
            ]
        ]


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Dashboard, Route.Dashboard ) ->
            True

        ( DraftClassrooms, Route.DraftClassrooms ) ->
            True

        _ ->
            False
