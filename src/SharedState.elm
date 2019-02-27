module SharedState exposing (SharedState, SharedStateUpdate(..), initialSharedState, update)

import Browser.Navigation
import Time exposing (Posix)


type alias SharedState =
    { navKey : Browser.Navigation.Key
    , currentTime : Posix
    , secret : String
    }


type SharedStateUpdate
    = NoUpdate
    | UpdateTime Posix
    | UpdateSharedSecret String


initialSharedState : Browser.Navigation.Key -> Posix -> SharedState
initialSharedState navKey time =
    { navKey = navKey
    , currentTime = time
    , secret = "xxx"
    }


update : SharedState -> SharedStateUpdate -> SharedState
update sharedState sharedStateUpdate =
    case sharedStateUpdate of
        UpdateTime time ->
            { sharedState | currentTime = time }

        UpdateSharedSecret str ->
            { sharedState | secret = str }

        NoUpdate ->
            sharedState
