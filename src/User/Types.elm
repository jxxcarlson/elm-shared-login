module User.Types exposing (User, Msg(..))

import Routing.Helpers exposing (Route)
import Http


type alias User =
    { username : String
    , id : Int
    , firstname : String
    , email : String
    , token : String
    , blurb : String
    , public : Bool
    , follow : List String
    , followers : List String
    , admin : Bool
    , beginningDate : String
    }


type Msg
    = SetFavorite String
    | ProcessAuthentication (Result Http.Error User)
    | SetSecret String
    | NavigateTo Route
