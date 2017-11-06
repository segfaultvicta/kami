defmodule Kami.Repo.Migrations.CreateLetters do
  use Ecto.Migration

  def change do
    create table(:letters) do
      add :text, :text
      add :description, :text
      add :to_postmaster, :boolean, default: false, null: false
      add :sender_id, references(:characters, on_delete: :nothing)
      add :author_id, references(:characters, on_delete: :nothing)
      add :recipient_id, references(:characters, on_delete: :nothing)

      timestamps()
    end

    create index(:letters, [:sender_id])
    create index(:letters, [:author_id])
    create index(:letters, [:recipient_id])
  end
end
