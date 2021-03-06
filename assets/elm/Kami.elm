port module Kami exposing (..)

import Array exposing (Array)
import Bitwise exposing (shiftLeftBy)
import Char exposing (toCode)
import Dialog
import Dict
import Html exposing (..)
import Html.Attributes exposing (class, href, id, property, selected, src, style, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as JD
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)
import Json.Encode as JE
import Phoenix
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Push as Push
import Phoenix.Socket as Socket exposing (AbnormalClose, Socket)
import String exposing (foldl)
import Time exposing (Time)


main : Program InitFlags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }



-- MODEL


type alias Model =
    { uid : String
    , loc : String
    , key : String
    , connectionStatus : ConnectionStatus
    , currentTime : Time
    , posts : List Post
    , characters : List Character
    , dice : List DieMeta
    , presence : List PresenceMeta
    , post : Post
    , selectedCharacter : Int
    , admin : Bool
    , phone : Bool
    , cRemaining : Int
    , cMax : Int
    , showDialog : Bool
    , showPresence : Bool
    , resetDice : Bool
    , dialogSelectedSkill : String
    , dialogSelectedRing : String
    , dialogSelectedSkillValue : Int
    , dialogSelectedRingValue : Int
    , socketUrl : String
    , active : Bool
    }


getCharacter : List Character -> Int -> Character
getCharacter list index =
    case list |> Array.fromList |> Array.get index of
        Just character ->
            character

        Nothing ->
            Character "[Narrative]" "" True 0 0 "" "" 0 "" 0 "" 0 "" 0 "" 0 "" 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0


type alias Character =
    { name : String
    , family : String
    , approved : Bool
    , user : Int
    , xp : Float
    , image : String
    , id1 : String
    , id1_pct : Int
    , id2 : String
    , id2_pct : Int
    , id3 : String
    , id3_pct : Int
    , id4 : String
    , id4_pct : Int
    , id5 : String
    , id5_pct : Int
    , id6 : String
    , id6_pct : Int
    , favourite : Int
    , guru : Int
    , mentor : Int
    , responsibility : Int
    , protege : Int
    , fitness : Int
    , dodge : Int
    , status : Int
    , pursuit : Int
    , knowledge : Int
    , lie : Int
    , notice : Int
    , secrecy : Int
    , connect : Int
    , struggle : Int
    }


type alias Post =
    { author_slug : String
    , ooc : Bool
    , narrative : Bool
    , name : String
    , text : String
    , rolled : String
    , target : Int
    , result : Int
    , image : String
    , identities : String
    , date : String
    , time : String
    }


type alias DieMeta =
    { die_id : String
    , enum : Int
    }


type alias PresenceMeta =
    { timestamp : String
    , real_ts : Int
    , name : String
    , location : String
    }


type alias InitFlags =
    { uid : String
    , loc : String
    , key : String
    , width : Int
    , socketUrl : String
    }


type ConnectionStatus
    = Connected
    | Disconnected
    | ScheduledReconnect { time : Time }


init : InitFlags -> ( Model, Cmd Msg )
init flags =
    ( { uid = flags.uid
      , loc = flags.loc
      , key = flags.key
      , connectionStatus = Disconnected
      , currentTime = 0
      , posts = []
      , characters = []
      , dice = []
      , presence = []
      , post = Post "" False False "" "" "" 0 0 "" "" "" ""
      , selectedCharacter = 0
      , admin = False
      , phone = flags.width < 600
      , cRemaining = 750
      , cMax = 750
      , showDialog = False
      , showPresence = False
      , resetDice = True
      , dialogSelectedRing = ""
      , dialogSelectedSkill = ""
      , dialogSelectedRingValue = -1
      , dialogSelectedSkillValue = -1
      , socketUrl = flags.socketUrl
      , active = True
      }
    , Cmd.none
    )



-- ACTION, UPDATE


type Msg
    = SocketClosedAbnormally AbnormalClose
    | ConnectionStatusChanged ConnectionStatus
    | Tick Time
    | InitChannel JD.Value
    | UpdatePosts JD.Value
    | UpdateCharacters JD.Value
    | UpdateDice JD.Value
    | PushPost Bool
    | ChangeSelectedCharacter String
    | ChangeSelectedSkill String
    | ChangeImage String
    | ChangeText String
    | ModifyStat String Int
    | SpendXP String
    | ModifyStatFailed JD.Value
    | OpenDialog
    | OpenPresence
    | UpdatePresence JD.Value
    | AckDialog
    | DialogChangeSelectedSkill String
    | DialogChangeSelectedRing String
    | Activity Bool
    | DiceClick Int Post


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

        OpenDialog ->
            { model | showDialog = True } ! []

        OpenPresence ->
            let
                push =
                    Push.init ("room:" ++ model.loc) "presence"
                        |> Push.onOk (\response -> UpdatePresence response)
            in
            model ! [ Phoenix.push model.socketUrl push ]

        UpdatePresence payload ->
            case JD.decodeValue presenceDecoder payload of
                Ok payloadContainer ->
                    { model | showPresence = True, presence = payloadContainer.presence } ! []

                Err err ->
                    let
                        _ =
                            Debug.log "updatePresence payload error " ( err, payload )
                    in
                    model ! []

        AckDialog ->
            { model | showPresence = False, showDialog = False, dialogSelectedRing = "", dialogSelectedSkill = "", dialogSelectedRingValue = -1, dialogSelectedSkillValue = -1 } ! []

        InitChannel payload ->
            case JD.decodeValue initDecoder payload of
                Ok payloadContainer ->
                    let
                        admin =
                            payloadContainer.admin

                        characters =
                            payloadContainer.characters

                        selectedCharacter =
                            if admin then
                                -1
                            else
                                0

                        character =
                            getCharacter characters selectedCharacter

                        slug =
                            character.name |> String.toLower

                        name =
                            character.name ++ " " ++ character.family

                        posts =
                            payloadContainer.posts

                        dice =
                            payloadContainer.dice

                        initPost =
                            case admin of
                                True ->
                                    Post "" False True "-=[Narrative]=-" "" "" 0 0 "" "" "" ""

                                False ->
                                    Post slug False False name "" "" 0 0 character.image "" "" ""
                    in
                    { model | post = initPost, dice = dice, admin = admin, selectedCharacter = selectedCharacter, posts = payloadContainer.posts, characters = payloadContainer.characters } ! []

                Err err ->
                    let
                        _ =
                            Debug.log "initChannel payload error " ( err, payload )
                    in
                    model ! []

        UpdatePosts payload ->
            case JD.decodeValue postContainerDecoder payload of
                Ok payloadContainer ->
                    let
                        commands =
                            if model.active then
                                []
                            else
                                [ title "[*] Gan no Koe", donk () ]
                    in
                    { model | posts = payloadContainer.posts } ! commands

                Err err ->
                    let
                        _ =
                            Debug.log "updatePosts payload error " ( err, payload )
                    in
                    model ! []

        UpdateCharacters payload ->
            case JD.decodeValue charactersContainerDecoder payload of
                Ok payloadContainer ->
                    { model | characters = payloadContainer.characters |> List.sortBy .name } ! []

                Err err ->
                    let
                        _ =
                            Debug.log "updateCharacters payload error " ( err, payload )
                    in
                    model ! []

        UpdateDice payload ->
            case JD.decodeValue diceContainerDecoder payload of
                Ok payloadContainer ->
                    { model | dice = payloadContainer.dice } ! []

                Err err ->
                    let
                        _ =
                            Debug.log "updateDice payload error " ( err, payload )
                    in
                    model ! []

        ChangeSelectedCharacter s ->
            let
                selectedCharacter =
                    case String.toInt s of
                        Ok i ->
                            i

                        Err _ ->
                            0

                selected =
                    getCharacter model.characters selectedCharacter

                author_slug =
                    selected.name |> String.toLower

                full_name =
                    selected.family ++ " " ++ selected.name

                narrative =
                    s == "-1"

                oldPost =
                    model.post

                newPost =
                    { oldPost | name = full_name, author_slug = author_slug, narrative = narrative, image = selected.image }
            in
            { model | post = newPost, selectedCharacter = selectedCharacter } ! []

        DialogChangeSelectedSkill skill ->
            let
                split =
                    String.split ":" skill

                name =
                    case List.head split of
                        Just n ->
                            n

                        Nothing ->
                            ""

                value =
                    case List.tail split of
                        Just [ n ] ->
                            String.toInt n |> Result.withDefault 0

                        _ ->
                            0
            in
            { model | dialogSelectedSkill = name, dialogSelectedSkillValue = value } ! []

        DialogChangeSelectedRing ring ->
            let
                split =
                    String.split ":" ring

                name =
                    case List.head split of
                        Just n ->
                            n

                        Nothing ->
                            ""

                value =
                    case List.tail split of
                        Just [ n ] ->
                            String.toInt n |> Result.withDefault 0

                        _ ->
                            0
            in
            { model | dialogSelectedRing = name, dialogSelectedRingValue = value } ! []

        ChangeSelectedSkill skill ->
            let
                oldPost =
                    model.post

                newPost =
                    { oldPost | rolled = skill }
            in
            { model | post = newPost, resetDice = False } ! []

        ChangeImage filename ->
            let
                oldPost =
                    model.post

                newPost =
                    { oldPost | image = filename }
            in
            { model | post = newPost } ! []

        ChangeText text ->
            let
                oldPost =
                    model.post

                newPost =
                    { oldPost | text = text }

                newRemaining =
                    model.cMax - String.length text
            in
            { model | cRemaining = newRemaining, post = newPost } ! []

        ModifyStat stat_key delta ->
            let
                selected =
                    getCharacter model.characters model.selectedCharacter

                push =
                    Push.init ("room:" ++ model.loc) "modify"
                        |> Push.withPayload
                            (JE.object
                                [ ( "stat_key", JE.string stat_key )
                                , ( "delta", JE.int delta )
                                , ( "character", JE.string selected.name )
                                ]
                            )
                        |> Push.onError ModifyStatFailed
                        |> Push.onOk (\response -> UpdateCharacters response)
            in
            model ! [ Phoenix.push model.socketUrl push ]

        SpendXP stat_key ->
            let
                selected =
                    getCharacter model.characters model.selectedCharacter

                push =
                    Push.init ("room:" ++ model.loc) "spend_xp"
                        |> Push.withPayload
                            (JE.object
                                [ ( "stat_key", JE.string stat_key )
                                , ( "character", JE.string selected.name )
                                ]
                            )
                        |> Push.onError ModifyStatFailed
                        |> Push.onOk (\response -> UpdateCharacters response)
            in
            { model | showDialog = False, dialogSelectedRing = "", dialogSelectedSkill = "", dialogSelectedRingValue = -1, dialogSelectedSkillValue = -1 } ! [ Phoenix.push model.socketUrl push ]

        ModifyStatFailed value ->
            let
                _ =
                    Debug.log "modify stat returned an error code" value
            in
            model ! []

        Activity status ->
            let
                push =
                    Push.init ("room:" ++ model.loc) "still_alive"

                commands =
                    if status == True then
                        [ title "Gan no Koe", Phoenix.push model.socketUrl push ]
                    else
                        []
            in
            { model | active = status } ! commands

        DiceClick idx post ->
            let
                dbj2 =
                    foldl updateDbjHash 5381 post.text

                selected =
                    getCharacter model.characters model.selectedCharacter

                push =
                    Push.init ("room:" ++ model.loc) "die_toggle"
                        |> Push.withPayload
                            (JE.object
                                [ ( "idx", JE.int idx )
                                , ( "author", JE.string post.author_slug )
                                , ( "time", JE.string post.time )
                                , ( "hash", JE.int dbj2 )
                                ]
                            )
            in
            model ! [ Phoenix.push model.socketUrl push ]

        PushPost ooc ->
            let
                push =
                    Push.init ("room:" ++ model.loc) "post"
                        |> Push.withPayload
                            (JE.object
                                [ ( "author_slug", JE.string model.post.author_slug )
                                , ( "ooc", JE.bool ooc )
                                , ( "narrative", JE.bool model.post.narrative )
                                , ( "name", JE.string model.post.name )
                                , ( "text", JE.string model.post.text )
                                , ( "roll", JE.string model.post.rolled )
                                , ( "image", JE.string model.post.image )
                                ]
                            )
                        |> Push.onOk (\response -> UpdateCharacters response)

                oldPost =
                    model.post

                newPost =
                    { oldPost | text = "", rolled = "" }
            in
            { model | post = newPost, cRemaining = model.cMax, resetDice = True } ! [ Phoenix.push model.socketUrl push ]



-- UPDATE HELPERS


roundDownToSecond : Time -> Time
roundDownToSecond ms =
    (ms / 1000) |> truncate |> (*) 1000 |> toFloat


updateDbjHash : Char -> Int -> Int
updateDbjHash c h =
    shiftLeftBy h 5 + h + toCode c



-- DECODERS


type alias InitPayloadContainer =
    { posts : List Post
    , characters : List Character
    , admin : Bool
    , dice : List DieMeta
    }


initDecoder : JD.Decoder InitPayloadContainer
initDecoder =
    JD.map4 (\posts characters admin dice -> InitPayloadContainer posts characters admin dice)
        (JD.field "posts" postListDecoder)
        (JD.field "characters" characterListDecoder)
        (JD.field "admin" JD.bool)
        (JD.field "dice" diceListDecoder)


type alias PostPayloadContainer =
    { posts : List Post }


postContainerDecoder : JD.Decoder PostPayloadContainer
postContainerDecoder =
    JD.map (\posts -> PostPayloadContainer posts)
        (JD.field "posts" postListDecoder)


type alias CharactersPayloadContainer =
    { characters : List Character }


charactersContainerDecoder : JD.Decoder CharactersPayloadContainer
charactersContainerDecoder =
    JD.map (\characters -> CharactersPayloadContainer characters)
        (JD.field "characters" characterListDecoder)


type alias DicePayloadContainer =
    { dice : List DieMeta }


diceContainerDecoder : JD.Decoder DicePayloadContainer
diceContainerDecoder =
    JD.map (\dice -> DicePayloadContainer dice)
        (JD.field "dice" diceListDecoder)


type alias PresencePayloadContainer =
    { presence : List PresenceMeta }


presenceDecoder : JD.Decoder PresencePayloadContainer
presenceDecoder =
    JD.map (\presence -> PresencePayloadContainer presence)
        (JD.field "activity" presenceListDecoder)


postListDecoder : JD.Decoder (List Post)
postListDecoder =
    JD.list postDecoder


characterListDecoder : JD.Decoder (List Character)
characterListDecoder =
    JD.list characterDecoder


diceListDecoder : JD.Decoder (List DieMeta)
diceListDecoder =
    JD.list dieMetaDecoder


presenceListDecoder : JD.Decoder (List PresenceMeta)
presenceListDecoder =
    JD.list presenceMetaDecoder


postDecoder : JD.Decoder Post
postDecoder =
    decode Post
        |> required "author_slug" JD.string
        |> required "ooc" JD.bool
        |> required "narrative" JD.bool
        |> required "name" JD.string
        |> required "text" JD.string
        |> required "rolled" JD.string
        |> required "target" JD.int
        |> required "result" JD.int
        |> required "image" JD.string
        |> required "identities" JD.string
        |> required "date" JD.string
        |> required "time" JD.string


characterDecoder : JD.Decoder Character
characterDecoder =
    decode Character
        |> required "name" JD.string
        |> required "family" JD.string
        |> required "approved" JD.bool
        |> required "user" JD.int
        |> required "xp" JD.float
        |> required "image" JD.string
        |> required "id1" JD.string
        |> required "id1_pct" JD.int
        |> required "id2" JD.string
        |> required "id2_pct" JD.int
        |> required "id3" JD.string
        |> required "id3_pct" JD.int
        |> required "id4" JD.string
        |> required "id4_pct" JD.int
        |> required "id5" JD.string
        |> required "id5_pct" JD.int
        |> required "id6" JD.string
        |> required "id6_pct" JD.int
        |> required "favourite" JD.int
        |> required "guru" JD.int
        |> required "mentor" JD.int
        |> required "responsibility" JD.int
        |> required "protege" JD.int
        |> required "fitness" JD.int
        |> required "dodge" JD.int
        |> required "status" JD.int
        |> required "pursuit" JD.int
        |> required "knowledge" JD.int
        |> required "lie" JD.int
        |> required "notice" JD.int
        |> required "secrecy" JD.int
        |> required "connect" JD.int
        |> required "struggle" JD.int


dieMetaDecoder : JD.Decoder DieMeta
dieMetaDecoder =
    decode DieMeta
        |> required "die_id" JD.string
        |> required "enum" JD.int


presenceMetaDecoder : JD.Decoder PresenceMeta
presenceMetaDecoder =
    decode PresenceMeta
        |> required "timestamp" JD.string
        |> required "real_ts" JD.int
        |> required "name" JD.string
        |> required "location" JD.string



-- PORTS


port activity : (Bool -> msg) -> Sub msg


port title : String -> Cmd msg


port donk : () -> Cmd msg



-- SUBSCRIPTIONS


socket : Model -> Socket Msg
socket model =
    Socket.init model.socketUrl
        |> Socket.onOpen (ConnectionStatusChanged Connected)
        |> Socket.onClose (\_ -> ConnectionStatusChanged Disconnected)
        |> Socket.onAbnormalClose SocketClosedAbnormally
        |> Socket.reconnectTimer (\backoffIteration -> (backoffIteration + 1) * 5000 |> toFloat)


connect : Model -> Channel Msg
connect model =
    Channel.init ("room:" ++ model.loc)
        |> Channel.withPayload (JE.object [ ( "id", JE.string model.uid ), ( "key", JE.string model.key ) ])
        |> Channel.onJoin InitChannel
        |> Channel.on "update_posts" (\msg -> UpdatePosts msg)
        |> Channel.on "update_dice" (\msg -> UpdateDice msg)
        |> Channel.withDebug


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ phoenixSubscription model, Time.every Time.second Tick, activity Activity ]


phoenixSubscription model =
    Phoenix.connect (socket model) [ connect model ]



-- VIEW


view : Model -> Html Msg
view model =
    let
        posts_sub =
            if model.phone then
                "posts-phone"
            else
                "posts-desktop"
    in
    div []
        ([ renderInputBar model ] ++ [ div [ class ("posts " ++ posts_sub) ] (List.map (renderPost model.dice) model.posts) ] ++ [ dialog model ])


dialog : Model -> Html Msg
dialog model =
    let
        selected =
            getCharacter model.characters model.selectedCharacter
    in
    Dialog.view
        (if model.showDialog || model.showPresence then
            Just
                { closeMessage = Nothing
                , containerClass = Just "modal-container"
                , header =
                    Just
                        (div [ class "d-flex fill" ]
                            (if model.showPresence then
                                [ presenceDialogHeader, i [ class "p-2 fa fa-times fa-4x cancel-icon", onClick AckDialog ] [] ]
                             else
                                [ xpDialogHeader selected, i [ class "p-2 fa fa-times fa-4x cancel-icon", onClick AckDialog ] [] ]
                            )
                        )
                , body =
                    Just
                        (div [ class "modal-body" ]
                            (if model.showPresence then
                                [ presenceDialogBody model.presence ]
                             else
                                [ xpDialogBody selected model ]
                            )
                        )
                , footer = Nothing
                }
         else
            Nothing
        )


xpDialogHeader : Character -> Html Msg
xpDialogHeader selected =
    div [ class "mr-auto p-2" ] [ span [ class "xp-available" ] [ text (selected.xp |> toString) ], span [ class "xp-available-text" ] [ text " XP Available" ] ]


presenceDialogHeader : Html Msg
presenceDialogHeader =
    div [ class "mr-auto p-2" ] [ span [ class "xp-available-text" ] [ text "Currently Online:" ] ]


xpDialogBody : Character -> Model -> Html Msg
xpDialogBody selected model =
    div [ class "d-flex fill flex-column" ]
        [ div [ class "xp-menu-item d-flex flex-row" ] ([ xpDialogSkills selected ] ++ spend selected model.dialogSelectedSkill model.dialogSelectedSkillValue 2 True)
        , div [ class "xp-menu-item d-flex flew-row" ] ([ xpDialogRings selected ] ++ spend selected model.dialogSelectedRing model.dialogSelectedRingValue 3 False)
        ]


presenceDialogBody : List PresenceMeta -> Html Msg
presenceDialogBody presence =
    div [ class "d-flex fill flex-column" ]
        [ presence |> List.sortBy .real_ts |> List.reverse |> List.map presenceItem |> ul [ class "presence-list" ] ]


presenceItem : PresenceMeta -> Html Msg
presenceItem item =
    li [ class "presence-item" ] [ text (item.name ++ " @ " ++ item.location ++ ", " ++ item.timestamp) ]


spend : Character -> String -> Int -> Int -> Bool -> List (Html Msg)
spend s key value multiplier ignoreValidity =
    let
        newValue =
            value + 1

        cost =
            newValue * multiplier

        allow =
            False

        allowBuy =
            allow && (s.xp >= (cost |> toFloat))

        costString =
            if allow then
                span [ class "cost-text" ] [ text ("Cost: " ++ (cost |> toString)) ]
            else
                span [ class "cost-text disallow-cost" ] [ text "Cost: ---" ]

        buttonAttributes =
            if allowBuy then
                [ class "ml-auto p-1 btn btn-primary", onClick (SpendXP key) ]
            else
                [ class "ml-auto p-1 btn btn-danger btn-disabled", Html.Attributes.disabled True ]
    in
    [ span [] [ costString ]
    , button buttonAttributes [ text "BUY" ]
    ]


xpDialogSkills : Character -> Html Msg
xpDialogSkills s =
    select [ onInput DialogChangeSelectedSkill, class "custom-select mr-auto p-1" ]
        [ renderDialogSkillOption "" "-=[*]=-" -1
        ]


xpDialogRings : Character -> Html Msg
xpDialogRings s =
    select [ onInput DialogChangeSelectedRing, class "custom-select mr-auto p-1" ]
        [ renderDialogSkillOption "" "-=[*]=-" -1
        ]


renderDialogSkillOption : String -> String -> Int -> Html Msg
renderDialogSkillOption skill name val =
    let
        pretty =
            if val >= 0 then
                name ++ " " ++ (val |> toString)
            else
                "-=[*]=-"
    in
    option [ value (skill ++ ":" ++ (val |> toString)) ] [ text pretty ]


renderInputBar : Model -> Html Msg
renderInputBar model =
    let
        selected =
            getCharacter model.characters model.selectedCharacter

        interface_sub =
            if model.phone then
                "interface-phone"
            else
                "fixed-top interface-desktop"

        right_rail =
            if model.phone then
                "container right-rail"
            else
                "container right-rail right-rail-desktop"
    in
    div [ class ("navbar navbar-expand interface " ++ interface_sub) ]
        [ div [ class "container" ]
            [ div [ class "row interface-main no-gutters" ]
                [ div [ class "col col-3-lg image" ]
                    (if model.phone then
                        renderImageAndCharacterOptionsForPhone
                            model
                            selected
                     else
                        renderImageAndCharacterOptions
                            model
                            selected
                    )
                , div [ class "col-sm col-5-lg input-field" ]
                    [ textarea [ value model.post.text, Html.Attributes.maxlength model.cMax, onInput ChangeText ] []
                    ]
                , div [ class "col-sm col-4-lg" ]
                    [ div [ class right_rail ]
                        [ div [ class "d-flex align-items-start flex-column right-rail-inner" ]
                            [ renderDice selected model.post.narrative model.resetDice
                            , div [ class "p-0" ]
                                [ div []
                                    [ text
                                        ((model.cRemaining |> toString) ++ " Characters Remaining")
                                    ]
                                ]
                            , if not model.post.narrative then
                                div [ class "p-0" ]
                                    [ span [] [ text ((selected.xp |> toString) ++ " XP ") ]
                                    ]
                              else
                                text ""
                            , div [ class "mt-auto p-0" ]
                                [ button [ Html.Attributes.disabled (model.cRemaining == model.cMax), onClick (PushPost False), Html.Attributes.type_ "button", class "btn btn-outline btn-primary post-button" ] [ text "POST" ]
                                , button [ Html.Attributes.disabled (not ((model.cRemaining /= model.cMax) || (model.post.rolled /= ""))), onClick (PushPost True), Html.Attributes.type_ "button", class "btn btn-secondary post-button" ] [ text "OOC" ]
                                , if model.post.narrative then
                                    text ""
                                  else
                                    button [ Html.Attributes.type_ "button", class "btn btn-success post-button", onClick OpenDialog ] [ text "Spend XP" ]
                                , button [ Html.Attributes.type_ "button", class "btn btn-info post-button", onClick OpenPresence ] [ text "Activity" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


renderDice : Character -> Bool -> Bool -> Html Msg
renderDice s narrative reset =
    div [ class "mb-auto p-0" ]
        [ if narrative then
            select [ onInput ChangeSelectedSkill, class "custom-select" ]
                [ renderSelectableSkillOption "" "-=[*]=-" -1 reset
                , renderSkillOption "narr" "d100" 999
                , renderSkillOption "narr10" "d10" 999
                ]
          else
            select [ onInput ChangeSelectedSkill, class "custom-select" ]
                [ renderSelectableSkillOption "" "-=[*]=-" -1 reset
                , renderSkillOption "id1" s.id1 s.id1_pct
                , renderSkillOption "id2" s.id2 s.id2_pct
                , renderSkillOption "id3" s.id3 s.id3_pct
                , renderSkillOption "id4" s.id4 s.id4_pct
                , renderSkillOption "id5" s.id5 s.id5_pct
                , renderSkillOption "id6" s.id6 s.id6_pct
                , renderSkillOption "favourite" "Favourite" s.favourite
                , renderSkillOption "guru" "Guru" s.guru
                , renderSkillOption "mentor" "Mentor" s.mentor
                , renderSkillOption "responsibility" "Responsibility" s.responsibility
                , renderSkillOption "protege" "Protege" s.protege
                , renderSkillOption "fitness" "Fitness" s.fitness
                , renderSkillOption "dodge" "Dodge" s.dodge
                , renderSkillOption "status" "Status" s.status
                , renderSkillOption "pursuit" "Pursuit" s.pursuit
                , renderSkillOption "knowledge" "Knowledge" s.knowledge
                , renderSkillOption "lie" "Lie" s.lie
                , renderSkillOption "notice" "Notice" s.notice
                , renderSkillOption "secrecy" "Secrecy" s.secrecy
                , renderSkillOption "connect" "Connect" s.connect
                , renderSkillOption "struggle" "Struggle" s.struggle
                ]
        ]


renderSelectableSkillOption : String -> String -> Int -> Bool -> Html Msg
renderSelectableSkillOption skill name val sel =
    let
        pretty =
            if val > 0 then
                name ++ " " ++ (val |> toString)
            else
                "-=[*]=-"
    in
    option [ Html.Attributes.selected sel, value skill ] [ text pretty ]


renderSkillOption : String -> String -> Int -> Html Msg
renderSkillOption skill name val =
    let
        pretty =
            if val < 101 then
                name ++ " " ++ (val |> toString)
            else
                name

        showOption =
            if val > 0 then
                True
            else
                False
    in
    if showOption then
        option [ value skill ] [ text pretty ]
    else
        text ""


renderImageAndCharacterOptionsForPhone : Model -> Character -> List (Html Msg)
renderImageAndCharacterOptionsForPhone model selected =
    [ div [ class "row" ]
        [ div [ class "col" ]
            [ if not (model.post.image == "") then
                img [ class "character-image mt-1 mb-1 ml-0", src model.post.image ] []
              else
                text ""
            ]
        , div [ class "col" ]
            [ div [ class "stats text-center" ]
                [ if ((model.characters |> List.length) > 1) || model.admin then
                    select [ onInput ChangeSelectedCharacter, class "custom-select" ]
                        ((if model.admin then
                            [ option [ value "-1" ] [ text "[NARRATIVE]" ] ]
                          else
                            [ text "" ]
                         )
                            ++ List.indexedMap
                                characterOption
                                model.characters
                        )
                  else
                    strong [] [ text model.post.name ]
                ]
            ]
        ]
    ]


renderImageAndCharacterOptions : Model -> Character -> List (Html Msg)
renderImageAndCharacterOptions model selected =
    [ if not (model.post.image == "") then
        img [ class "character-image", src model.post.image ] []
      else
        text ""
    , div [ class "stats text-center options-grid" ]
        [ if ((model.characters |> List.length) > 1) || model.admin then
            select [ onInput ChangeSelectedCharacter, class "custom-select" ]
                ((if model.admin then
                    [ option [ value "-1" ] [ text "[NARRATIVE]" ] ]
                  else
                    [ text "" ]
                 )
                    ++ List.indexedMap
                        characterOption
                        model.characters
                )
          else
            strong [] [ text model.post.name ]
        ]
    ]


characterOption : Int -> Character -> Html Msg
characterOption idx c =
    option [ value (idx |> toString) ] [ text (c.family ++ " " ++ c.name) ]


checkbox : msg -> Bool -> String -> String -> Html msg
checkbox msg status name classextras =
    div [ class classextras ]
        [ label [ class "form-check-label mx-2" ]
            [ input [ Html.Attributes.checked status, Html.Attributes.type_ "checkbox", onClick msg, class "form-check-input" ] []
            , text name
            ]
        ]


renderPost : List DieMeta -> Post -> Html Msg
renderPost dice post =
    let
        post_classes =
            case ( post.narrative, post.ooc ) of
                ( True, True ) ->
                    "post post-ooc post-narrative"

                ( True, False ) ->
                    "post post-narrative"

                ( False, True ) ->
                    "post post-ooc"

                ( False, False ) ->
                    "post"

        roll_element =
            if post.target > 0 then
                text ("Rolled " ++ post.rolled ++ " (Skill Level " ++ (post.target |> toString) ++ "): " ++ (post.result |> toString))
            else if post.target == -1 then
                text ("Rolled 1d100: " ++ (post.result |> toString))
            else
                text ("Rolled 1d10: " ++ (post.result |> toString))
    in
    div [ class post_classes ]
        [ div [ class "row" ]
            [ if not post.narrative && not post.ooc then
                a [ href ("/characters/" ++ post.author_slug) ]
                    [ div [ class "col-2 image" ]
                        [ if not (post.image == "") then
                            img [ class "character-image", src post.image, Html.Attributes.width 150 ] []
                          else
                            text ""
                        , div [ class "stats text-center" ]
                            [ div [] [ strong [] [ text post.name, span [ property "innerHTML" (JE.string (String.lines post.identities |> String.join "<br>")) ] [] ] ]
                            ]
                        ]
                    ]
              else
                text ""
            , div [ class "col post-text" ]
                [ p [ class "text-justify" ]
                    [ if post.ooc then
                        text (post.name ++ ": ")
                      else
                        text ""
                    , span [ property "innerHTML" (JE.string (String.lines post.text |> String.join "<br>")) ] []
                    ]
                , if post.ooc && (post.rolled /= "") then
                    text ""
                  else
                    hr [] []
                , if post.rolled /= "" then
                    div [ class "diceroll text-center" ]
                        [ roll_element
                        ]
                  else
                    text ""
                , if not post.ooc then
                    div [ class "timestamp text-center font-weight-light" ]
                        [ text post.date
                        , br [] []
                        , text post.time
                        ]
                  else
                    text ""
                ]
            ]
        ]


diceClass : Int -> Post -> List DieMeta -> String
diceClass index post dice =
    let
        dbj =
            foldl updateDbjHash 5381 post.text

        die_id =
            post.author_slug ++ "-" ++ (index |> toString) ++ "-" ++ post.time ++ "-" ++ (dbj |> toString)

        selected =
            List.any
                (\die -> die.die_id == die_id)
                dice

        match =
            List.filter (\die -> die.die_id == die_id) dice

        h =
            List.head match

        enum =
            if selected then
                case h of
                    Just m ->
                        m.enum

                    Nothing ->
                        0
            else
                0
    in
    if selected then
        case enum of
            1 ->
                "die-selected"

            2 ->
                "die-special"

            _ ->
                "die-unselected"
    else
        "die-unselected"


hoverDice : Int -> String
hoverDice face =
    case face of
        0 ->
            "Opportunity + Strife"

        1 ->
            "Success"

        2 ->
            "Success + Strife"

        3 ->
            "Blank"

        4 ->
            "Opportunity"

        5 ->
            "Explosive + Strife"

        6 ->
            "Blank"

        7 ->
            "Blank"

        8 ->
            "Success"

        9 ->
            "Success"

        10 ->
            "Opportunity + Success"

        11 ->
            "Success + Strife"

        12 ->
            "Success + Strife"

        13 ->
            "Explosive"

        14 ->
            "Explosive + Strife"

        15 ->
            "Opportunity"

        16 ->
            "Opportunity"

        17 ->
            "Opportunity"

        _ ->
            "Dunno wtf happened here"
