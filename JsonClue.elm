port module JsonClue exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes as Attr
import Html.Events exposing (..)
import Http
import Maybe exposing (..)
import Svg exposing (..)
import Svg.Attributes as SvgAttr exposing (..)
import Json.Decode as Json exposing (..)
import Task

main =
  App.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias PathRecord = {id : String, path : String}


type alias Model =  { file : String   , records : Maybe (List PathRecord)}

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
init f =
  ({ file = f, records = Nothing } , getIt2 f)


-- UPDATE

port d3Update : (List String) -> Cmd msg
port getTopoJson : Json.Value -> Cmd msg
-- port for listening for translated features from JavaScript
port features : (List PathRecord -> msg) -> Sub msg

type Msg
  = MorePlease
  | FetchSucceed2 Json.Value
  | IdPath (List PathRecord)
  | FetchFail Http.Error


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      (model, Cmd.none)

    FetchSucceed2 rec ->
        (model, getTopoJson rec)

    IdPath newFeatures ->
        ({file = model.file, records = Just newFeatures}, Cmd.none) --d3Update newFeatures)

    FetchFail _ ->
        (model, Cmd.none)



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  features IdPath

-- VIEW

svgpaths : List PathRecord -> List (Svg msg)
svgpaths paths =
    List.map svgpath paths

--pathRender : PathRecord -> Html
svgpath : PathRecord -> Svg msg
svgpath entry =
    Svg.path [SvgAttr.class "grid", Attr.id entry.id, SvgAttr.d entry.path][]



view : Model -> Html Msg
view model =
    let
        len = (Debug.log "rendering " model.file)
    in
       (
        case model.records of
            Nothing ->
            (div [Attr.class "container"]
                 [div [Attr.class "row"][
                       div [Attr.class "mapapp col"][
                            Svg.svg [  width "500", height "500"][
                                 Svg.g [][]
                                ]],
                           div [Attr.class "mapcontrol col"][
                                h2 []
                                    [Html.text model.file]
                               , button [ onClick MorePlease ] [ Html.text "More Please!" ]
                               ]]])
            Just records ->
            ( div [Attr.class "container"]
                  [div [Attr.class "row"][
                        div [Attr.class "mapapp col"][
                             Svg.svg [  width "500", height "500"][
                                  Svg.g [] (svgpaths records)
                                 ]],
                            div [Attr.class "mapcontrol col"][
                                 h2 []
                                     [Html.text model.file]
                                , button [ onClick MorePlease ] [ Html.text "More Please!" ]
                                ]]] )
       )



-- HTTP


getIt2 : String -> Cmd Msg
getIt2 f =
  let
    url = f
  in
    Task.perform FetchFail FetchSucceed2 (Http.get decodeResult2 url)


decodeResult2 : Json.Decoder Json.Value
decodeResult2 = Json.value

--decodeResult : List decodeIdPath

-- decodeIdPath : Json.Decoder PathRecord
-- decodeIdPath = Json.object2 PathRecord
--                (  ("id"   := Json.string)
--                       ("path" := Json.string))
