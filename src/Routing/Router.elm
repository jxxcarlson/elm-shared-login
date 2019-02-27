module Routing.Router exposing (Model, Msg(..), initialModel, init, pageView, update, updateHome, updateCurrentUser, view)

import Browser
import Browser.Navigation exposing (Key)
import Pages.Home as Home
import Pages.CurrentUser as CurrentUser
import Routing.Helpers exposing (Route(..), parseUrl, reverseRoute)
import SharedState exposing (SharedState, SharedStateUpdate(..))
import Url exposing (Url)
import Html exposing (Html)
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Element.Background as Background
import Common.Style as Style
import User.Types


type alias Model =
    { homeModel : Home.Model
    , currentUserModel : CurrentUser.Model
    , route : Route
    }


type Msg
    = UrlChange Url
    | HomeMsg Home.Msg
    | CurrentUserMsg User.Types.Msg
    | NavigateTo Route


initialModel : Url -> Model
initialModel url =
    let
        ( homeModel, homeCmd ) =
            Home.init

        currentUserModel =
            CurrentUser.initModel
    in
        { homeModel = homeModel
        , currentUserModel = currentUserModel
        , route = parseUrl url
        }


init : Url -> ( Model, Cmd Msg )
init url =
    let
        ( homeModel, homeCmd ) =
            Home.init

        currentUserModel =
            CurrentUser.initModel
    in
        ( { homeModel = homeModel
          , currentUserModel = currentUserModel
          , route = parseUrl url
          }
        , Cmd.map HomeMsg homeCmd
        )


update : SharedState -> Msg -> Model -> ( Model, Cmd Msg, SharedStateUpdate )
update sharedState msg model =
    case msg of
        UrlChange location ->
            ( { model | route = parseUrl location }
            , Cmd.none
            , NoUpdate
            )

        NavigateTo route ->
            ( model
            , Browser.Navigation.pushUrl sharedState.navKey (reverseRoute route)
            , NoUpdate
            )

        HomeMsg homeMsg ->
            updateHome model homeMsg

        CurrentUserMsg currentUserMsg ->
            updateCurrentUser sharedState model currentUserMsg


updateHome : Model -> Home.Msg -> ( Model, Cmd Msg, SharedStateUpdate )
updateHome model homeMsg =
    let
        ( nextHomeModel, homeCmd ) =
            Home.update homeMsg model.homeModel
    in
        ( { model | homeModel = nextHomeModel }
        , Cmd.map HomeMsg homeCmd
        , NoUpdate
        )


updateCurrentUser : SharedState -> Model -> User.Types.Msg -> ( Model, Cmd Msg, SharedStateUpdate )
updateCurrentUser sharedState model settingsMsg =
    let
        ( nextSettingsModel, settingsCmd, sharedStateUpdate ) =
            CurrentUser.update sharedState settingsMsg model.currentUserModel
    in
        ( { model | currentUserModel = nextSettingsModel }
        , Cmd.map CurrentUserMsg settingsCmd
        , sharedStateUpdate
        )


view : (Msg -> msg) -> SharedState -> Model -> { body : List (Html.Html msg), title : String }
view msgMapper sharedState model =
    let
        title =
            case model.route of
                HomeRoute ->
                    "Home"

                SettingsRoute ->
                    "CurrentUser"

                NotFoundRoute ->
                    "404"

        body_ =
            column [ padding 40 ]
                [ el [ paddingXY 0 20, Font.bold ]
                    (text "Login Demo with Shared State")
                , row
                    (Style.navBar (px 480))
                    [ Input.button (Style.activeButton (model.route == HomeRoute))
                        { onPress = Just (NavigateTo HomeRoute)
                        , label = el [] (text "Home")
                        }
                    , Input.button (Style.activeButton (model.route == SettingsRoute))
                        { onPress = Just (NavigateTo SettingsRoute)
                        , label = el [] (text "Sign in page")
                        }
                    ]
                , pageView sharedState model
                ]
    in
        { title = "Elm Shared State Demo"
        , body = body_ |> Element.layout [] |> Html.map msgMapper |> \x -> [ x ]
        }


pageView : SharedState -> Model -> Element Msg
pageView sharedState model =
    row []
        [ case model.route of
            HomeRoute ->
                Home.view sharedState model.homeModel
                    |> Element.map HomeMsg

            SettingsRoute ->
                CurrentUser.view sharedState model.currentUserModel
                    |> Element.map CurrentUserMsg

            NotFoundRoute ->
                el [] (text "404 :(")
        ]
