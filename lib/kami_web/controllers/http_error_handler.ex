defmodule KamiWeb.HttpErrorHandler do
  use KamiWeb, :controller

  def auth_error(conn, {type, reason}, _opts) do
    conn
    |> put_flash(:error, "Authentication Error: #{type} - #{reason}")
    |> redirect(to: session_path(conn, :new))
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:info, "You must be signed in to access this page!")
    |> redirect(to: session_path(conn, :new))
  end
  
  def unauthorized(conn, _params) do
    conn
    |> put_flash(:error, "You are not authorised to view this page!")
    |> redirect(to: session_path(conn, :new))
  end
end