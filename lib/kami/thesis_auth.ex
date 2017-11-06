defmodule Kami.ThesisAuth do
  @moduledoc """
  Contains functions for handling Thesis authorization.
  """

  @behaviour Thesis.Auth

  def page_is_editable?(conn) do
    # Editable by the world
    not (~w(locations archive characters users) |> Enum.any?(fn(x) -> String.contains?(conn.request_path, x) end))


    #true

    # Or use your own auth strategy. Learn more:
    # https://github.com/infinitered/thesis-phoenix#authorization
  end

  def user_can_edit?(conn) do
    if Kami.Guardian.Plug.authenticated?(conn) do
      if Kami.Guardian.Plug.current_resource(conn).admin do
        true
      else
        false
      end
    else
      false
    end
  end

end
