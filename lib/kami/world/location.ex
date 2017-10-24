defmodule Kami.World.Location.NameSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end

defmodule Kami.World.Location do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kami.World.Location
  alias Kami.World.Location.NameSlug

  @derive {Phoenix.Param, key: :slug}
  schema "locations" do
    field :description, :string
    field :locked, :boolean, default: false
    field :name, :string
    field :ooc, :boolean, default: false
    
    field :slug, NameSlug.Type
    
    has_many :children, Kami.World.Location, foreign_key: :parent_id
    has_many :posts, Kami.World.Post, foreign_key: :location_id
    belongs_to :parent, Kami.World.Location

    timestamps()
  end

  @doc false
  def changeset(%Location{} = location, attrs) do
    location
    |> cast(attrs, [:name, :description, :ooc, :locked])
    |> validate_required([:name, :description])
    |> unique_constraint(:name)
    |> NameSlug.maybe_generate_slug
    |> NameSlug.unique_constraint
  end
end
