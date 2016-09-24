port module JsonClue exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing (..)
import Task

main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL



type alias Model =
  { status : String
  , records : List String
  }

type alias Properties =
    { gid : Int
    ,id : String}

type alias Coordinate =
    (Float, Float)

type alias PolyLine =
     List Coordinate

type alias PolyCoordinates =
     List ( List  PolyLine  )


type alias Geometry =
    { type' : String
      ,coordinates : PolyCoordinates }

type alias Feature =
    {type' : String
    ,properties : Properties
    ,geometry : Geometry }

-- {"type":"Feature",
--    "properties":{
--            "gid":25083,
--            "id":"120_278"},
--    "geometry":{
--            "type":"Polygon",
--            "coordinates":[[[-123.08153279727972,42.0060393009301],[-123.10209111311131,42.0060393009301],[-123.10209111311131,42.007934650465046],[-123.08153279727972,42.0060393009301]]]}
--   }


init: String -> (Model, Cmd Msg)
init file =
  (Model file ["waiting.gif", "syntax mystery"], Cmd.none)


-- UPDATE

port d3Update : (List String) -> Cmd msg
port getTopoJson : Json.Value -> Cmd msg
-- port for listening for translated features from JavaScript
port features : (List String -> msg) -> Sub msg

type Msg
  = MorePlease
  | FetchSucceed JsonRecord
  | FetchSucceed2 Json.Value
  | Suggest (List String)
  | FetchFail Http.Error


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      (model, (getIt2 model.status))

    FetchSucceed rec ->
        let
            incoming = case rec.records of
                           one :: rest ->
                               one
                           _ ->
                               ["empty"]
        in
            (Model rec.status incoming, Cmd.none)

    FetchSucceed2 rec ->
        (model, getTopoJson rec)

    Suggest newFeatures ->
        (model, d3Update newFeatures)

    FetchFail _ ->
        (model, Cmd.none)



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  features Suggest

-- VIEW



view : Model -> Html Msg
view model =
  div []
    [ h2 [] [Html.text model.status]
    , p[][ Html.text  model.status ]
    , p[][ Html.text (List.foldr (++) ""(List.intersperse ", " model.records)) ]
    , button [ onClick MorePlease ] [ Html.text "More Please!" ]
    ]



-- HTTP

getIt :  Cmd Msg
getIt =
  let
    url =
      "data/test.json"
  in
    Task.perform FetchFail FetchSucceed2 (Http.get decodeResult2 url)

getIt2 : String -> Cmd Msg
getIt2 f =
  let
    url = f
  in
    Task.perform FetchFail FetchSucceed2 (Http.get decodeResult2 url)


decodeResult2 : Json.Decoder Json.Value
decodeResult2 = Json.value

type alias JsonRecord = {status: String, records: List (List String)}

decodeResult : Json.Decoder JsonRecord
decodeResult = Json.object2 JsonRecord
               ("status" := Json.string)
               ("records" := Json.list (Json.list Json.string))
