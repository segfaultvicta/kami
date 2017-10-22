defmodule Kami.AuthErrorHandler do
  def auth_error(conn, {type, reason}, _opts) do
    body = Poison.encode!(%{message: to_string(type)})
    Plug.Conn.send_resp(conn, 401, body)
  end
end