defmodule KamiWeb.ArchiveController do
  use KamiWeb, :controller
  use Timex

  alias Kami.World

  def index(conn, _params) do
    locations = World.list_locations_with_posts()
    render conn, "index.html", locations: locations
  end

  def show(conn, %{"loc" => loc, "day" => day}) do
    location = World.get_location_by_slug!(loc)
    [y, m, d] = String.split(day, "-")
    start = Timex.to_datetime({String.to_integer(y), String.to_integer(m), String.to_integer(d)}, "America/Chicago")
    finish = Timex.shift(start, days: 1)
    posts = World.get_posts!(location.id)
    |> Enum.filter(fn(p) ->
      Timex.to_datetime(p.inserted_at) |> Timex.between?(start, finish, [inclusive: true])
    end)
    render conn, "show.html", loc: location, day: day, posts: posts
  end

  def show(conn, %{"loc" => loc}) do
    location = World.get_location_by_slug!(loc)
    days = World.get_posts!(location.id)
      |> Enum.map(fn(post) ->
        Timex.to_datetime(post.inserted_at) |> Timex.Timezone.convert("America/Chicago") |> Timex.format!("{YYYY}-{M}-{D}")
      end)
      |> Enum.uniq
    render conn, "daylocation.html", loc: location, days: days
  end
end
