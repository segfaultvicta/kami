defmodule KamiWeb.CharacterController do
  use KamiWeb, :controller

  alias Kami.Accounts
  alias Kami.Accounts.Character

  def index(conn, _params) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      characters = Accounts.list_characters()
      render(conn, "index.html", characters: characters)
    else
      conn
      |> redirect(to: character_path(conn, :show, Accounts.get_PC_for(Kami.Guardian.Plug.current_resource(conn).id)))
    end
  end

  def new(conn, _params) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      changeset = Accounts.change_character(%Character{})
      render(conn, "new.html", changeset: changeset)
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end

  def create(conn, %{"character" => character_params}) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      case Accounts.create_character(character_params) do
        {:ok, character} ->
          conn
          |> put_flash(:info, "Character created successfully.")
          |> redirect(to: character_path(conn, :show, character))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end

  def show(conn, %{"id" => id}) when is_integer(id) do
    character = Accounts.get_character!(id)
    user = Kami.Guardian.Plug.current_resource(conn)
    if user.admin or character.user_id == user.id do
      show_full_character(conn, character, user.admin)
    else
      show_public_character(conn, character)
    end
  end
  
  def show(conn, %{"id" => id}) do
    character = case Integer.parse(id) do
      :error ->
        Accounts.get_character_by_name!(id)
      {cid, _} ->
        Accounts.get_character!(id)
    end
    user = Kami.Guardian.Plug.current_resource(conn)
    if user.admin or character.user_id == user.id do
      show_full_character(conn, character, user.admin)
    else
      show_public_character(conn, character)
    end
  end
  
  def show_public_character(conn, character) do
    render(conn, "show_public.html", character: character)
  end
  
  def show_full_character(conn, character, as_admin) do
    if not character.approved do
      conn 
      |> put_flash(:error, "Note: Character is not currently in an approved state.")
      |> render("show.html", character: character, as_admin: as_admin)
    else
      render(conn, "show.html", character: character, as_admin: as_admin)
    end
  end

  def edit(conn, %{"id" => id}) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      character = Accounts.get_character!(id)
      changeset = Accounts.change_character(character)
      render(conn, "edit.html", character: character, changeset: changeset)
    else
      user_id = Kami.Guardian.Plug.current_resource(conn).id
      character = Accounts.get_character!(id)
      if user_id == character.user_id do 
        changeset = Accounts.change_character_description(character)
        render(conn, "edit_description.html", character: character, changeset: changeset)
      else
        conn
        |> put_flash(:error, "Unauthorised action! You can't edit someone else's character sheet.")
        |> redirect(to: "/")
      end
    end
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      character = Accounts.get_character!(id)

      case Accounts.update_character(character, character_params) do
        {:ok, character} ->
          conn
          |> put_flash(:info, "Character updated successfully.")
          |> redirect(to: character_path(conn, :show, character))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", character: character, changeset: changeset)
      end
    else
      user_id = Kami.Guardian.Plug.current_resource(conn).id
      character = Accounts.get_character!(id)
      if user_id == character.user_id do
        case Accounts.update_character_description(character, character_params) do
          {:ok, character} ->
            conn
            |> put_flash(:info, "Character updated successfully.")
            |> redirect(to: character_path(conn, :show, character))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit_description.html", character: character, changeset: changeset)
        end
      else
        conn
        |> put_flash(:error, "Unauthorised action!")
        |> redirect(to: "/")
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      character = Accounts.get_character!(id)
      {:ok, _character} = Accounts.delete_character(character)

      conn
      |> put_flash(:info, "Character deleted successfully.")
      |> redirect(to: character_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end
end
