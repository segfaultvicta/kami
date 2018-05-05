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

  def handle_in("post", %{"author_slug" => slug, "ooc" => ooc, "narrative" => narr, "name" => name, "text" => text,
                          "roll" => roll, "image" => image}, socket) do
    name = if narr do "" else name end
    character = if narr do nil else Kami.Accounts.get_character_by_name!(slug) end
    {rolled, target, result} = if roll != "" do
      # at this point roll is going to be either "narr" or "idX" or one of the stats
      # if it's idX we want to
      # a) look up what that ID's name is
      # b) whether it's public
      # c) what its associated skill level is
      # if it's one of the stats we just want to look up the associated skill level
      # if it's narr we want to be enigmatic as fuck
      result = Enum.random(1..100)
      case roll do
        "narr" ->
          {"-=[*]=-", -1, result}
        "id1" ->
          {if character.id1_visible do character.id1 else "-=[*]=-" end, character.id1_pct, result}
        "id2" ->
          {if character.id2_visible do character.id2 else "-=[*]=-" end, character.id2_pct, result}
        "id3" ->
          {if character.id3_visible do character.id3 else "-=[*]=-" end, character.id3_pct, result}
        "id4" ->
          {if character.id4_visible do character.id4 else "-=[*]=-" end, character.id4_pct, result}
        "id5" ->
          {if character.id5_visible do character.id5 else "-=[*]=-" end, character.id5_pct, result}
        "id6" ->
          {if character.id6_visible do character.id6 else "-=[*]=-" end, character.id6_pct, result}
        _ ->
          value = Kami.Accounts.Character.get_value(character, roll)
          Logger.info("obtained value of #{value} for roll #{roll}")
          {String.capitalize(roll), Kami.Accounts.Character.get_value(character, roll), result}
      end
    else
      {"", 0, 0}
    end
    text = if ooc && text == "" do "\n" else HtmlSanitizeEx.strip_tags(text) end
    identities = if character != nil do Kami.Accounts.Character.serialise_public_identities(character) else "" end
    Kami.World.create_post(socket.assigns[:location], slug, %{ooc: ooc, narrative: narr, text: text, name: name, image: image,
                                                              rolled: rolled, target: target, result: result,
                                                              identities: identities})
    broadcast!(socket, "update_posts", %{posts: get_posts(socket.assigns[:location])})
    if not ooc and not Kami.World.is_ooc?(socket.assigns[:location]) and not narr and not socket.assigns[:admin] do
      Kami.Accounts.award_xp(character, Application.get_env(:kami, :xp_per_post), False)
    end
    {:reply, {:ok, %{characters: get_characters(socket.assigns[:user])}}, socket}
  end

  defp get_posts(location_id) do
    Kami.World.get_backfill!(location_id, Application.get_env(:kami, :posts_to_show))
    |> Enum.map(fn(post) ->  %{author_slug: post.author_slug, ooc: post.ooc, narrative: post.narrative,
                               name: post.name, text: post.text, rolled: post.rolled, target: post.target,
                               result: post.result, image: post.image, identities: post.identities,
                               date: Timex.format(Timex.Timezone.convert(post.inserted_at, Timex.Timezone.get("America/Chicago")), "{D} {Mshort} {YYYY}") |> Tuple.to_list |> List.last,
                               time: Timex.format(Timex.Timezone.convert(post.inserted_at, Timex.Timezone.get("America/Chicago")), "{h24}:{m}") |> Tuple.to_list |> List.last } end)
  end



  defp get_characters(user_id) do
    Kami.Accounts.get_characters(user_id)
    |> Enum.map(fn(c) -> %{name: c.name, family: c.family, approved: c.approved,
                           user: c.user_id, xp: c.xp, image: Kami.Accounts.image_url(c),
                           id1: v(c.id1), id1_pct: c.id1_pct, id2: v(c.id2), id2_pct: c.id2_pct, id3: v(c.id3), id3_pct: c.id3_pct,
                           id4: v(c.id4), id4_pct: c.id4_pct, id5: v(c.id5), id5_pct: c.id5_pct, id6: v(c.id6), id6_pct: c.id6_pct,
                           favourite: c.favourite, guru: c.guru, mentor: c.mentor, responsibility: c.responsibility, protege: c.protege,
                           fitness: Kami.Accounts.Character.get_value(c, "fitness"), dodge: Kami.Accounts.Character.get_value(c, "dodge"),
                           status: Kami.Accounts.Character.get_value(c, "status"), pursuit: Kami.Accounts.Character.get_value(c, "pursuit"),
                           knowledge: Kami.Accounts.Character.get_value(c, "knowledge"), lie: Kami.Accounts.Character.get_value(c, "lie"),
                           notice: Kami.Accounts.Character.get_value(c, "notice"), secrecy: Kami.Accounts.Character.get_value(c, "secrecy"),
                           connect: Kami.Accounts.Character.get_value(c, "connect"), struggle: Kami.Accounts.Character.get_value(c, "struggle"),
       } end)
  end

  defp v(i) do
    if is_nil(i) do
      ""
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
