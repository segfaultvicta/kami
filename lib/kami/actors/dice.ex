defmodule Kami.Actors.Dice do
  def start_link do
    Agent.start_link(fn -> %{1 => [%{die_id: "[narrative]-1-00:44-6150", enum: 1, timestamp: DateTime.utc_now()},
                                   %{die_id: "[narrative]-2-00:44-6150", enum: 2, timestamp: DateTime.utc_now()}]} end, name: __MODULE__)
    #Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get(room) do
    dice = Agent.get(__MODULE__, fn(state) -> state[room] end)
    if is_nil(dice) do [] else dice end
  end

  def trigger(id, ts, location) do
    curr_dice = get(location)
    new_dice = if Enum.any?(curr_dice, fn(die) -> die.die_id == id end) do
      die = Enum.find(curr_dice, 0, fn(die) -> die.die_id == id end)
      new_die = case die.enum do
        0 -> %{die_id: die.die_id, enum: 1, timestamp: ts}
        1 -> %{die_id: die.die_id, enum: 2, timestamp: ts}
        2 -> %{die_id: die.die_id, enum: 0, timestamp: ts}
      end
      Enum.reject(curr_dice, fn(die) -> die.die_id == id end) ++ [new_die]
    else
      curr_dice ++ [%{die_id: id, enum: 1, timestamp: ts}]
    end

    new_dice = filter_old_dice(new_dice, ts)
    Agent.update(__MODULE__,
      fn state ->
        Map.put(state, location, new_dice)
      end)
  end

  defp filter_old_dice(dice, ts) do
    Enum.reject(dice, fn(die) ->
      die.enum == 0 || DateTime.diff(ts, die.timestamp) > Application.get_env(:kami, :dice_lifetime)
    end)
  end
end
