defmodule Kami.Repo.Migrations.AddNewRollMdToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :rolled, :text, default: ""
      add :target, :integer, default: 0
      add :result, :integer, default: 0
    end
  end
end
