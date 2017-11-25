defmodule Kami.Actors.Activity do
  require Logger

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get() do
    Agent.get(__MODULE__, fn(state) ->
      Enum.map(state, fn({_, %{location: location, name: name, ts: timestamp}}) ->
        %{location: location, name: name, real_ts: Timex.to_unix(timestamp), timestamp: Timex.Format.DateTime.Formatters.Relative.format!(timestamp, "{relative}")}
      end)
    end)
  end

  def get(user) do
    Agent.get(__MODULE__, fn(state) ->
      r = state[user]
      if r == nil do %{name: "Unknown", location: "Unknown", ts: Timex.now} else r end
    end)
  end

  def update(user, nil) do
    Agent.update(__MODULE__,
      fn state ->
        Map.delete(state, user)
    end)
  end

  def update(user, new_list) do
    Agent.update(__MODULE__,
      fn state ->
        Map.put(state, user, new_list)
      end)
  end

  def join(user, location) do
    fc = Kami.Accounts.get_characters(user) |> Enum.at(0)
    name = if fc == nil do "Unknown" else fc.name end
    loc = Kami.World.get_location!(location)
    update(user, %{get(user) | name: name, location: loc.name })
  end

  def ping(user) do
    update(user, %{get(user) | ts: Timex.now})
  end

  def part(user) do
    update(user, nil)
  end



end
