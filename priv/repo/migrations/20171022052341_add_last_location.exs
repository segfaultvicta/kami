defmodule Kami.Repo.Migrations.AddLastLocation do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :last_location_id, :integer
    end
  end
end
