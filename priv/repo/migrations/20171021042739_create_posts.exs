defmodule Kami.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :name, :string
      add :image, :string
      add :text, :text
      add :honor, :integer
      add :glory, :integer
      add :status, :integer
      add :ooc, :boolean, default: false, null: false
      add :narrative, :boolean, default: false, null: false
      add :diceroll, :boolean, default: false, null: false
      add :skillroll, :boolean, default: false, null: false
      add :results, {:array, :integer}
      add :ring_name, :string
      add :skill_name, :string
      add :ring_value, :integer
      add :die_size, :integer
      add :author_slug, :string
      
      add :location_id, references(:locations, on_delete: :delete_all)

      timestamps()
    end

  end
end
