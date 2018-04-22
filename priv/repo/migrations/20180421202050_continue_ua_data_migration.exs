defmodule Kami.Repo.Migrations.ContinueUaDataMigration do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :favourite, :integer, default: 0
      add :guru, :integer, default: 0
      add :mentor, :integer, default: 0
      add :responsibility, :integer, default: 0
      add :protege, :integer, default: 0
      add :id1, :string, default: ""
      add :id1_pct, :integer, default: 0
      add :id1_desc, :string, default: "I am a ___, of course I can ___. Substitutes for ___. Features:"
      add :id1_visible, :boolean, default: false, null: false
      add :id2, :string, default: ""
      add :id2_pct, :integer, default: 0
      add :id2_desc, :string, default: "I am a ___, of course I can ___. Substitutes for ___. Features:"
      add :id2_visible, :boolean, default: false, null: false
      add :id3, :string, default: ""
      add :id3_pct, :integer, default: 0
      add :id3_desc, :string, default: "I am a ___, of course I can ___. Substitutes for ___. Features:"
      add :id3_visible, :boolean, default: false, null: false
      add :id4, :string, default: ""
      add :id4_pct, :integer, default: 0
      add :id4_desc, :string, default: "I am a ___, of course I can ___. Substitutes for ___. Features:"
      add :id4_visible, :boolean, default: false, null: false
      add :id5, :string, default: ""
      add :id5_pct, :integer, default: 0
      add :id5_desc, :string, default: "I am a ___, of course I can ___. Substitutes for ___. Features:"
      add :id5_visible, :boolean, default: false, null: false
      add :id6, :string, default: ""
      add :id6_pct, :integer, default: 0
      add :id6_desc, :string, default: "I am a ___, of course I can ___. Substitutes for ___. Features:"
      add :id6_visible, :boolean, default: false, null: false
      remove :other
      remove :identities
      remove :distinguishing_characteristics
      remove :air
      remove :water
      remove :fire
      remove :void
      remove :earth
      remove :strife
      remove :school
      remove :school_rank
      remove :glory
      remove :status
      remove :honor
      remove :void_points
      remove :skill_melee
      remove :skill_sentiment
      remove :skill_courtesy
      remove :skill_survival
      remove :skill_smithing
      remove :skill_government
      remove :skill_games
      remove :skill_performance
      remove :skill_skullduggery
      remove :skill_aesthetics
      remove :skill_meditation
      remove :skill_medicine
      remove :skill_labor
      remove :skill_theology
      remove :skill_design
      remove :skill_culture
      remove :skill_iaijutsu
      remove :skill_fitness
      remove :skill_ranged
      remove :skill_composition
      remove :skill_command
      remove :skill_unarmed
      remove :skill_seafaring
      remove :skill_commerce
      remove :skill_tactics
      remove :ninjo
      remove :giri
      remove :questions
      remove :outburst
      remove :adversities
      remove :armor
      remove :techniques
      remove :passions
      remove :distinctions
      remove :weapons
      remove :clan
      remove :anxieties
      remove :titles
    end
  end
end
