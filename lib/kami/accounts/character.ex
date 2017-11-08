defmodule Kami.Accounts.Character do
  use Ecto.Schema
  import Ecto.Changeset
  alias Kami.Accounts.Character

  use Arc.Ecto.Schema


  schema "characters" do
    field :strife, :integer
    field :school, :string
    field :air, :integer
    field :skill_melee, :integer
    field :skill_sentiment, :integer
    field :skill_courtesy, :integer
    field :name, :string
    field :public_description, :string
    field :ninjo, :string
    field :skill_survival, :integer
    field :skill_smithing, :integer
    field :questions, :string
    field :skill_government, :integer
    field :outburst, :string
    field :skill_games, :integer
    field :skill_performance, :integer
    field :adversities, :string
    field :armor, :string
    field :techniques, :string
    field :fire, :integer
    field :skill_skullduggery, :integer
    field :skill_aesthetics, :integer
    field :bxp_this_week, :float
    field :approved, :boolean, default: false
    field :skill_meditation, :integer
    field :total_xp, :float
    field :bxp, :float
    field :skill_medicine, :integer
    field :skill_labor, :integer
    field :skill_theology, :integer
    field :passions, :string
    field :skill_design, :integer
    field :skill_culture, :integer
    field :distinctions, :string
    field :image, Kami.Avatar.Type
    field :giri, :string
    field :xp, :float
    field :weapons, :string
    field :honor, :integer
    field :skill_iaijutsu, :integer
    field :skill_fitness, :integer
    field :clan, :string
    field :skill_ranged, :integer
    field :void, :integer
    field :anxieties, :string
    field :skill_composition, :integer
    field :water, :integer
    field :skill_command, :integer
    field :family, :string
    field :school_rank, :integer
    field :skill_unarmed, :integer
    field :skill_seafaring, :integer
    field :earth, :integer
    field :glory, :integer
    field :skill_commerce, :integer
    field :status, :integer
    field :skill_tactics, :integer
    field :void_points, :integer
    field :titles, :string
    field :total_spent_xp, :integer
    field :patreon, :boolean, default: false
    field :gm_notes, :string
    field :secret_gm_notes, :string


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
    |> cast(attrs, [:name, :clan, :family, :school, :school_rank, :honor, :glory, :status, :strife, :approved, :void_points,
                    :air, :earth, :fire, :water, :void, :skill_aesthetics, :skill_composition, :skill_design, :skill_smithing,
                    :skill_fitness, :skill_iaijutsu, :skill_melee, :skill_ranged, :skill_unarmed, :skill_meditation, :skill_tactics,
                    :skill_command, :skill_courtesy, :skill_games, :skill_performance, :skill_culture, :skill_government, :skill_sentiment,
                    :skill_theology, :skill_medicine, :skill_commerce, :skill_labor, :skill_seafaring, :skill_skullduggery, :skill_survival,
                    :ninjo, :giri, :titles, :distinctions, :adversities, :passions, :anxieties, :outburst, :weapons, :armor, :techniques,
                    :questions, :public_description, :bxp, :bxp_this_week, :xp, :total_xp, :total_spent_xp, :patreon, :gm_notes, :secret_gm_notes])
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
    |> cast(attrs, [:name, :clan, :family, :school, :school_rank, :honor, :glory, :status, :air, :earth, :fire, :water, :void, :skill_aesthetics, :skill_composition, :skill_design, :skill_smithing, :skill_fitness, :skill_iaijutsu, :skill_melee, :skill_ranged, :skill_unarmed, :skill_meditation, :skill_tactics, :skill_command, :skill_courtesy, :skill_games, :skill_performance, :skill_culture, :skill_government, :skill_sentiment, :skill_theology, :skill_medicine, :skill_commerce, :skill_labor, :skill_seafaring, :skill_skullduggery, :skill_survival, :ninjo, :giri, :titles, :distinctions, :adversities, :passions, :anxieties, :outburst, :weapons, :armor, :techniques, :questions, :public_description])
    |> validate_required([:name, :family])
    |> validate_no_spaces(:name)
  end

  @doc false
  def stat_changeset(%Character{} = character, attrs) do
    character
    |> cast(attrs, [:strife, :void_points, :air, :earth, :fire, :water, :void, :skill_aesthetics, :skill_composition, :skill_design, :skill_smithing, :skill_fitness, :skill_iaijutsu, :skill_melee, :skill_ranged, :skill_unarmed, :skill_meditation, :skill_tactics, :skill_command, :skill_courtesy, :skill_games, :skill_performance, :skill_culture, :skill_government, :skill_sentiment, :skill_theology, :skill_medicine, :skill_commerce, :skill_labor, :skill_seafaring, :skill_skullduggery, :skill_survival, :bxp, :xp, :bxp_this_week, :total_xp, :total_spent_xp])
  end

  def image_changeset(%Character{} = character, attrs \\ :invalid) do
    character
    |> cast_attachments(attrs, [:image])
    |> validate_required([:image])
  end

  def get_value(character, key) do
    Map.get(character, String.to_existing_atom(key))
  end
end
