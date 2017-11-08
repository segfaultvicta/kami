defmodule Kami.Repo.Migrations.AddCharacterMetadata do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :gm_notes, :text
      add :secret_gm_notes, :text
      add :patreon, :boolean, default: false, null: false
    end
  end
end
