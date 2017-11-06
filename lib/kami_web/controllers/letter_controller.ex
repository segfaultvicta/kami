defmodule KamiWeb.LetterController do
  use KamiWeb, :controller

  alias Kami.World
  alias Kami.World.Letter

  def index(conn, _params) do
    letters = World.list_letters()
    render(conn, "index.html", letters: letters)
  end

  def new(conn, _params) do
    changeset = World.change_letter(%Letter{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"letter" => letter_params}) do
    case World.create_letter(letter_params) do
      {:ok, letter} ->
        conn
        |> put_flash(:info, "Letter created successfully.")
        |> redirect(to: letter_path(conn, :show, letter))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    letter = World.get_letter!(id)
    render(conn, "show.html", letter: letter)
  end

  def edit(conn, %{"id" => id}) do
    letter = World.get_letter!(id)
    changeset = World.change_letter(letter)
    render(conn, "edit.html", letter: letter, changeset: changeset)
  end

  def update(conn, %{"id" => id, "letter" => letter_params}) do
    letter = World.get_letter!(id)

    case World.update_letter(letter, letter_params) do
      {:ok, letter} ->
        conn
        |> put_flash(:info, "Letter updated successfully.")
        |> redirect(to: letter_path(conn, :show, letter))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", letter: letter, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    letter = World.get_letter!(id)
    {:ok, _letter} = World.delete_letter(letter)

    conn
    |> put_flash(:info, "Letter deleted successfully.")
    |> redirect(to: letter_path(conn, :index))
  end
end
