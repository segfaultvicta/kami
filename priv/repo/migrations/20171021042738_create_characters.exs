defmodule Kami.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :name, :string
      add :clan, :string
      add :family, :string
      add :school, :string
      add :school_rank, :integer
      add :honor, :integer
      add :glory, :integer
      add :status, :integer
      add :strife, :integer
      add :approved, :boolean, default: false, null: false
      add :void_points, :integer
      add :void_points_max, :integer
      add :air, :integer
      add :earth, :integer
      add :fire, :integer
      add :water, :integer
      add :void, :integer
      add :skill_aesthetics, :integer
      add :skill_composition, :integer
      add :skill_design, :integer
      add :skill_smithing, :integer
      add :skill_fitness, :integer
      add :skill_iaijutsu, :integer
      add :skill_melee, :integer
      add :skill_ranged, :integer
      add :skill_unarmed, :integer
      add :skill_meditation, :integer
      add :skill_tactics, :integer
      add :skill_command, :integer
      add :skill_courtesy, :integer
      add :skill_games, :integer
      add :skill_performance, :integer
      add :skill_culture, :integer
      add :skill_government, :integer
      add :skill_sentiment, :integer
      add :skill_theology, :integer
      add :skill_medicine, :integer
      add :skill_commerce, :integer
      add :skill_labor, :integer
      add :skill_seafaring, :integer
      add :skill_skullduggery, :integer
      add :skill_survival, :integer
      add :ninjo, :text
      add :giri, :text
      add :titles, :text
      add :distinctions, :text
      add :adversities, :text
      add :passions, :text
      add :anxieties, :text
      add :outburst, :text
      add :weapons, :text
      add :armor, :text
      add :techniques, :text
      add :questions, :text
      add :public_description, :text
      add :images, {:array, :string}
      add :bxp, :float
      add :bxp_this_week, :float
      add :xp, :float
      add :total_xp, :float
      add :total_spent_xp, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:characters, [:name])
  end
end
