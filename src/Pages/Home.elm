module Pages.Home
    exposing
        ( Model
        , Msg(..)
        , init
        , update
        , view
        )

import SharedState exposing (SharedState, SharedStateUpdate(..))
import Time exposing (Posix)
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Common.Style as Style
import Common.Utility as Utility
import User.Types exposing (User)


type alias Model =
    { counter : Int }


type Msg
    = NoOp
    | IncrementCounter


init : ( Model, Cmd Msg )
init =
    ( { counter = 0
      }
    , Cmd.none
    )


{-| NOTE that the Home udpdate function is of the usual
kind -- there is no SharedState parameter. Contrast
this with the update function for SettiÂngs.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        IncrementCounter ->
            ( { model | counter = model.counter + 1 }, Cmd.none )


view : SharedState -> Model -> Element Msg
view sharedState model =
    column [ paddingXY 0 40, spacing 18 ]
        [ el [ Font.size 24, Font.bold ] (text "Home page")
        , el [ Font.size 16 ] (text <| "Counter = " ++ String.fromInt model.counter)
        , Input.button Style.button
            { onPress = Just (IncrementCounter)
            , label = el [] (text "Increment counter")
            }
        , userStatus sharedState.currentUser
        , el [ Font.size 16 ] (text <| "UTC: " ++ Utility.toUtcString (Just sharedState.currentTime))
        ]



--
-- HELPERS
--


userStatus : Maybe User -> Element msg
userStatus user_ =
    case user_ of
        Nothing ->
            el [] (text "Not signed in.")

        Just user ->
            el [] (text <| user.username ++ ", you are now signed in.")
