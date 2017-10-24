defmodule KamiWeb.ArchiveController do
  use KamiWeb, :controller

  alias Kami.World
  alias Kami.World.Location
  alias Kami.World.Post

  def index(conn, _params) do
    locations = World.list_locations_with_posts()
    render conn, "index.html", locations: locations
  end
  
  def show(conn, %{"loc" => loc}) do
    location = World.get_location_by_slug!(loc)
    posts = World.get_posts!(location.id)
    render conn, "show.html", loc: location, posts: posts
  end
end