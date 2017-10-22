defmodule KamiWeb.LocationController do
  use KamiWeb, :controller

  alias Kami.World
  alias Kami.World.Location

  def index(conn, _params) do
    locations = World.list_locations()
    render(conn, "index.html", locations: locations)
  end

  def new(conn, _params) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      changeset = World.change_location(%Location{})
      render(conn, "new.html", changeset: changeset)
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end

  def create(conn, %{"location" => location_params}) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      case World.create_location(location_params) do
        {:ok, location} ->
          conn
          |> put_flash(:info, "Location created successfully.")
          |> redirect(to: location_path(conn, :show, location))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end
  
  def show(conn, %{"id" => id, "loadroom" => "true"}) do
    # if the location is locked, we should error and redirect back to :show
    # if the location is IC and the user's character hasn't been marked as accepted yet, we should error and redirect back to :show
    # if the location here is an IC location, we should update the user's last_location_id
    location = World.get_location!(id)
    render(conn, "room.html", location_id: id)
  end
  
  def show(conn, %{"id" => id}) do
    location = World.get_location!(id)
    parent = case location.parent do
      nil ->
        false
      p ->
        %{name: p.name, id: p.id}
    end
    children = if Enum.count(location.children) > 0 do 
      Enum.map(location.children, fn(child) -> %{name: child.name, id: child.id} end)
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

  def delete(conn, %{"id" => id}) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      location = World.get_location!(id)
      {:ok, _location} = World.delete_location(location)

      conn
      |> put_flash(:info, "Location deleted successfully.")
      |> redirect(to: location_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end
end
