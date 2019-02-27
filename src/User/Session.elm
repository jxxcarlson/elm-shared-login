module User.Session exposing (authenticate)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (required, hardcoded)
import Configuration
import Common.Days as Days
import User.Types exposing (User, Msg(..))


authenticate : String -> String -> Cmd Msg
authenticate email password =
    Http.post
        { url = Configuration.backend ++ "/api/users/authenticate"
        , body = Http.jsonBody (authorizationEncoder email password)
        , expect = Http.expectJson ProcessAuthentication userDecoder
        }



--
-- ENCODERS AND DECODERS
--


authorizationEncoder : String -> String -> Encode.Value
authorizationEncoder email password =
    Encode.object
        [ ( "email", Encode.string email )
        , ( "password", Encode.string password )
        ]


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "username" Decode.string
        |> required "id" Decode.int
        |> required "firstname" Decode.string
        |> required "email" Decode.string
        |> required "token" Decode.string
        |> required "blurb" Decode.string
        |> required "public" Decode.bool
        |> required "follow" (Decode.list Decode.string)
        |> required "followers" (Decode.list Decode.string)
        |> required "admin" Decode.bool
        |> required "inserted_at" (Decode.map usDateStringFromElixirDateString Decode.string)



--
-- HELPERS
--


intListFromElixirDateString : String -> List Int
intListFromElixirDateString str =
    let
        maybeElixirDate =
            String.split "T" str |> List.head
    in
        case maybeElixirDate of
            Nothing ->
                []

            Just str_ ->
                String.split "-" str_
                    |> List.map String.toInt
                    |> List.map (Maybe.withDefault 0)


usDateStringFromElixirDateString : String -> String
usDateStringFromElixirDateString dateString =
    dateString
        |> intListFromElixirDateString
        |> Days.fromIntList
        |> Days.usDateStringFromDate
