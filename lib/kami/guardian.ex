defmodule Kami.Guardian do
  use Guardian, otp_app: :kami
  
  def subject_for_token(user = %Kami.Accounts.User{}, _claims) do
    {:ok, "User:#{user.id}"}
  end
  
  def subject_for_token(_, _) do
    {:error, "Unknown resource"}
  end
  
  def resource_from_claims(claims) do
    {:ok, find_resource(claims["sub"])}
  end
  
  def resource_from_claims(_claims) do
    {:error, "Unknown resource"}
  end
  
  def find_resource("User:" <> id) do
    Kami.Accounts.get(id)
  end

end