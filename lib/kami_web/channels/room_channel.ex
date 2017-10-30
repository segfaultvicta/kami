defmodule KamiWeb.RoomChannel do
  use KamiWeb, :channel
  require Logger

  def join("room:" <> loc_id, %{"id" => user_id, "key" => key}, socket) do
    if authorized?(loc_id, user_id, key) do
      {loc_id, _} = Integer.parse(loc_id)
      {user_id, _} = Integer.parse(user_id)
      is_admin = Kami.Accounts.is_admin?(user_id)
      socket = socket
      |> Phoenix.Socket.assign(:location, loc_id)
      |> Phoenix.Socket.assign(:user, user_id)
      |> Phoenix.Socket.assign(:admin, is_admin)
      posts = get_posts(loc_id)
      characters = get_characters(user_id)
      {:ok, %{posts: posts, characters: characters, admin: is_admin}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  
  def handle_in("modify", %{"character" => character_name, "stat_key" => stat_key, "delta" => delta}, socket) do
    character = Kami.Accounts.get_character_by_name!(character_name)
    if character.user_id == socket.assigns[:user] do
      {status, result} = Kami.Accounts.update_stat(character, stat_key, delta)
      case status do
        :ok ->
          {:reply, {:ok, %{characters: get_characters(socket.assigns[:user])}}, socket}
        :error ->
          {:reply, {:error, %{reason: result}}, socket}
        end
    else
      {:reply, {:error, %{reason: "unauthorised to update that character"}}, socket}
    end
  end
  
  def handle_in("post", %{"author_slug" => slug, "ooc" => ooc, "narrative" => narr, "name" => name, "text" => text, "diceroll" => dice, 
                          "die_size" => face, "ring_value" => num, "ring_name" => ring, "skill_name" => skill, "skillroll" => specialdice, "image" => image}, socket) do
    name = if narr do "" else name end
    {glory, status, skill_name, ring_name, ring_value, skill_value, results} = if not narr do
      character = Kami.Accounts.get_character_by_name!(slug)
      glory = character.glory
      status = character.status
      skill_name = String.split(skill, "_") |> Enum.at(1) |> String.capitalize
      ring_name = ring |> String.capitalize
      ring_value = if specialdice do Kami.Accounts.Character.get_value(character, ring) else num end
      skill_value = Kami.Accounts.Character.get_value(character, skill)
      results = if specialdice do
        (1..ring_value |> Enum.map(fn(_) -> Enum.random(0..5) end)) ++ (1..skill_value |> Enum.map(fn(_) -> Enum.random(6..17) end)) 
      else
        []
      end
      {glory, status, skill_name, ring_name, ring_value, skill_value, results}
    else
      {0, 0, "", "", 0, 0, []}
    end
    Kami.World.create_post(socket.assigns[:location], slug, %{ooc: ooc, narrative: narr, text: text, name: name, image: image, glory: glory, status: status,
                                                              diceroll: dice, skillroll: specialdice, ring_name: ring_name, skill_name: skill_name, results: results, ring_value: ring_value, die_size: face})
    broadcast!(socket, "update_posts", %{posts: get_posts(socket.assigns[:location])})
    {:reply, {:ok, %{updated_bxp: 0}}, socket}
  end

  defp get_posts(location_id) do
    posts = 
      Kami.World.get_backfill!(location_id, 20)
      |> Enum.map(fn(post) ->  %{author_slug: post.author_slug, ooc: post.ooc, narrative: post.narrative, name: post.name, 
                                 glory: post.glory, status: post.status, text: post.text, diceroll: post.diceroll, die_size: post.die_size, 
                                 results: l(post.results), ring_name: post.ring_name, ring_value: post.ring_value, skill_name: post.skill_name, 
                                 skillroll: post.skillroll, image: post.image, 
                                 date: Timex.format(Timex.Timezone.convert(post.inserted_at, Timex.Timezone.get("America/New_York")), "{D} {Mshort} {YYYY}") |> Tuple.to_list |> List.last,
                                 time: Timex.format(Timex.Timezone.convert(post.inserted_at, Timex.Timezone.get("America/New_York")), "{h24}:{m}") |> Tuple.to_list |> List.last } end)
  end
  

  
  defp get_characters(user_id) do
    Kami.Accounts.get_characters(user_id) 
    |> Enum.map(fn(c) -> %{name: c.name, family: c.family, approved: c.approved, status: c.status, glory: c.glory, air: c.air, earth: c.earth, fire: c.fire, void: c.void, 
       water: c.water, strife: c.strife, user: c.user_id, xp: c.xp, bxp: c.bxp, images: c.images, void_points: c.void_points,
       aesthetics: c.skill_aesthetics, composition: c.skill_composition, design: c.skill_design, smithing: c.skill_smithing, 
       fitness: c.skill_fitness, melee: c.skill_melee, ranged: c.skill_ranged, unarmed: c.skill_unarmed, iaijutsu: c.skill_iaijutsu, meditation: c.skill_meditation, tactics: c.skill_tactics, 
       culture: c.skill_culture, government: c.skill_government, sentiment: c.skill_sentiment, theology: c.skill_theology, medicine: c.skill_medicine, 
       command: c.skill_command, courtesy: c.skill_courtesy, games: c.skill_games, performance: c.skill_performance,
       commerce: c.skill_commerce, labor: c.skill_labor, seafaring: c.skill_seafaring, skulduggery: c.skill_skullduggery, survival: c.skill_survival
       } end)
  end

  defp l(i) do
    if is_nil(i) do
      []
    else
      i
    end
  end

  # Add authorization logic here as required.
  defp authorized?(loc_id, user_id, key) do
    {:ok, key} = Base.decode64(key)
    Logger.info "id: " <> user_id <> ", loc: " <> loc_id <> ", key: " <> key
    if :crypto.hash(:sha512, loc_id <> "." <> user_id <> "." <> Application.get_env(:kami, :elm_secret)) == key do
      true
    else
      Logger.warn "channel auth failure, id: " <> user_id <> ", loc: " <> loc_id <> ", key: " <> key
      false
    end
  end
end
