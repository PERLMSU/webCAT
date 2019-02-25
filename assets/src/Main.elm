module Main exposing (main)

import Browser
import Html exposing (..)


type alias Model =
    { message : String }


type Msg
    = Message String


model : Model
model =
    Model ""


update : Msg -> Model -> Model
update msg m =
    case msg of
        Message newMessage ->
            { m | message = newMessage }


view : Model -> Html Msg
view m =
    div [] [ text "Hello World" ]


main =
    Browser.sandbox
        { init = model
        , view = view
        , update = update
        }
