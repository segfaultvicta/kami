defmodule KamiWeb.UserController do
  use KamiWeb, :controller
  alias Kami.Accounts
  alias Kami.Accounts.User

  def index(conn, _params) do
    users = Kami.Repo.all(User)
    render conn, "index.html", users: users
  end
  
  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render conn, "new.html", changeset: changeset
  end
  
  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> Kami.Auth.login(user)
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end
end