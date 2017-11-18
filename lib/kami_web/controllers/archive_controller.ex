defmodule KamiWeb.ArchiveController do
  use KamiWeb, :controller

  alias Kami.World

  def index(conn, _params) do
    locations = World.list_locations_with_posts()
    render conn, "index.html", locations: locations
  end

  def show(conn, %{"loc" => loc, "day" => day}) do
    location = World.get_location_by_slug!(loc)
    [y, m, d] = String.split(day, "-")
    posts = World.get_posts!(location.id)
    |> Enum.filter(fn(p) -> (p.inserted_at.year == String.to_integer(y)) and (p.inserted_at.month == String.to_integer(m)) and (p.inserted_at.day == String.to_integer(d)) end)
    render conn, "show.html", loc: location, day: day, posts: posts
  end

  def show(conn, %{"loc" => loc}) do
    location = World.get_location_by_slug!(loc)
    days = World.get_posts!(location.id)
      |> Enum.map(fn(post) -> Integer.to_string(post.inserted_at.year) <> "-" <> Integer.to_string(post.inserted_at.month) <> "-" <> Integer.to_string(post.inserted_at.day) end)
      |> Enum.uniq
    render conn, "daylocation.html", loc: location, days: days
  end
end
