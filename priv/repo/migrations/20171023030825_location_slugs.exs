defmodule Kami.Repo.Migrations.LocationSlugs do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :slug, :string
    end
    
    create unique_index(:locations, [:slug]) # should be unique
  end
end
