defmodule Kami.Repo.Migrations.AddIdentitiesToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :identities, :string, default: ""
    end
  end
end
