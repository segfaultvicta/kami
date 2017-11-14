defmodule KamiWeb.ViewHelpers do
  def current_user(conn), do: Kami.Guardian.Plug.current_resource(conn)
  def logged_in?(conn), do: Kami.Guardian.Plug.authenticated?(conn)
  def as_admin?(conn) do
    if logged_in?(conn) do
      Kami.Guardian.Plug.current_resource(conn).admin
    else
      false
    end
  end
  def last_location(conn) do
    if logged_in?(conn) do
      case Kami.Guardian.Plug.current_resource(conn).last_location_id do
        nil ->
          false
        1 ->
          false
        llid ->
          Kami.World.get_location!(llid)
      end
    end
  end
  def characters_link_name(conn) do
    if logged_in?(conn) do
      user = Kami.Guardian.Plug.current_resource(conn)
      if user.admin do
        "Characters"
      else
        Kami.Accounts.get_PC_for(user.id).name
      end
    else
      false
    end
  end
  def t(text) when is_nil(text) do "" end
  def t(text) do
    Phoenix.HTML.Format.text_to_html(text, [wrapper_tag: :span])
  end
end
