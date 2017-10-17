defmodule KamiWeb.ArchiveController do
  use KamiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
  
  def show(conn, %{"loc" => loc}) do
    render conn, "show.html", loc: loc
  end
end