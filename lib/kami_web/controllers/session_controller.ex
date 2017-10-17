defmodule KamiWeb.SessionController do
  use KamiWeb, :controller

  def new(conn, _) do
    render conn, "new.html"
  end
  
  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case Kami.Auth.login_by_username_and_password(conn, user, pass, repo: Kami.Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Logged in!")
        |> redirect(to: user_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Wrong username/password")
        |> render("new.html")
    end
  end
  
  def delete(conn, _) do
    conn
    |> Kami.Guardian.Plug.sign_out
    |> redirect(to: "/")
  end
end