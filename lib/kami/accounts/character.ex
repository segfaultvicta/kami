defmodule Kami.Accounts.Character do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kami.Accounts.Character

  use Arc.Ecto.Schema


  schema "characters" do
    field :name, :string
    field :public_description, :string
    field :bxp_this_week, :float
    field :approved, :boolean, default: false
    field :total_xp, :float
    field :bxp, :float
    field :image, Kami.Avatar.Type
    field :xp, :float
    field :family, :string
    field :total_spent_xp, :integer
    field :patreon, :boolean, default: false
    field :gm_notes, :string
    field :secret_gm_notes, :string
    field :cabal, :string
    field :concept, :string
    field :objectives, :string
    field :rage, :string
    field :noble, :string
    field :fear, :string
    field :helplessness_hardened, :integer
    field :helplessness_failures, :integer
    field :isolation_hardened, :integer
    field :isolation_failures, :integer
    field :self_hardened, :integer
    field :self_failures, :integer
    field :unnatural_hardened, :integer
    field :unnatural_failures, :integer
    field :violence_hardened, :integer
    field :violence_failures, :integer
    field :favourite, :integer
    field :guru, :integer
    field :mentor, :integer
    field :responsibility, :integer
    field :protege, :integer
    field :id1, :string
    field :id1_pct, :integer
    field :id1_desc, :string
    field :id1_visible, :boolean, default: false
    field :id2, :string
    field :id2_pct, :integer
    field :id2_desc, :string
    field :id2_visible, :boolean, default: false
    field :id3, :string
    field :id3_pct, :integer
    field :id3_desc, :string
    field :id3_visible, :boolean, default: false
    field :id4, :string
    field :id4_pct, :integer
    field :id4_desc, :string
    field :id4_visible, :boolean, default: false
    field :id5, :string
    field :id5_pct, :integer
    field :id5_desc, :string
    field :id5_visible, :boolean, default: false
    field :id6, :string
    field :id6_pct, :integer
    field :id6_desc, :string
    field :id6_visible, :boolean, default: false


    belongs_to :user, Kami.Accounts.User

    has_many :letters_received, Kami.World.Letter, foreign_key: :recipient_id
    has_many :letters_written, Kami.World.Letter, foreign_key: :author_id

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
  def changeset(%Character{} = character, attrs) do
    character
    |> cast(attrs, [:name, :family, :approved, :public_description, :bxp, :bxp_this_week,
                    :xp, :total_xp, :total_spent_xp, :patreon, :gm_notes, :secret_gm_notes,
                    :cabal, :concept, :objectives, :rage, :noble, :fear,
                    :favourite, :guru, :mentor, :responsibility, :protege,
                    :helplessness_hardened, :helplessness_failures,
                    :isolation_hardened, :isolation_failures,
                    :self_hardened, :self_failures,
                    :violence_hardened, :violence_failures,
                    :unnatural_hardened, :unnatural_failures,
                    :id1, :id1_pct, :id1_desc, :id1_visible,
                    :id2, :id2_pct, :id2_desc, :id2_visible,
                    :id3, :id3_pct, :id3_desc, :id3_visible,
                    :id4, :id4_pct, :id4_desc, :id4_visible,
                    :id5, :id5_pct, :id5_desc, :id5_visible,
                    :id6, :id6_pct, :id6_desc, :id6_visible,
                    ])
    |> validate_required([:name, :approved, :family])
    |> validate_no_spaces(:name)
  end

  def description_changeset(%Character{} = character, attrs) do
    character
    |> cast(attrs, [:public_description])
    |> validate_required([:public_description])
  end

  def pre_approval_changeset(%Character{} = character, attrs) do
    character
    |> cast(attrs, [:name, :family, :public_description,
                    :cabal, :concept, :objectives, :rage, :noble, :fear,
                    :favourite, :guru, :mentor, :responsibility, :protege,
                    :helplessness_hardened, :helplessness_failures,
                    :isolation_hardened, :isolation_failures,
                    :self_hardened, :self_failures,
                    :violence_hardened, :violence_failures,
                    :unnatural_hardened, :unnatural_failures,
                    :id1, :id1_pct, :id1_desc, :id1_visible,
                    :id2, :id2_pct, :id2_desc, :id2_visible,
                    :id3, :id3_pct, :id3_desc, :id3_visible,
                    :id4, :id4_pct, :id4_desc, :id4_visible,
                    :id5, :id5_pct, :id5_desc, :id5_visible,
                    :id6, :id6_pct, :id6_desc, :id6_visible,
                    ])
    |> validate_required([:name, :family])
    |> validate_no_spaces(:name)
  end

  @doc false
  def stat_changeset(%Character{} = character, attrs) do
    character
    |> cast(attrs, [:favourite, :guru, :mentor, :responsibility, :protege,
                    :id1_pct, :id2_pct, :id3_pct, :id4_pct, :id5_pct, :id6_pct,
                    :bxp, :xp, :bxp_this_week, :total_xp, :total_spent_xp])
  end

  def image_changeset(%Character{} = character, attrs \\ :invalid) do
    character
    |> cast_attachments(attrs, [:image])
    |> validate_required([:image])
  end

  def serialise_public_identities(character) do
    "\n" <>
    if character.id1_pct > 0 and character.id1_visible do character.id1 <> "\n" else "" end <>
    if character.id2_pct > 0 and character.id2_visible do character.id2 <> "\n" else "" end <>
    if character.id3_pct > 0 and character.id3_visible do character.id3 <> "\n" else "" end <>
    if character.id4_pct > 0 and character.id4_visible do character.id4 <> "\n" else "" end <>
    if character.id5_pct > 0 and character.id5_visible do character.id5 <> "\n" else "" end <>
    if character.id6_pct > 0 and character.id6_visible do character.id6 <> "\n" else "" end
  end

  def get_value(character, key) do
    Map.get(character, String.to_existing_atom(key))
  end
end
