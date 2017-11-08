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
      user = Kami.Guardian.Plug.current_resource(conn)
      case Accounts.create_character(user, character_params) do
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
    character = Map.put(character, :image_url, Kami.Accounts.image_url(character))
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
        Accounts.get_character!(cid)
    end
    character = Map.put(character, :image_url, Kami.Accounts.image_url(character))
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
        if character.approved do
          changeset = Accounts.change_character_description(character)
          render(conn, "edit_description.html", character: character, changeset: changeset)
        else
          changeset = Accounts.change_before_approval(character)
          render(conn, "edit_pre_approval.html", character: character, changeset: changeset)
        end
      else
        conn
        |> put_flash(:error, "Unauthorised action! You can't edit someone else's character sheet.")
        |> redirect(to: "/")
      end
    end
  end

  def new_image(conn, %{"id" => id}) do
    user_id = Kami.Guardian.Plug.current_resource(conn).id
    character = case Integer.parse(id) do
      :error ->
        Accounts.get_character_by_name!(id)
      {cid, _} ->
        Accounts.get_character!(cid)
    end
    if user_id == character.user_id do
      changeset = Accounts.change_image(character)
      render(conn, "new_image.html", character: character, changeset: changeset)
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end

  def award(conn, %{"id" => id, "amt" => amount}) do
    if Kami.Guardian.Plug.current_resource(conn).admin do
      character = case Integer.parse(id) do
        :error ->
          Accounts.get_character_by_name!(id)
        {cid, _} ->
          Accounts.get_character!(cid)
      end
      amt = cond do
        amount == "full" -> 1.0
        amount == "half" -> 0.5
        amount == "quarter" -> 0.25
        amount == "tenth" -> 0.1
        true -> 0
      end

      case Accounts.award_xp(character, amt) do
        {:ok, character} ->
          conn
          |> put_flash(:info, "Awarded #{amt} XP!")
          |> redirect(to: character_path(conn, :show, character))
        {:error, _ } ->
          conn
          |> put_flash(:error, "Something went wrong trying to award XP to that character.")
          |> redirect(to: character_path(conn, :show, character))
      end
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
    end
  end



  def update_image(conn, %{"id" => id, "character" => params}) do
    user_id = Kami.Guardian.Plug.current_resource(conn).id
    character = case Integer.parse(id) do
      :error ->
        Accounts.get_character_by_name!(id)
      {cid, _} ->
        Accounts.get_character!(cid)
    end
    if user_id == character.user_id do
      case Accounts.update_image(character, params) do
        {:ok, character} ->
          conn
          |> put_flash(:info, "Image uploaded!")
          |> redirect(to: character_path(conn, :show, character))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new_image.html", character: character, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "Unauthorised action!")
      |> redirect(to: "/")
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
        if character.approved do
          case Accounts.update_character_description(character, character_params) do
            {:ok, character} ->
              conn
              |> put_flash(:info, "Character updated successfully.")
              |> redirect(to: character_path(conn, :show, character))
            {:error, %Ecto.Changeset{} = changeset} ->
              render(conn, "edit_description.html", character: character, changeset: changeset)
          end
        else
          case Accounts.update_pre_approval(character, character_params) do
            {:ok, character} ->
              conn
              |> put_flash(:info, "Character updated successfully.")
              |> redirect(to: character_path(conn, :show, character))
            {:error, %Ecto.Changeset{} = changeset} ->
              render(conn, "edit_pre_approval.html", character: character, changeset: changeset)
          end
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
