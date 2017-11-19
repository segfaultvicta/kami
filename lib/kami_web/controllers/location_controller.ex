defmodule KamiWeb.LocationController do
  use KamiWeb, :controller

  require Logger

  alias Kami.World

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
    {location, _} = case Integer.parse(id) do
      :error ->
        {World.get_location_by_slug!(id), id}
      {lid, _} ->
        {World.get_location!(lid), nil}
    end
    if location.locked do
      conn
      |> put_flash(:error, "This location cannot be entered at this time.")
      |> redirect(to: location_path(conn, :show, location))
    else
      user = Kami.Guardian.Plug.current_resource(conn)
      if user.admin or location.ooc or Kami.Accounts.get_PC_for(user.id).approved do
        Kami.Accounts.update_user(user, %{last_location_id: location.id})
        conn
        |> put_resp_cookie("location-id", to_string(location.id), [max_age: 20, http_only: false])
        |> put_resp_cookie("user-id", to_string(user.id), [max_age: 20, http_only: false])
        |> put_resp_cookie("elm-key", Base.encode64(:crypto.hash(:sha512, to_string(location.id) <> "." <> to_string(user.id) <> "." <> Application.get_env(:kami, :elm_secret))), [max_age: 20, http_only: false])
        |> render("room.html")
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
      location = case Integer.parse(id) do
        :error ->
          World.get_location_by_slug!(id)
        {lid, _} ->
          World.get_location!(lid)
      end
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
      location = case Integer.parse(id) do
        :error ->
          World.get_location_by_slug!(id)
        {lid, _} ->
          World.get_location!(lid)
      end
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
