defmodule KamiWeb.RoomChannel do
  use KamiWeb, :channel
  alias Kami.Actors.Dice
  alias Kami.Actors.Activity
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
      dice = Dice.get(loc_id)
      Activity.join(user_id, loc_id)
      {:ok, %{posts: posts, characters: characters, admin: is_admin, dice: dice}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def terminate(_, socket) do
    Activity.part(socket.assigns[:user])
  end

  def handle_in("still_alive", _, socket) do
    Activity.ping(socket.assigns[:user])
    {:noreply, socket}
  end

  def handle_in("presence", _, socket) do
    {:reply, {:ok, %{activity: Activity.get}}, socket}
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

  def handle_in("spend_xp", %{"character" => character_name, "stat_key" => stat_key}, socket) do
    character = Kami.Accounts.get_character_by_name!(character_name)
    if character.user_id == socket.assigns[:user] do
      {status, result} = Kami.Accounts.buy_upgrade_for_stat(character, stat_key)
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

  def handle_in("die_toggle", %{"idx" => index, "author" => author, "time" => time, "hash" => hash}, socket) do
    user = if (author == "") || author == "[narrative]" do -1 else Kami.Accounts.get_character_by_name!(author).user_id end
    if socket.assigns[:user] == user || (socket.assigns[:admin]) do
      id = "#{author}-#{index}-#{time}-#{hash}"
      Dice.trigger(id, DateTime.utc_now(), socket.assigns[:location])
      broadcast!(socket, "update_dice", %{dice: Dice.get(socket.assigns[:location])})
      {:reply, {:ok, %{}}, socket}
    else
      {:reply, {:error, %{reason: "unauthorised to update that character's dice results"}}, socket}
    end
  end

  def handle_in("post", %{"author_slug" => slug, "ooc" => ooc, "narrative" => narr, "name" => name, "text" => text, "diceroll" => dice,
                          "die_size" => face, "ring_value" => num, "ring_name" => ring, "skill_name" => skill, "skillroll" => specialdice, "image" => image}, socket) do
    name = if narr do "" else name end
    character = if narr do nil else Kami.Accounts.get_character_by_name!(slug) end
    glory = 0
    status = 0
    arbitrary = skill == "arbitrary" or ring == "arbitrary"
    skill_name = if dice and character != nil and not arbitrary do String.split(skill, "_") |> Enum.at(1) |> String.capitalize else "" end
    ring_name = if dice and character != nil and not arbitrary do ring |> String.capitalize else "" end
    ring_value = if dice and specialdice and character != nil and not arbitrary do Kami.Accounts.Character.get_value(character, ring) else num end
    skill_value = if dice and specialdice and character != nil and not arbitrary do Kami.Accounts.Character.get_value(character, skill) else 0 end
    ring_value = if arbitrary do num else ring_value end
    skill_value = if arbitrary do face else skill_value end
    results = if specialdice do
      cond do
        ring_value > 0 and skill_value > 0 ->
          (1..ring_value |> Enum.map(fn(_) -> Enum.random(0..5) end)) ++ (1..skill_value |> Enum.map(fn(_) -> Enum.random(6..17) end))

        skill_value == 0 ->
          (1..ring_value |> Enum.map(fn(_) -> Enum.random(0..5) end))

        ring_value == 0 and arbitrary ->
          (1..skill_value |> Enum.map(fn(_) -> Enum.random(6..17) end))

        true ->
          []
      end
    else
      []
    end
    text = if ooc && text == "" do "\n" else HtmlSanitizeEx.strip_tags(text) end
    identities = if character != nil do Kami.Accounts.Character.serialise_public_identities(character) else "" end
    Kami.World.create_post(socket.assigns[:location], slug, %{ooc: ooc, narrative: narr, text: text, name: name, image: image, glory: glory, status: status,
                                                              diceroll: dice, skillroll: specialdice, ring_name: ring_name, skill_name: skill_name, results: results,
                                                              ring_value: ring_value, die_size: face, identities: identities})
    broadcast!(socket, "update_posts", %{posts: get_posts(socket.assigns[:location])})
    if not ooc and not Kami.World.is_ooc?(socket.assigns[:location]) and not narr and not socket.assigns[:admin] do
      Kami.Accounts.award_bxp(character)
    end
    {:reply, {:ok, %{characters: get_characters(socket.assigns[:user])}}, socket}
  end

  defp get_posts(location_id) do
    Kami.World.get_backfill!(location_id, Application.get_env(:kami, :posts_to_show))
    |> Enum.map(fn(post) ->  %{author_slug: post.author_slug, ooc: post.ooc, narrative: post.narrative, name: post.name,
                               glory: post.glory, status: post.status, text: post.text, diceroll: post.diceroll, die_size: post.die_size,
                               results: l(post.results), ring_name: post.ring_name, ring_value: post.ring_value, skill_name: post.skill_name,
                               skillroll: post.skillroll, image: post.image, identities: post.identities,
                               date: Timex.format(Timex.Timezone.convert(post.inserted_at, Timex.Timezone.get("America/Chicago")), "{D} {Mshort} {YYYY}") |> Tuple.to_list |> List.last,
                               time: Timex.format(Timex.Timezone.convert(post.inserted_at, Timex.Timezone.get("America/Chicago")), "{h24}:{m}") |> Tuple.to_list |> List.last } end)
  end



  defp get_characters(user_id) do
    Kami.Accounts.get_characters(user_id)
    |> Enum.map(fn(c) -> %{name: c.name, family: c.family, approved: c.approved, user: c.user_id, xp: c.xp, bxp: c.bxp, image: Kami.Accounts.image_url(c)
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
