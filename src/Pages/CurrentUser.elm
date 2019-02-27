module Pages.CurrentUser
    exposing
        ( Model
        , currentSharedStateView
        , initModel
        , update
        , view
        )

import Browser.Navigation exposing (pushUrl)
import Routing.Helpers exposing (Route(..), reverseRoute)
import SharedState exposing (SharedState, SharedStateUpdate(..))
import Time
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import User.Authentication as Authentication
import User.Types exposing (User, Msg(..))


type alias Model =
    { favorite : String
    , currentUser : Maybe User
    , errorMessage : String
    }


initModel : Model
initModel =
    { favorite = "??"
    , currentUser = Nothing
    , errorMessage = ""
    }


{-| NOTE that the Settings updpate function takes a SharedState parameter.
In addition, its return value is a triple, with the last element
of type SharedStateUpdate.
-}
update : SharedState -> Msg -> Model -> ( Model, Cmd Msg, SharedStateUpdate )
update sharedState msg model =
    case msg of
        SetFavorite str ->
            ( { model | favorite = str }
            , Cmd.none
            , NoUpdate
            )

        SetSecret str ->
            ( model, Cmd.none, UpdateSharedSecret str )

        ProcessAuthentication (Ok user) ->
            ( { model | currentUser = Just user, errorMessage = "" }, Cmd.none, NoUpdate )

        ProcessAuthentication (Err err) ->
            ( { model | errorMessage = "Invalid password or username" }, Cmd.none, NoUpdate )

        NavigateTo route ->
            ( model, pushUrl sharedState.navKey (reverseRoute route), NoUpdate )


view : SharedState -> Model -> Element Msg
view sharedState model =
    column [ paddingXY 0 40, spacing 24 ]
        [ el [ Font.size 24, Font.bold ] (text "Settings")
        , inputFavorite model
        , inputSecret sharedState
        , currentSharedStateView sharedState
        ]


inputFavorite model =
    Input.text []
        { onChange = SetFavorite
        , text = model.favorite
        , placeholder = Nothing
        , label = Input.labelLeft [ moveDown 12, Font.bold ] (text "Favorite fruit: ")
        }


inputSecret sharedState =
    Input.text []
        { onChange = SetSecret
        , text = sharedState.secret
        , placeholder = Nothing
        , label = Input.labelLeft [ moveDown 12, Font.bold ] (text "Secret: ")
        }


currentSharedStateView : SharedState -> Element never
currentSharedStateView sharedState =
    column []
        [ el [] (text <| "Unix time: " ++ (String.fromInt (Time.posixToMillis sharedState.currentTime)))
        ]
