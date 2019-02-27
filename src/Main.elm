module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Browser.Navigation
import Html exposing (..)
import Routing.Router as Router
import SharedState exposing (SharedState, SharedStateUpdate(..), initialSharedState)
import Time exposing (Posix)
import Url exposing (Url)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , onUrlChange = UrlChange
        , onUrlRequest = LinkClicked
        , subscriptions = \_ -> Time.every 1000 TimeChange
        }


type alias Model =
    { appState : AppState
    , navKey : Browser.Navigation.Key
    , url : Url
    }


type alias Flags =
    { currentTime : Int }


type AppState
    = NotReady Posix
    | Ready SharedState Router.Model
    | FailedToInitialize


type Msg
    = UrlChange Url
    | LinkClicked UrlRequest
    | TimeChange Posix
    | RouterMsg Router.Msg


init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    ( { appState =
            Ready
                (initialSharedState navKey (Time.millisToPosix flags.currentTime))
                (Router.initialModel url)

      -- NotReady (Time.millisToPosix flags.currentTime)
      , url = url
      , navKey = navKey
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeChange time ->
            updateTime model time

        UrlChange url ->
            updateRouter { model | url = url } (Router.UrlChange url)

        RouterMsg routerMsg ->
            updateRouter model routerMsg

        LinkClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Browser.Navigation.pushUrl model.navKey (Url.toString url) )

                External url ->
                    ( model, Browser.Navigation.load url )


updateTime : Model -> Posix -> ( Model, Cmd Msg )
updateTime model time =
    case model.appState of
        NotReady _ ->
            ( { model | appState = NotReady time }
            , Cmd.none
            )

        Ready sharedState routerModel ->
            ( { model | appState = Ready (SharedState.update sharedState (UpdateTime time)) routerModel }
            , Cmd.none
            )

        FailedToInitialize ->
            ( model, Cmd.none )


updateRouter : Model -> Router.Msg -> ( Model, Cmd Msg )
updateRouter model routerMsg =
    case model.appState of
        Ready sharedState routerModel ->
            let
                nextSharedState =
                    SharedState.update sharedState sharedStateUpdate

                ( nextRouterModel, routerCmd, sharedStateUpdate ) =
                    Router.update sharedState routerMsg routerModel
            in
                ( { model | appState = Ready nextSharedState nextRouterModel }
                , Cmd.map RouterMsg routerCmd
                )

        _ ->
            let
                _ =
                    Debug.log "We got a router message even though the app is not ready?"
                        routerMsg
            in
                ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    case model.appState of
        Ready sharedState routerModel ->
            Router.view RouterMsg sharedState routerModel

        NotReady _ ->
            { title = "Loading (1)"
            , body = [ text "Loading (2)" ]
            }

        FailedToInitialize ->
            { title = "Failure"
            , body = [ text "The application failed to initialize. " ]
            }
