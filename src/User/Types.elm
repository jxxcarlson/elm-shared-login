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
    = ProcessAuthentication (Result Http.Error User)
    | AcceptRegistration (Result Http.Error User)
    | NavigateTo Route
    | AcceptUsername String
    | AcceptEmail String
    | AcceptPassword String
    | SignIn
    | SignOut
    | Register
    | CancelRegistration
    | CancelSignin
    | SubmitRegistration
