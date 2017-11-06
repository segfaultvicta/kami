defmodule Kami.World.Letter do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kami.World.Letter


  schema "letters" do
    field :description, :string
    field :text, :string
    field :to_postmaster, :boolean, default: false
    belongs_to :sender, Kami.Accounts.Character
    belongs_to :author, Kami.Accounts.Character
    belongs_to :recipient, Kami.Accounts.Character

    timestamps()
  end

  @doc false
  def changeset(%Letter{} = letter, attrs) do
    letter
    |> cast(attrs, [:text, :description, :to_postmaster])
    |> validate_required([:text, :description])
  end
end
