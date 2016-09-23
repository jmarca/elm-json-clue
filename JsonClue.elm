port module JsonClue exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
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


init: String -> (Model, Cmd Msg)
init file =
  (Model file ["waiting.gif", "syntax mystery"], Cmd.none)


-- UPDATE

type Msg
  = MorePlease
  | FetchSucceed String
  | FetchFail Http.Error


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      (model, getIt)

    FetchSucceed status ->
      (Model status model.records, Cmd.none)

    FetchFail _ ->
      (model, Cmd.none)



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW



view : Model -> Html Msg
view model =
  div []
    [ h2 [] [Html.text model.status]
    , p[][ Html.text  model.status ]
    , button [ onClick MorePlease ] [ Html.text "More Please!" ]
    ]



-- HTTP

getIt : Cmd Msg
getIt =
  let
    url =
      "data/test.json"
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeResult url)


-- decodeListPart : Json.Decode.list List
-- decodeListPart =
--   Json.Decode.list Json.Decode.string


decodeResult : Json.Decoder String
decodeResult =
  Json.at ["status"] Json.string
