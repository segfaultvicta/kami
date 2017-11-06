defmodule Kami.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :name, :string, default: ""
      add :clan, :string, default: ""
      add :family, :string, default: ""
      add :school, :string, default: ""
      add :school_rank, :integer, default: 0
      add :honor, :integer, default: 0
      add :glory, :integer, default: 0
      add :status, :integer, default: 0
      add :strife, :integer, default: 0
      add :approved, :boolean, default: false, null: false
      add :void_points, :integer, default: 0
      add :air, :integer, default: 0
      add :earth, :integer, default: 0
      add :fire, :integer, default: 0
      add :water, :integer, default: 0
      add :void, :integer, default: 0
      add :skill_aesthetics, :integer, default: 0
      add :skill_composition, :integer, default: 0
      add :skill_design, :integer, default: 0
      add :skill_smithing, :integer, default: 0
      add :skill_fitness, :integer, default: 0
      add :skill_iaijutsu, :integer, default: 0
      add :skill_melee, :integer, default: 0
      add :skill_ranged, :integer, default: 0
      add :skill_unarmed, :integer, default: 0
      add :skill_meditation, :integer, default: 0
      add :skill_tactics, :integer, default: 0
      add :skill_command, :integer, default: 0
      add :skill_courtesy, :integer, default: 0
      add :skill_games, :integer, default: 0
      add :skill_performance, :integer, default: 0
      add :skill_culture, :integer, default: 0
      add :skill_government, :integer, default: 0
      add :skill_sentiment, :integer, default: 0
      add :skill_theology, :integer, default: 0
      add :skill_medicine, :integer, default: 0
      add :skill_commerce, :integer, default: 0
      add :skill_labor, :integer, default: 0
      add :skill_seafaring, :integer, default: 0
      add :skill_skullduggery, :integer, default: 0
      add :skill_survival, :integer, default: 0
      add :ninjo, :text, default: ""
      add :giri, :text, default: ""
      add :titles, :text, default: ""
      add :distinctions, :text, default: ""
      add :adversities, :text, default: ""
      add :passions, :text, default: ""
      add :anxieties, :text, default: ""
      add :outburst, :text, default: ""
      add :weapons, :text, default: ""
      add :armor, :text, default: ""
      add :techniques, :text, default: ""
      add :questions, :text, default: ""
      add :public_description, :text, default: ""
      add :image, :string, default: ""
      add :bxp, :float, default: 0
      add :bxp_this_week, :float, default: 0
      add :xp, :float, default: 0
      add :total_xp, :float, default: 0
      add :total_spent_xp, :integer, default: 0
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:characters, [:name])
  end
end
