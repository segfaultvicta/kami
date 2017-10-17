defmodule KamiWeb.CharacterController do
  use KamiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
  
  def show(conn, %{"chara" => chara}) do
    render conn, "show.html", chara: chara
  end
end