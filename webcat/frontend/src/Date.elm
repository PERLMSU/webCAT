module Date exposing (posixToClockTime, posixToDate)

import Time exposing (..)

posixToClockTime : Time.Zone -> Time.Posix -> String
posixToClockTime zone posix =
    let
        fixMidnight i =
            if i == 0 then
                12

            else
                i

        hour =
            (Time.toHour zone >> modBy 12 >> fixMidnight >> String.fromInt) posix

        partOfDay =
            if Time.toHour zone posix >= 12 then
                "pm"

            else
                "am"

        minute =
            if Time.toMinute zone posix < 10 then
                "0" ++ (Time.toMinute zone >> String.fromInt) posix
            else
                (Time.toMinute zone >> String.fromInt) posix
    in
    hour ++ ":" ++ minute ++ partOfDay


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

        dayEnd =
            if day == "1" || day == "21" || day == "31" then
                "st"

            else if day == "2" || day == "22" then
                "nd"

            else if day == "3" || day == "23" then
                "rd"

            else
                "th"

        month =
            (Time.toMonth zone >> monthToStr) posix

        year =
            (Time.toYear zone >> String.fromInt) posix
    in
    String.join " " [ month, day ++ dayEnd, year ]
