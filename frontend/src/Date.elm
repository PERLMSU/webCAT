module Date exposing (posixToDate)

import Time exposing (..)


posixToDate : Time.Zone -> Time.Posix -> String
posixToDate zone posix =
    let
        monthToStr m =
            case m of
                Jan ->
                    "January"

                Feb ->
                    "February"

                Mar ->
                    "March"

                Apr ->
                    "April"

                May ->
                    "May"

                Jun ->
                    "June"

                Jul ->
                    "July"

                Aug ->
                    "August"

                Sep ->
                    "September"

                Oct ->
                    "October"

                Nov ->
                    "November"

                Dec ->
                    "December"

        day =
            (Time.toDay zone >> String.fromInt) posix

        month =
            (Time.toMonth zone >> monthToStr ) posix

        year =
            (Time.toYear zone >> String.fromInt) posix
    in
    String.join " " [ day, month, year ]
