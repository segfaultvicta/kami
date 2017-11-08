defmodule Kami.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kami.Accounts.User


  schema "users" do
    field :crypted_password, :string
    field :password, :string, virtual: true
    field :name, :string
    field :admin, :boolean
    field :last_location_id, :integer

    has_many :characters, Kami.Accounts.Character

    timestamps()
  end

  def validate_no_spaces(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, f ->
      case String.contains?(f, " ") do
        true -> [{field, options[:message] || "Can't contain spaces"}]
        false -> []
      end
    end)
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :crypted_password, :admin, :last_location_id])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> validate_no_spaces(:name)
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, ~w(password), [])
    |> validate_length(:password, min: 6)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :crypted_password, Comeonin.Pbkdf2.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
