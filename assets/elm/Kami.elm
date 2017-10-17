port module Kami exposing (..)

import Array exposing (Array)
import Dict
import Html exposing (..)
import Html.Attributes exposing (class, href, id, style)
import Json.Decode as JD
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)
import Json.Encode as JE
import Phoenix
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Push as Push
import Phoenix.Socket as Socket exposing (AbnormalClose, Socket)
import Time exposing (Time)


main : Program Never Model Msg
main =
    Html.program
        { init = ( init, Cmd.none )
        , view = view
        , subscriptions = subscriptions
        , update = update
        }


port loc : (String -> msg) -> Sub msg



-- MODEL


type alias Model =
    { connectionStatus : ConnectionStatus
    , currentTime : Time
    , urlParams : Dict.Dict String String
    }


type ConnectionStatus
    = Connected
    | Disconnected
    | ScheduledReconnect { time : Time }


init : Model
init =
    { connectionStatus = Disconnected
    , currentTime = 0
    , urlParams = Dict.empty
    }



-- ACTION, UPDATE


type Msg
    = SocketClosedAbnormally AbnormalClose
    | ConnectionStatusChanged ConnectionStatus
    | Tick Time
    | ParseUrlParams String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SocketClosedAbnormally abnormalClose ->
            { model
                | connectionStatus =
                    ScheduledReconnect { time = roundDownToSecond (model.currentTime + abnormalClose.reconnectWait) }
            }
                ! []

        ConnectionStatusChanged status ->
            { model | connectionStatus = status } ! []

        Tick time ->
            { model | currentTime = time } ! []

        ParseUrlParams params ->
            { model | urlParams = parseUrlParams params |> paramsToDict } ! []



-- UPDATE HELPERS


roundDownToSecond : Time -> Time
roundDownToSecond ms =
    (ms / 1000) |> truncate |> (*) 1000 |> toFloat



-- DECODERS
-- SUBSCRIPTIONS


lobbySocket : String
lobbySocket =
    "ws://gaius.ddns.net:8686/socket/websocket"


socket : Socket Msg
socket =
    Socket.init lobbySocket
        |> Socket.onOpen (ConnectionStatusChanged Connected)
        |> Socket.onClose (\_ -> ConnectionStatusChanged Disconnected)
        |> Socket.onAbnormalClose SocketClosedAbnormally
        |> Socket.reconnectTimer (\backoffIteration -> (backoffIteration + 1) * 5000 |> toFloat)


lobby : String -> Channel Msg
lobby userName =
    Channel.init "room:lobby"
        |> Channel.withPayload (JE.object [ ( "user_name", JE.string "foobie" ) ])
        |> Channel.withDebug


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ phoenixSubscription model, Time.every Time.second Tick, loc ParseUrlParams ]


phoenixSubscription model =
    Phoenix.connect socket [ lobby "foobie" ]



-- VIEW


view : Model -> Html Msg
view model =
    text "Hello from Elm"



-- URL PARAMS STUFF


type ParseResult
    = Error String
    | UrlParams (Dict.Dict String String)


paramsToDict : ParseResult -> Dict.Dict String String
paramsToDict result =
    case result of
        Error _ ->
            Dict.empty

        UrlParams dict ->
            dict


parseUrlParams : String -> ParseResult
parseUrlParams startsWithQuestionMarkThenParams =
    case String.uncons startsWithQuestionMarkThenParams of
        Nothing ->
            Error "No URL params"

        Just ( '?', rest ) ->
            parseParams rest

        Just ( _, rest ) ->
            Error "Didn't begin with a ?"


parseParams : String -> ParseResult
parseParams stringWithAmpersands =
    let
        eachParam =
            String.split "&" stringWithAmpersands

        eachPair =
            List.map (splitAtFirst '=') eachParam
    in
    UrlParams (Dict.fromList eachPair)


splitAtFirst : Char -> String -> ( String, String )
splitAtFirst c s =
    case firstOccurrence c s of
        Nothing ->
            ( s, "" )

        Just i ->
            ( String.left i s, String.dropLeft (i + 1) s )


firstOccurrence : Char -> String -> Maybe Int
firstOccurrence c s =
    case String.indexes (String.fromChar c) s of
        [] ->
            Nothing

        head :: _ ->
            Just head
