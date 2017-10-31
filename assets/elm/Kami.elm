module Kami exposing (..)

import Array exposing (Array)
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
    , post : Post
    , selectedCharacter : Int
    , admin : Bool
    , phone : Bool
    , cRemaining : Int
    , cMax : Int
    , showDialog : Bool
    , resetDice : Bool
    , dialogSelectedSkill : String
    , dialogSelectedRing : String
    , dialogSelectedSkillValue : Int
    , dialogSelectedRingValue : Int
    }


getCharacter : List Character -> Int -> Character
getCharacter list index =
    case list |> Array.fromList |> Array.get index of
        Just character ->
            character

        Nothing ->
            Character "[Narrative]" "" True 0 0 0 0 0 0 0 0 0 0 0 [] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0


type alias Character =
    { name : String
    , family : String
    , approved : Bool
    , status : Int
    , glory : Int
    , air : Int
    , earth : Int
    , fire : Int
    , water : Int
    , void : Int
    , strife : Int
    , user : Int
    , xp : Float
    , bxp : Float
    , images : List String
    , void_points : Int
    , aesthetics : Int
    , composition : Int
    , design : Int
    , smithing : Int
    , fitness : Int
    , melee : Int
    , ranged : Int
    , unarmed : Int
    , iaijutsu : Int
    , meditation : Int
    , tactics : Int
    , culture : Int
    , government : Int
    , sentiment : Int
    , theology : Int
    , medicine : Int
    , command : Int
    , courtesy : Int
    , games : Int
    , performance : Int
    , commerce : Int
    , labor : Int
    , seafaring : Int
    , skulduggery : Int
    , survival : Int
    }


type alias Post =
    { author_slug : String
    , ooc : Bool
    , narrative : Bool
    , name : String
    , glory : Int
    , status : Int
    , text : String
    , diceroll : Bool
    , die_size : Int
    , results : List Int
    , ring_name : String
    , skill_name : String
    , ring_value : Int
    , skillroll : Bool
    , image : String
    , date : String
    , time : String
    }


type alias InitFlags =
    { uid : String
    , loc : String
    , key : String
    , width : Int
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
      , post = Post "" False False "" 0 0 "" False 0 [] "" "" 0 False "" "" ""
      , selectedCharacter = 0
      , admin = False
      , phone = flags.width < 600
      , cRemaining = 1500
      , cMax = 1500
      , showDialog = False
      , resetDice = True
      , dialogSelectedRing = ""
      , dialogSelectedSkill = ""
      , dialogSelectedRingValue = -1
      , dialogSelectedSkillValue = -1
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
    | PushPost Bool
    | ChangeSelectedCharacter String
    | ChangeSelectedSkill String
    | ChangeSelectedRing String
    | ChangeImage String
    | ChangeText String
    | ToggleSpecialDice
    | ChangeDieSize Int
    | ChangeDieNum Int
    | ModifyStat String Int
    | SpendXP String
    | ModifyStatFailed JD.Value
    | OpenDialog
    | AckDialog
    | DialogChangeSelectedSkill String
    | DialogChangeSelectedRing String


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

        AckDialog ->
            { model | showDialog = False, dialogSelectedRing = "", dialogSelectedSkill = "", dialogSelectedRingValue = -1, dialogSelectedSkillValue = -1 } ! []

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
                            character.family ++ " " ++ character.name

                        firstImage =
                            character.images |> List.head |> Maybe.withDefault ""

                        posts =
                            payloadContainer.posts

                        initPost =
                            case admin of
                                True ->
                                    Post "" False True "-=[Narrative]=-" 0 0 "" False 0 [] "" "" 0 True "" "" ""

                                False ->
                                    Post slug False False name character.glory character.status "" False 0 [] "" "" 0 True firstImage "" ""
                    in
                    { model | post = initPost, admin = admin, selectedCharacter = selectedCharacter, posts = payloadContainer.posts, characters = payloadContainer.characters } ! []

                Err err ->
                    let
                        _ =
                            Debug.log "initChannel payload error " ( err, payload )
                    in
                    model ! []

        UpdatePosts payload ->
            case JD.decodeValue postContainerDecoder payload of
                Ok payloadContainer ->
                    { model | posts = payloadContainer.posts } ! []

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

                firstImage =
                    selected.images |> List.head |> Maybe.withDefault ""

                narrative =
                    s == "-1"

                oldPost =
                    model.post

                newPost =
                    { oldPost | name = full_name, author_slug = author_slug, narrative = narrative, image = firstImage, diceroll = False, skill_name = "", ring_name = "", glory = selected.glory, status = selected.status }
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

                diceroll =
                    skill /= "" && model.post.ring_name /= ""

                newPost =
                    { oldPost | skill_name = skill, diceroll = diceroll }
            in
            { model | post = newPost, resetDice = False } ! []

        ChangeSelectedRing ring ->
            let
                oldPost =
                    model.post

                diceroll =
                    ring /= "" && model.post.skill_name /= ""

                newPost =
                    { oldPost | ring_name = ring, diceroll = diceroll }
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

        ToggleSpecialDice ->
            let
                oldPost =
                    model.post

                newPost =
                    { oldPost | skillroll = not oldPost.skillroll }
            in
            { model | post = newPost } ! []

        ChangeDieSize num ->
            let
                oldPost =
                    model.post

                newPost =
                    { oldPost | die_size = num }
            in
            { model | post = newPost } ! []

        ChangeDieNum num ->
            let
                oldPost =
                    model.post

                newPost =
                    { oldPost | ring_value = num }
            in
            { model | post = newPost } ! []

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
            model ! [ Phoenix.push lobbySocket push ]

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
            { model | showDialog = False, dialogSelectedRing = "", dialogSelectedSkill = "", dialogSelectedRingValue = -1, dialogSelectedSkillValue = -1 } ! [ Phoenix.push lobbySocket push ]

        ModifyStatFailed value ->
            let
                _ =
                    Debug.log "modify stat returned an error code" value
            in
            model ! []

        PushPost ooc ->
            let
                push =
                    Push.init "room:1" "post"
                        |> Push.withPayload
                            (JE.object
                                [ ( "author_slug", JE.string model.post.author_slug )
                                , ( "ooc", JE.bool ooc )
                                , ( "narrative", JE.bool model.post.narrative )
                                , ( "name", JE.string model.post.name )
                                , ( "text", JE.string model.post.text )
                                , ( "diceroll", JE.bool model.post.diceroll )
                                , ( "die_size", JE.int model.post.die_size )
                                , ( "ring_value", JE.int model.post.ring_value )
                                , ( "ring_name", JE.string model.post.ring_name )
                                , ( "skill_name", JE.string model.post.skill_name )
                                , ( "skillroll", JE.bool model.post.skillroll )
                                , ( "image", JE.string model.post.image )
                                ]
                            )

                oldPost =
                    model.post

                newPost =
                    { oldPost | text = "", diceroll = False, die_size = 0, ring_value = 0, skill_name = "", ring_name = "" }
            in
            { model | post = newPost, cRemaining = model.cMax, resetDice = True } ! [ Phoenix.push lobbySocket push ]



-- UPDATE HELPERS


roundDownToSecond : Time -> Time
roundDownToSecond ms =
    (ms / 1000) |> truncate |> (*) 1000 |> toFloat



-- DECODERS


type alias InitPayloadContainer =
    { posts : List Post
    , characters : List Character
    , admin : Bool
    }


initDecoder : JD.Decoder InitPayloadContainer
initDecoder =
    JD.map3 (\posts characters admin -> InitPayloadContainer posts characters admin)
        (JD.field "posts" postListDecoder)
        (JD.field "characters" characterListDecoder)
        (JD.field "admin" JD.bool)


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


postListDecoder : JD.Decoder (List Post)
postListDecoder =
    JD.list postDecoder


characterListDecoder : JD.Decoder (List Character)
characterListDecoder =
    JD.list characterDecoder


postDecoder : JD.Decoder Post
postDecoder =
    decode Post
        |> required "author_slug" JD.string
        |> required "ooc" JD.bool
        |> required "narrative" JD.bool
        |> required "name" JD.string
        |> required "glory" JD.int
        |> required "status" JD.int
        |> required "text" JD.string
        |> required "diceroll" JD.bool
        |> required "die_size" JD.int
        |> required "results" (JD.list JD.int)
        |> required "ring_name" JD.string
        |> required "skill_name" JD.string
        |> required "ring_value" JD.int
        |> required "skillroll" JD.bool
        |> required "image" JD.string
        |> required "date" JD.string
        |> required "time" JD.string


characterDecoder : JD.Decoder Character
characterDecoder =
    decode Character
        |> required "name" JD.string
        |> required "family" JD.string
        |> required "approved" JD.bool
        |> required "status" JD.int
        |> required "glory" JD.int
        |> required "air" JD.int
        |> required "earth" JD.int
        |> required "fire" JD.int
        |> required "water" JD.int
        |> required "void" JD.int
        |> required "strife" JD.int
        |> required "user" JD.int
        |> required "xp" JD.float
        |> required "bxp" JD.float
        |> required "images" (JD.list JD.string)
        |> required "void_points" JD.int
        |> required "aesthetics" JD.int
        |> required "composition" JD.int
        |> required "design" JD.int
        |> required "smithing" JD.int
        |> required "fitness" JD.int
        |> required "melee" JD.int
        |> required "ranged" JD.int
        |> required "unarmed" JD.int
        |> required "iaijutsu" JD.int
        |> required "meditation" JD.int
        |> required "tactics" JD.int
        |> required "culture" JD.int
        |> required "government" JD.int
        |> required "sentiment" JD.int
        |> required "theology" JD.int
        |> required "medicine" JD.int
        |> required "command" JD.int
        |> required "courtesy" JD.int
        |> required "games" JD.int
        |> required "performance" JD.int
        |> required "commerce" JD.int
        |> required "labor" JD.int
        |> required "seafaring" JD.int
        |> required "skulduggery" JD.int
        |> required "survival" JD.int



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


connect : Model -> Channel Msg
connect model =
    Channel.init ("room:" ++ model.loc)
        |> Channel.withPayload (JE.object [ ( "id", JE.string model.uid ), ( "key", JE.string model.key ) ])
        |> Channel.onJoin InitChannel
        |> Channel.on "update_posts" (\msg -> UpdatePosts msg)
        |> Channel.withDebug


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ phoenixSubscription model, Time.every Time.second Tick ]


phoenixSubscription model =
    Phoenix.connect socket [ connect model ]



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
        ([ renderInputBar model ] ++ [ div [ class ("posts " ++ posts_sub) ] (List.map renderPost model.posts) ] ++ [ xpDialog model ])


xpDialog : Model -> Html Msg
xpDialog model =
    let
        selected =
            getCharacter model.characters model.selectedCharacter
    in
    Dialog.view
        (if model.showDialog then
            Just
                { closeMessage = Nothing
                , containerClass = Just "modal-container"
                , header = Just (div [ class "d-flex fill" ] [ xpDialogHeader selected, i [ class "p-2 fa fa-times fa-4x cancel-icon", onClick AckDialog ] [] ])
                , body = Just (div [ class "modal-body" ] [ xpDialogBody selected model ])
                , footer = Nothing
                }
         else
            Nothing
        )


xpDialogHeader : Character -> Html Msg
xpDialogHeader selected =
    div [ class "mr-auto p-2" ] [ span [ class "xp-available" ] [ text (selected.xp |> toString) ], span [ class "xp-available-text" ] [ text " XP Available" ] ]


xpDialogBody : Character -> Model -> Html Msg
xpDialogBody selected model =
    div [ class "d-flex fill flex-column" ]
        [ div [ class "xp-menu-item d-flex flex-row" ] ([ xpDialogSkills selected ] ++ spend selected model.dialogSelectedSkill model.dialogSelectedSkillValue 2 True)
        , div [ class "xp-menu-item d-flex flew-row" ] ([ xpDialogRings selected ] ++ spend selected model.dialogSelectedRing model.dialogSelectedRingValue 3 False)
        ]


spend : Character -> String -> Int -> Int -> Bool -> List (Html Msg)
spend s key value multiplier ignoreValidity =
    let
        newValue =
            value + 1

        cost =
            newValue * multiplier

        smallestRing =
            List.minimum [ s.fire, s.air, s.earth, s.water, s.void ]

        valid =
            newValue <= (Maybe.withDefault 0 smallestRing + s.void)

        allow =
            (ignoreValidity || valid) && newValue /= 0

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
        , renderDialogSkillOption "skill_aesthetics" "Aesthetics" s.aesthetics
        , renderDialogSkillOption "skill_composition" "Composition" s.composition
        , renderDialogSkillOption "skill_design" "Composition" s.composition
        , renderDialogSkillOption "skill_smithing" "Smithing" s.smithing
        , renderDialogSkillOption "skill_fitness" "Fitness" s.fitness
        , renderDialogSkillOption "skill_melee" "Melee" s.melee
        , renderDialogSkillOption "skill_ranged" "Ranged" s.ranged
        , renderDialogSkillOption "skill_unarmed" "Unarmed" s.unarmed
        , renderDialogSkillOption "skill_iaijutsu" "Iaijutsu" s.iaijutsu
        , renderDialogSkillOption "skill_meditation" "Meditation" s.meditation
        , renderDialogSkillOption "skill_tactics" "Tactics" s.tactics
        , renderDialogSkillOption "skill_culture" "Culture" s.culture
        , renderDialogSkillOption "skill_government" "Government" s.government
        , renderDialogSkillOption "skill_sentiment" "Sentiment" s.sentiment
        , renderDialogSkillOption "skill_theology" "Theology" s.theology
        , renderDialogSkillOption "skill_medicine" "Medicine" s.medicine
        , renderDialogSkillOption "skill_command" "Command" s.command
        , renderDialogSkillOption "skill_courtesy" "Courtesy" s.courtesy
        , renderDialogSkillOption "skill_games" "Games" s.games
        , renderDialogSkillOption "skill_performance" "Performance" s.performance
        , renderDialogSkillOption "skill_commerce" "Commerce" s.commerce
        , renderDialogSkillOption "skill_labor" "Labor" s.labor
        , renderDialogSkillOption "skill_seafaring" "Seafaring" s.seafaring
        , renderDialogSkillOption "skill_skullduggery" "Skulduggery" s.skulduggery
        , renderDialogSkillOption "skill_survival" "Survival" s.survival
        ]


xpDialogRings : Character -> Html Msg
xpDialogRings s =
    select [ onInput DialogChangeSelectedRing, class "custom-select mr-auto p-1" ]
        [ renderDialogSkillOption "" "-=[*]=-" -1
        , renderDialogSkillOption "air" "Air" s.air
        , renderDialogSkillOption "earth" "Earth" s.earth
        , renderDialogSkillOption "fire" "Fire" s.fire
        , renderDialogSkillOption "water" "Water" s.water
        , renderDialogSkillOption "void" "Void" s.void
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

        composure =
            (selected.earth + selected.fire) * 2

        panic =
            if not model.post.narrative && (selected.strife == composure) && composure > 0 then
                " panic-mode"
            else
                ""

        disable_post =
            if model.cRemaining == 1500 then
                " btn-disabled"
            else
                ""
    in
    div [ class ("navbar navbar-expand interface " ++ interface_sub ++ panic) ]
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
                                , if not model.post.narrative then
                                    div []
                                        [ span [ class "fa fa-minus", onClick (ModifyStat "void_points" -1) ] []
                                        , span [] [ text (" " ++ (selected.void_points |> toString) ++ "/" ++ (selected.void |> toString) ++ " Void ") ]
                                        , span [ class "fa fa-plus", onClick (ModifyStat "void_points" 1) ] []
                                        , span [ class "spacer-span" ] []
                                        , span [ class "fa fa-minus", onClick (ModifyStat "strife" -1) ] []
                                        , span [] [ text (" " ++ (selected.strife |> toString) ++ "/" ++ (((selected.earth + selected.fire) * 2) |> toString) ++ " Strife ") ]
                                        , span [ class "fa fa-plus", onClick (ModifyStat "strife" 1) ] []
                                        ]
                                  else
                                    text ""
                                ]
                            , if not model.post.narrative then
                                div [ class "p-0" ]
                                    [ span [] [ text ((selected.xp |> toString) ++ " XP " ++ (selected.bxp |> toString) ++ " BXP") ]
                                    ]
                              else
                                text ""
                            , div [ class "mt-auto p-0" ]
                                [ button [ Html.Attributes.disabled (model.cRemaining == model.cMax), onClick (PushPost False), Html.Attributes.type_ "button", class "btn btn-outline btn-primary post-button" ] [ text "POST" ]
                                , button [ Html.Attributes.disabled (not ((model.cRemaining /= model.cMax) || model.post.diceroll)), onClick (PushPost True), Html.Attributes.type_ "button", class "btn btn-secondary post-button" ] [ text "OOC" ]
                                , if model.post.narrative then
                                    text ""
                                  else
                                    button [ Html.Attributes.type_ "button", class "btn btn-success post-button", onClick OpenDialog ] [ text "Spend XP" ]
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
            text ""
          else
            select [ onInput ChangeSelectedSkill, class "custom-select" ]
                [ renderSelectableSkillOption "" "-=[*]=-" -1 reset
                , renderSkillOption "skill_aesthetics" "Aesthetics" s.aesthetics
                , renderSkillOption "skill_composition" "Composition" s.composition
                , renderSkillOption "skill_design" "Composition" s.composition
                , renderSkillOption "skill_smithing" "Smithing" s.smithing
                , renderSkillOption "skill_fitness" "Fitness" s.fitness
                , renderSkillOption "skill_melee" "Melee" s.melee
                , renderSkillOption "skill_ranged" "Ranged" s.ranged
                , renderSkillOption "skill_unarmed" "Unarmed" s.unarmed
                , renderSkillOption "skill_iaijutsu" "Iaijutsu" s.iaijutsu
                , renderSkillOption "skill_meditation" "Meditation" s.meditation
                , renderSkillOption "skill_tactics" "Tactics" s.tactics
                , renderSkillOption "skill_culture" "Culture" s.culture
                , renderSkillOption "skill_government" "Government" s.government
                , renderSkillOption "skill_sentiment" "Sentiment" s.sentiment
                , renderSkillOption "skill_theology" "Theology" s.theology
                , renderSkillOption "skill_medicine" "Medicine" s.medicine
                , renderSkillOption "skill_command" "Command" s.command
                , renderSkillOption "skill_courtesy" "Courtesy" s.courtesy
                , renderSkillOption "skill_games" "Games" s.games
                , renderSkillOption "skill_performance" "Performance" s.performance
                , renderSkillOption "skill_commerce" "Commerce" s.commerce
                , renderSkillOption "skill_labor" "Labor" s.labor
                , renderSkillOption "skill_seafaring" "Seafaring" s.seafaring
                , renderSkillOption "skill_skullduggery" "Skulduggery" s.skulduggery
                , renderSkillOption "skill_survival" "Survival" s.survival
                ]
        , if narrative then
            text ""
          else
            select [ onInput ChangeSelectedRing, class "custom-select" ]
                [ renderSelectableSkillOption "" "-=[*]=-" -1 reset
                , renderSkillOption "air" "Air" s.air
                , renderSkillOption "earth" "Earth" s.earth
                , renderSkillOption "fire" "Fire" s.fire
                , renderSkillOption "water" "Water" s.water
                , renderSkillOption "void" "Void" s.void
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
            if val >= 0 then
                name ++ " " ++ (val |> toString)
            else
                "-=[*]=-"
    in
    option [ value skill ] [ text pretty ]


renderImageAndCharacterOptionsForPhone : Model -> Character -> List (Html Msg)
renderImageAndCharacterOptionsForPhone model selected =
    [ div [ class "row" ]
        [ div [ class "col" ]
            [ if not (model.post.image == "") then
                img [ class "character-image mt-1 mb-1 ml-0", src ("http://aurum.aludel.xyz/gnkstatic/" ++ model.post.image) ] []
              else
                text ""
            ]
        , div [ class "col" ]
            [ div [ class "stats text-center" ]
                [ if (model.characters |> List.length) > 1 then
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
                , if (selected.images |> List.length) > 0 then
                    select [ onInput ChangeImage, class "custom-select" ]
                        (List.map
                            (imageOption model.post.image)
                            selected.images
                        )
                  else
                    text ""
                ]
            ]
        ]
    ]


renderImageAndCharacterOptions : Model -> Character -> List (Html Msg)
renderImageAndCharacterOptions model selected =
    [ if not (model.post.image == "") then
        img [ class "character-image", src ("http://aurum.aludel.xyz/gnkstatic/" ++ model.post.image) ] []
      else
        text ""
    , div [ class "stats text-center options-grid" ]
        [ if (model.characters |> List.length) > 1 then
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
        , if (selected.images |> List.length) > 0 then
            select [ onInput ChangeImage, class "custom-select" ]
                (List.map
                    (imageOption model.post.image)
                    selected.images
                )
          else
            text ""
        ]
    ]


imageOption : String -> String -> Html Msg
imageOption current filename =
    option [ selected (current == filename), value filename ] [ text filename ]


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


renderPost : Post -> Html Msg
renderPost post =
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
    in
    div [ class post_classes ]
        [ div [ class "row" ]
            [ if not post.narrative && not post.ooc then
                a [ href ("/characters/" ++ post.author_slug) ]
                    [ div [ class "col-2 image" ]
                        [ if not (post.image == "") then
                            img [ class "character-image", src ("http://aurum.aludel.xyz/gnkstatic/" ++ post.image), Html.Attributes.width 150 ] []
                          else
                            text ""
                        , div [ class "stats text-center" ]
                            [ div [] [ strong [] [ text post.name ] ]
                            , div [] [ strong [] [ text "Glory " ], text (toString post.glory) ]
                            , div [] [ strong [] [ text "Status " ], text (toString post.status) ]
                            ]
                        ]
                    ]
              else
                text ""
            , div [ class "col post-text" ]
                [ p [ class "text-justify" ]
                    [ text (post.name ++ " ")
                    , span [ property "innerHTML" (JE.string (String.lines post.text |> String.join "<br>")) ] []
                    ]
                , if post.ooc && not post.diceroll then
                    text ""
                  else
                    hr [] []
                , if post.diceroll then
                    div [ class "diceroll text-center" ]
                        [ if post.skillroll then
                            div []
                                ([ text ("Rolled " ++ post.skill_name ++ " (" ++ post.ring_name ++ "), " ++ (List.length post.results |> toString) ++ "k" ++ toString post.ring_value ++ ": ") ]
                                    ++ (post.results
                                            |> List.map (\result -> a [ Html.Attributes.attribute "hovertitle" (hoverDice result) ] [ img [ class "dice-image", src ("http://aurum.aludel.xyz/gnkstatic/dice/" ++ toString result ++ ".png") ] [] ])
                                       )
                                )
                          else
                            text
                                ("Rolled "
                                    ++ (List.length post.results |> toString)
                                    ++ "d"
                                    ++ (post.die_size |> toString)
                                    ++ ": "
                                    ++ (List.map (\a -> toString a) post.results |> String.join ", ")
                                )
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
