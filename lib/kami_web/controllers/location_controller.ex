defmodule KamiWeb.LocationController do
  use KamiWeb, :controller

  alias Kami.World
  alias Kami.World.Location

  def index(conn, _params) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      locations = World.list_locations()
      render(conn, "index.html", locations: locations)
    else
      conn
      |> redirect(to: location_path(conn, :show, "lobby"))
    end
  end
  
  def show(conn, %{"id" => id, "loadroom" => "true"}) do
    {location, slug} = case Integer.parse(id) do
      :error ->
        {World.get_location_by_slug!(id), id}
      {lid, _} ->
        {World.get_location!(lid), nil}
    end
    slug = if slug == nil do
      location.slug
    else
      slug
    end
    if location.locked do
      conn
      |> put_flash(:error, "This location cannot be entered at this time.")
      |> redirect(to: location_path(conn, :show, location))
    else
      user = Kami.Guardian.Plug.current_resource(conn)
      if user.admin or location.ooc or Kami.Accounts.get_PC_for(user.id).approved do
        Kami.Accounts.update_user(user, %{last_location_id: location.id})
        render(conn, "room.html", location_id: id)
      else
        conn
        |> put_flash(:error, "You cannot enter IC locations until your character has been marked as approved.")
        |> redirect(to: location_path(conn, :show, location))
      end
    end
  end
  
  def show(conn, %{"id" => id}) do
    location = case Integer.parse(id) do
      :error ->
        World.get_location_by_slug!(id)
      {lid, _} ->
        World.get_location!(lid)
    end
    parent = case location.parent do
      nil ->
        false
      p ->
        %{name: p.name, id: p.id, slug: p.slug}
    end
    children = if Enum.count(location.children) > 0 do 
      Enum.map(location.children, fn(child) -> %{name: child.name, id: child.id, slug: child.slug} end)
    else
      false
    end
    render(conn, "show.html", location: location, parent: parent, children: children)
  end

  def edit(conn, %{"id" => id}) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      location = World.get_location!(id)
      changeset = World.change_location(location)
      render(conn, "edit.html", location: location, changeset: changeset)
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      location = World.get_location!(id)
      case World.update_location(location, location_params) do
        {:ok, location} ->
          conn
          |> put_flash(:info, "Location updated successfully.")
          |> redirect(to: location_path(conn, :show, location))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", location: location, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end
end
