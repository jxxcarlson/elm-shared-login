module SharedState exposing (SharedState, SharedStateUpdate(..), initialSharedState, update)

import Browser.Navigation
import Time exposing (Posix)
import User.Types exposing (User)


type alias SharedState =
    { navKey : Browser.Navigation.Key
    , currentTime : Posix
    , currentUser : Maybe User
    }


type SharedStateUpdate
    = NoUpdate
    | UpdateTime Posix
    | UpdateCurrentUser (Maybe User)
    | InvalidateCurrentUser


initialSharedState : Browser.Navigation.Key -> Posix -> SharedState
initialSharedState navKey time =
    { navKey = navKey
    , currentTime = time
    , currentUser = Nothing
    }


update : SharedState -> SharedStateUpdate -> SharedState
update sharedState sharedStateUpdate =
    case sharedStateUpdate of
        UpdateTime time ->
            { sharedState | currentTime = time }

        UpdateCurrentUser currentUser ->
            { sharedState | currentUser = currentUser }

        InvalidateCurrentUser ->
            { sharedState | currentUser = Nothing }

        NoUpdate ->
            sharedState
