defmodule Kami.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :description, :text
      add :ooc, :boolean, default: false, null: false
      add :locked, :boolean, default: false, null: false
      add :parent_id, references(:locations, on_delete: :delete_all)
      
      timestamps()
    end

    create index(:locations, [:parent_id])
  end
end
