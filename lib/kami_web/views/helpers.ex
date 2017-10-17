defmodule KamiWeb.ViewHelpers do
  def current_user(conn), do: Kami.Guardian.Plug.current_resource(conn)
  def logged_in?(conn), do: Kami.Guardian.Plug.authenticated?(conn)
end