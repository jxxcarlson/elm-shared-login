module Common.Utility exposing (toUtcString, toUtcDateString)

import Time exposing (Posix, Month(..))


toUtcString : Maybe Posix -> String
toUtcString maybeTime =
    case maybeTime of
        Nothing ->
            "--:--:--"

        Just time ->
            (String.fromInt (Time.toHour Time.utc time) |> String.padLeft 2 '0')
                ++ ":"
                ++ (String.fromInt (Time.toMinute Time.utc time) |> String.padLeft 2 '0')
                ++ ":"
                ++ (String.fromInt (Time.toSecond Time.utc time) |> String.padLeft 2 '0')


toUtcDateString : Maybe Posix -> String
toUtcDateString maybeTime =
    case maybeTime of
        Nothing ->
            "--/--/--"

        Just time ->
            String.fromInt (monthToInt <| Time.toMonth Time.utc time)
                ++ "/"
                ++ String.fromInt (Time.toDay Time.utc time)
                ++ "/"
                ++ String.fromInt (Time.toYear Time.utc time)


monthToInt : Month -> Int
monthToInt month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12
