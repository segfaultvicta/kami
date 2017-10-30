defmodule Kami.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :name, :string, default: ""
      add :image, :string, default: ""
      add :text, :text, default: ""
      add :honor, :integer, default: 0
      add :glory, :integer, default: 0
      add :status, :integer, default: 0
      add :ooc, :boolean, default: false, null: false
      add :narrative, :boolean, default: false, null: false
      add :diceroll, :boolean, default: false, null: false
      add :skillroll, :boolean, default: false, null: false
      add :results, {:array, :integer}
      add :ring_name, :string, default: ""
      add :skill_name, :string, default: ""
      add :ring_value, :integer, default: 0
      add :die_size, :integer, default: 0
      add :author_slug, :string, default: ""
      
      add :location_id, references(:locations, on_delete: :delete_all)

      timestamps()
    end

  end
end
