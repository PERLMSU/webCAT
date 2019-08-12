module Page exposing (Page(..), view, viewErrors, viewPublic)

import API exposing (Credential)
import Browser exposing (Document)
import Html exposing (Html, a, button, div, footer, h2, h3, hr, i, img, li, nav, p, span, text, ul)
import Html.Attributes exposing (class, classList, href, id, src, style)
import Html.Events exposing (onClick)
import Route exposing (Route)
import Session exposing (Session)
import Types exposing (User)


{-| Determines which navbar link (if any) will be rendered as active.
Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.
-}
type Page
    = Other
    | Dashboard
    | Login
    | Classrooms
    | Users
    | Feedback
    | EditFeedback
    | Drafts
    | Profile


{-| Take a page's Html and frames it with a header and footer.
The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.
isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)
-}
view : User -> Page -> { title : String, content : Html msg } -> Document msg
view user page { title, content } =
    { title = title ++ " - WebCAT"
    , body = [ viewGrid (viewMenu page user) content viewFooter ]
    }


viewPublic : { title : String, content : Html msg } -> Document msg
viewPublic { title, content } =
    { title = title ++ " - WebCAT"
    , body = [ content ]
    }


viewGrid : Html msg -> Html msg -> Html msg -> Html msg
viewGrid menu content footer =
    div [ id "main-container", class "w-screen min-h-screen" ]
        [ div [ id "sidebar", class "bg-light-slate" ] [ div [ class "" ] [ menu ] ]
        , div [ id "content", class "bg-slate" ] [ div [ class "container p-1" ] [ content ] ]
        , div [ id "footer", class "bg-slate border border-light-slate" ] [ div [ class "container p-1 mx-auto" ] [ footer ] ]
        ]


viewMenu : Page -> User -> Html msg
viewMenu page user =
    let
        userItem =
            div [ class "flex items-center m-2" ]
                [ img [ class "flex-shrink-0 h-10 w-10 rounded-full mx-1", src "https://avatars3.githubusercontent.com/u/2858049?s=460&v=4" ] []
                , div [ class "text-left w-32" ]
                    [ div [ class "mx-2 text-lg text-blue-200 font-display truncate" ] [ text "PHY 183 - Studio Physics" ]
                    , div [ class "mx-2 text-xs text-blue-100 font-display truncate" ] [ text (user.firstName ++ " " ++ user.lastName) ]
                    ]
                ]

        menuItem txt icon route =
            div [ classList [ ( "my-2 py-1 mx-1", True ), ( "bg-slate rounded", isActive page route ) ] ]
                [ a [ Route.href route, class "pl-4 text-blue-100 no-underline w-full" ]
                    [ i [ class ("w-4 fas fa-" ++ icon) ] []
                    , span [ class "font-display ml-4" ] [ text txt ]
                    ]
                ]
    in
    div [ class "flex flex-col" ]
        [ div [ class "my-2" ] [ userItem ]
        , div [ class "my-2" ]
            [ menuItem "Classrooms" "university" Route.Classrooms
            , menuItem "Users" "users" Route.Users
            , menuItem "Feedback" "pen" Route.Feedback
            , menuItem "Inbox" "inbox" Route.Drafts
            ]
        , div [ class "my-2" ]
            [ menuItem "Logout" "sign-out-alt" Route.Logout
            ]
        ]


viewFooter : Html msg
viewFooter =
    footer [ class "flex justify-center py-1" ]
        [ p [ class "text-center text-gray-600 mx-2" ] [ text "Version 0.4.0-dev" ]
        , p [ class "text-center text-gray-600 mx-2" ] [ text "|" ]
        , p [ class "text-center text-gray-600 mx-2" ] [ text "Built on 2019-6-27 at 1:52pm EDT" ]
        ]


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Classrooms, Route.Classrooms ) ->
            True

        ( Users, Route.Users ) ->
            True

        ( Feedback, Route.Feedback ) ->
            True

        ( Drafts, Route.Drafts ) ->
            True

        ( Profile, Route.Profile ) ->
            True

        ( EditFeedback, Route.EditFeedback _ _ _ ) ->
            True

        _ ->
            False


{-| Render dismissable errors. We use this all over the place!
-}
viewErrors : msg -> List String -> Html msg
viewErrors dismissErrors errors =
    if List.isEmpty errors then
        Html.text ""

    else
        div
            [ class "error-messages"
            , style "position" "fixed"
            , style "top" "0"
            , style "background" "rgb(250, 250, 250)"
            , style "padding" "20px"
            , style "border" "1px solid"
            ]
        <|
            List.map (\error -> p [] [ text error ]) errors
                ++ [ button [ onClick dismissErrors ] [ text "Ok" ] ]
