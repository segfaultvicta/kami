defmodule Kami.Auth do
  import Comeonin.Pbkdf2, only: [checkpw: 2, dummy_checkpw: 0]
  import Plug.Conn
  
  def login(conn, user) do
    conn
    |> Kami.Guardian.Plug.sign_in(user)
  end
  
  def login_by_username_and_password(conn, user, pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Kami.Accounts.User, name: user)
    
    cond do
      user && checkpw(pass, user.crypted_password) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_fount, conn}
    end
  end
end