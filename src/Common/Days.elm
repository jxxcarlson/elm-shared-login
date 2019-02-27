module Common.Days
    exposing
        ( fromDate
        , fromUSDate
        , dateStringFromDate
        , usDateStringFromDate
        , fromIntList
        , from
        , dateFromString
        , dateFromUsString
        , day
        , month
        , year
        )

{-| This library provides the means to compute the number of
days between two given dates, e.g,

    ```
     daysFromDate "28/2/2017" "1/6/2017" == 95
     daysFromUSDate "2/28/2017" "6/1/2017" == 95
     ```


## Functions which compute day intervals from from one date string to another.

@docs daysFromDate, daysFromUSDate


## Function which computes day intervals from one Date to another

@docs daysFrom


## Construct Dates from strings

@docs dateFromString, dateFromUsString


## Return components of a Date

@docs day, month, year

Thus,

    ```
    day   (dateFromString "1/2/2018") == 1
    day (dateFromSUstring "1/2/2018") == 2
    ```

-}

import Dict exposing (Dict)


type Date
    = Date
        { year : Int
        , month : Int
        , day : Int
        }


usDateStringFromDate : Date -> String
usDateStringFromDate date =
    let
        d =
            String.fromInt <| day date

        m =
            String.fromInt <| month date

        y =
            String.fromInt <| year date
    in
        m ++ "/" ++ d ++ "/" ++ y


dateStringFromDate : Date -> String
dateStringFromDate date =
    let
        d =
            String.fromInt <| day date

        m =
            String.fromInt <| month date

        y =
            String.fromInt <| year date
    in
        d ++ "/" ++ m ++ "/" ++ y


fromIntList : List Int -> Date
fromIntList intList =
    let
        y =
            getIntegerFromList intList

        m =
            getIntegerFromList (List.drop 1 intList)

        d =
            getIntegerFromList (List.drop 2 intList)
    in
        Date { year = y, month = m, day = d }


{-| Compute the number of days from one date to another,
where dates are given as strings of the form d/m/y.
-}
fromDate : String -> String -> Int
fromDate startDate endDate =
    fromDateWithConverter dateFromString startDate endDate


{-| Compute the number of days from one date to another,
where dates are given as strings of the form m/d/y.
-}
fromUSDate : String -> String -> Int
fromUSDate startDate endDate =
    fromDateWithConverter dateFromUsString startDate endDate


fromDateWithConverter : (String -> Date) -> String -> String -> Int
fromDateWithConverter converter startDateString endDateString =
    from (converter startDateString) (converter endDateString)


{-| Compute the number of days from one date to another,
where dates are given as Date values.
-}
from : Date -> Date -> Int
from startDate endDate =
    (through endDate) - (through startDate)


through : Date -> Int
through date =
    let
        dty =
            daysThroughYear (year date)

        dtm =
            daysThroughMonth (year date) (month date)
    in
        dty + dtm + (day date)


epoch =
    Date { year = 1970, month = 1, day = 1 }


{-| Return the day value of a Date
-}
day : Date -> Int
day (Date date) =
    date.day


{-| Return the month value of a Date
-}
month : Date -> Int
month (Date date) =
    date.month


{-| Return the year value of a Date
-}
year : Date -> Int
year (Date date) =
    date.year


{-| Construct a Date from a string of the form "d/m/y"
-}
dateFromString : String -> Date
dateFromString dateString =
    let
        elements =
            String.split "/" dateString

        d =
            getIntegerFromStringList elements

        m =
            getIntegerFromStringList (List.drop 1 elements)

        y =
            getIntegerFromStringList (List.drop 2 elements)
    in
        Date { year = y, month = m, day = d }


{-| Construct a Date from a string of the form "m/d/y"
-}
dateFromUsString : String -> Date
dateFromUsString dateString =
    let
        elements =
            String.split "/" dateString

        m =
            getIntegerFromStringList elements

        d =
            getIntegerFromStringList (List.drop 1 elements)

        y =
            getIntegerFromStringList (List.drop 2 elements)
    in
        Date { year = y, month = m, day = d }


getIntegerFromStringList : List String -> Int
getIntegerFromStringList stringList =
    stringList
        |> List.head
        |> Maybe.withDefault "0"
        |> String.toInt
        |> Maybe.withDefault 0


getIntegerFromList : List Int -> Int
getIntegerFromList intList =
    intList
        |> List.head
        |> Maybe.withDefault 0


daysThroughYear : Int -> Int
daysThroughYear y =
    let
        leapDays =
            (y - (year epoch) + 2) // 4
    in
        365 * (y - (year epoch) + 1) + leapDays


daysThroughMonth : Int -> Int -> Int
daysThroughMonth year_ m =
    let
        correction =
            if modBy 4 year_ == 0 then
                1
            else
                0
    in
        m
            |> numbersThrough
            |> List.map daysInMonth
            |> List.sum
            |> (\x -> x + correction)


daysInMonthDict : Dict Int Int
daysInMonthDict =
    Dict.fromList
        [ ( 1, 31 )
        , ( 2, 28 )
        , ( 3, 31 )
        , ( 4, 30 )
        , ( 5, 31 )
        , ( 6, 30 )
        , ( 7, 31 )
        , ( 8, 31 )
        , ( 9, 30 )
        , ( 10, 31 )
        , ( 11, 30 )
        , ( 12, 31 )
        ]


daysInMonth : Int -> Int
daysInMonth m =
    Dict.get m daysInMonthDict
        |> Maybe.withDefault 0


numbersThroughAux : Int -> List Int
numbersThroughAux n =
    if n < 1 then
        []
    else if n == 1 then
        [ 1 ]
    else
        n :: numbersThroughAux (n - 1)


numbersThrough : Int -> List Int
numbersThrough n =
    case n < 0 of
        True ->
            []

        False ->
            List.reverse <| numbersThroughAux n
