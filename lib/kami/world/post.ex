defmodule Kami.World.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kami.World.Post


  schema "posts" do
    field :diceroll, :boolean, default: false
    field :die_size, :integer
    field :glory, :integer
    field :honor, :integer
    field :image, :string
    field :name, :string
    field :narrative, :boolean, default: false
    field :ooc, :boolean, default: false
    field :results, {:array, :integer}
    field :ring_name, :string
    field :ring_value, :integer
    field :skill_name, :string
    field :skillroll, :boolean, default: false
    field :status, :integer
    field :text, :string
    field :author_slug, :string
    field :identities, :string

    belongs_to :location, Kami.World.Location

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:name, :image, :text, :honor, :glory, :status, :ooc, :narrative, :diceroll, :skillroll, :results, :ring_name, :skill_name, :ring_value, :die_size, :identities])
    |> validate_required([:ooc, :narrative])
  end
end
