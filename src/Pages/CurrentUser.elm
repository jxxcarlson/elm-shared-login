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
import Http exposing (Error(..))
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
    , username : String
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
    , username = ""
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

        AcceptUsername str ->
            ( { model | username = str }, Cmd.none, NoUpdate )

        SignIn ->
            ( { model | message = "" }, Session.authenticate model.email model.password, NoUpdate )

        SignOut ->
            ( { model
                | message = ""
                , username = ""
                , email = ""
                , password = ""
                , state = NotSignedIn
              }
            , Cmd.none
            , InvalidateCurrentUser
            )

        Register ->
            ( { model | message = "", state = Registering }, Cmd.none, NoUpdate )

        CancelRegistration ->
            ( { model | message = "", state = NotSignedIn }, Cmd.none, NoUpdate )

        CancelSignin ->
            ( { model | message = "", state = NotSignedIn }, Cmd.none, NoUpdate )

        SubmitRegistration ->
            ( { model | message = "", state = Registering }, Session.registerUser model.username model.email model.password, NoUpdate )

        ProcessAuthentication (Ok user) ->
            ( { model
                | message = "Success! Welcome " ++ user.username ++ "."
                , username = ""
                , email = ""
                , password = ""
                , state = SignedIn
              }
            , Cmd.none
            , UpdateCurrentUser (Just user)
            )

        ProcessAuthentication (Err err) ->
            ( { model | message = "Invalid password or username", state = SigningIn }, Cmd.none, UpdateCurrentUser Nothing )

        AcceptRegistration (Ok user) ->
            ( { model
                | message = "Success! Welcome " ++ user.username ++ "."
                , username = ""
                , email = ""
                , password = ""
                , state = SignedIn
              }
            , Cmd.none
            , UpdateCurrentUser (Just user)
            )

        AcceptRegistration (Err err) ->
            ( { model | message = httpErrorExplanation err, state = SigningIn }, Cmd.none, UpdateCurrentUser Nothing )

        NavigateTo route ->
            ( model, pushUrl sharedState.navKey (reverseRoute route), NoUpdate )


view : SharedState -> Model -> Element Msg
view sharedState model =
    column Style.mainColumn
        [ column (Style.shadedColumn (px 480) (px 300))
            [ showIf (model.state /= SignedIn) (inputUsername model)
            , showIf (model.state /= SignedIn) (inputEmail model)
            , showIf (model.state /= SignedIn) (inputPassword model)
            , row [ spacing 12 ] [ signInOrCancelButton model, registerButton model ]
            , el [ Font.size 18 ] (text model.message)
            ]
        , footer sharedState model
        ]


footer : SharedState -> Model -> Element Msg
footer sharedState model =
    row Style.footer
        [ el Style.footerItem (text <| stateAsString model.state)
        , el Style.footerItem (text <| "UTC: " ++ Utility.toUtcString (Just sharedState.currentTime))
        ]


showIf : Bool -> Element Msg -> Element Msg
showIf flag element =
    if flag then
        element
    else
        Element.none


inputEmail model =
    Input.text [ width (px 300) ]
        { onChange = AcceptEmail
        , text = model.email
        , placeholder = Nothing
        , label = Input.labelLeft [ moveDown 12, Font.bold, width (px 120) ] (text "Email")
        }


inputUsername model =
    case model.state of
        Registering ->
            Input.text [ width (px 300) ]
                { onChange = AcceptUsername
                , text = model.username
                , placeholder = Nothing
                , label = Input.labelLeft [ moveDown 12, Font.bold, width (px 120) ] (text "Username")
                }

        _ ->
            Element.none


inputPassword model =
    Input.currentPassword [ width (px 300) ]
        { onChange = AcceptPassword
        , text = model.password
        , placeholder = Nothing
        , label = Input.labelLeft [ moveDown 12, Font.bold, width (px 120) ] (text "Password")
        , show = False
        }


signInOrCancelButton model =
    case model.state of
        NotSignedIn ->
            signInButton

        SigningIn ->
            signInButton

        Registering ->
            cancelRegistrationButton

        SignedIn ->
            signOutButton


signInButton =
    Input.button Style.button
        { onPress = Just SignIn
        , label = el [] (text "Sign In")
        }


signOutButton =
    Input.button Style.button
        { onPress = Just SignOut
        , label = el [] (text "Sign Out")
        }


cancelRegistrationButton =
    Input.button Style.button
        { onPress = Just CancelRegistration
        , label = el [] (text "Cancel")
        }


cancelSignInButton =
    Input.button Style.button
        { onPress = Just CancelSignin
        , label = el [] (text "Cancel")
        }


registerButton model =
    case model.state of
        NotSignedIn ->
            registerButton_

        SigningIn ->
            cancelSignInButton

        Registering ->
            submitRegistrationButton

        SignedIn ->
            Element.none


registerButton_ =
    Input.button Style.button
        { onPress = Just Register
        , label = el [] (text "Register")
        }


submitRegistrationButton =
    Input.button Style.button
        { onPress = Just SubmitRegistration
        , label = el [] (text "Submit registration")
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


type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Int
    | BadBody String


httpErrorExplanation : Http.Error -> String
httpErrorExplanation error =
    case error of
        Http.BadUrl str ->
            str

        Http.Timeout ->
            "Timeout (error)"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus status ->
            "Bad status: " ++ String.fromInt status

        Http.BadBody str ->
            cleanupErrorMessage str


cleanupErrorMessage : String -> String
cleanupErrorMessage str =
    str
        |> String.lines
        |> List.filter (\x -> String.contains "message" x)
        |> List.head
        |> Maybe.withDefault ""
        |> String.trim
        |> String.replace "message" ""
        |> String.replace "\"" ""
        |> String.dropLeft 1
