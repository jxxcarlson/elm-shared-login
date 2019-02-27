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
import User.Session as Session
import User.Types exposing (User, Msg(..))
import Common.Style as Style
import Common.Utility as Utility


type alias Model =
    { message : String
    , email : String
    , password : String
    , state : State
    }


type State
    = NotSignedIn
    | SigningIn
    | Registering
    | SignedIn


initModel : Model
initModel =
    { message = ""
    , email = ""
    , password = ""
    , state = NotSignedIn
    }


{-| NOTE that the Settings updpate function takes a SharedState parameter.
In addition, its return value is a triple, with the last element
of type SharedStateUpdate.
-}
update : SharedState -> Msg -> Model -> ( Model, Cmd Msg, SharedStateUpdate )
update sharedState msg model =
    case msg of
        AcceptEmail str ->
            ( { model | email = str }, Cmd.none, NoUpdate )

        AcceptPassword str ->
            ( { model | password = str }, Cmd.none, NoUpdate )

        SignIn ->
            ( { model | message = "" }, Session.authenticate model.email model.password, NoUpdate )

        ProcessAuthentication (Ok user) ->
            ( { model | message = "Login successful", state = SignedIn }, Cmd.none, UpdateCurrentUser (Just user) )

        ProcessAuthentication (Err err) ->
            ( { model | message = "Invalid password or username", state = SigningIn }, Cmd.none, UpdateCurrentUser Nothing )

        NavigateTo route ->
            ( model, pushUrl sharedState.navKey (reverseRoute route), NoUpdate )


view : SharedState -> Model -> Element Msg
view sharedState model =
    column Style.mainColumn
        [ el [ Font.size 24, Font.bold ] (text "Sign in")
        , inputEmail model
        , inputPassword model
        , signInButton
        , el [ Font.size 18 ] (text model.message)
        , footer sharedState model
        ]


footer : SharedState -> Model -> Element Msg
footer sharedState model =
    row Style.footer
        [ el Style.footerItem (text <| stateAsString model.state)
        , el Style.footerItem (text <| "UTC: " ++ Utility.toUtcString (Just sharedState.currentTime))
        ]


inputEmail model =
    Input.text [ width (px 300) ]
        { onChange = AcceptEmail
        , text = model.email
        , placeholder = Nothing
        , label = Input.labelLeft [ moveDown 12, Font.bold, width (px 120) ] (text "Email")
        }


inputPassword model =
    Input.currentPassword [ width (px 300) ]
        { onChange = AcceptPassword
        , text = model.password
        , placeholder = Nothing
        , label = Input.labelLeft [ moveDown 12, Font.bold, width (px 120) ] (text "Password")
        , show = False
        }


signInButton =
    Input.button Style.button
        { onPress = Just SignIn
        , label = el [] (text "Sign In")
        }


currentSharedStateView : SharedState -> Element never
currentSharedStateView sharedState =
    column [ paddingXY 0 20, spacing 24 ]
        [ el [ Font.size 16 ] (text <| "UTC: " ++ Utility.toUtcString (Just sharedState.currentTime))
        ]



--
-- HELPERS
--


stateAsString : State -> String
stateAsString state =
    case state of
        NotSignedIn ->
            "Not signed in"

        SignedIn ->
            "Signed in"

        SigningIn ->
            "Signing in"

        Registering ->
            "Registering"


userStatus : Maybe User -> Element msg
userStatus user_ =
    case user_ of
        Nothing ->
            el [] (text "Not signed in.")

        Just user ->
            el [] (text <| user.username ++ ", you are now signed in.")
