defmodule KamiWeb.LocationControllerTest do
  use KamiWeb.ConnCase

  alias Kami.World

  @create_attrs %{description: "some description", locked: true, name: "some name", ooc: true}
  @update_attrs %{description: "some updated description", locked: false, name: "some updated name", ooc: false}
  @invalid_attrs %{description: nil, locked: nil, name: nil, ooc: nil}

  def fixture(:location) do
    {:ok, location} = World.create_location(@create_attrs)
    location
  end

  describe "index" do
    test "lists all locations", %{conn: conn} do
      conn = get conn, location_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Locations"
    end
  end

  describe "new location" do
    test "renders form", %{conn: conn} do
      conn = get conn, location_path(conn, :new)
      assert html_response(conn, 200) =~ "New Location"
    end
  end

  describe "create location" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, location_path(conn, :create), location: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == location_path(conn, :show, id)

      conn = get conn, location_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Location"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, location_path(conn, :create), location: @invalid_attrs
      assert html_response(conn, 200) =~ "New Location"
    end
  end

  describe "edit location" do
    setup [:create_location]

    test "renders form for editing chosen location", %{conn: conn, location: location} do
      conn = get conn, location_path(conn, :edit, location)
      assert html_response(conn, 200) =~ "Edit Location"
    end
  end

  describe "update location" do
    setup [:create_location]

    test "redirects when data is valid", %{conn: conn, location: location} do
      conn = put conn, location_path(conn, :update, location), location: @update_attrs
      assert redirected_to(conn) == location_path(conn, :show, location)

      conn = get conn, location_path(conn, :show, location)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, location: location} do
      conn = put conn, location_path(conn, :update, location), location: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Location"
    end
  end

  describe "delete location" do
    setup [:create_location]

    test "deletes chosen location", %{conn: conn, location: location} do
      conn = delete conn, location_path(conn, :delete, location)
      assert redirected_to(conn) == location_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, location_path(conn, :show, location)
      end
    end
  end

  defp create_location(_) do
    location = fixture(:location)
    {:ok, location: location}
  end
end
