defmodule Kami.Repo.Migrations.SetupCharacterForUa do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :cabal, :text, default: ""
      add :concept, :text, default: ""
      add :objectives, :text, default: ""
      add :distinguishing_characteristics, :text, default: ""
      add :rage, :text, default: ""
      add :noble, :text, default: ""
      add :fear, :text, default: ""
      add :helplessness_hardened, :integer, default: 0
      add :helplessness_failures, :integer, default: 0
      add :isolation_hardened, :integer, default: 0
      add :isolation_failures, :integer, default: 0
      add :self_hardened, :integer, default: 0
      add :self_failures, :integer, default: 0
      add :unnatural_hardened, :integer, default: 0
      add :unnatural_failures, :integer, default: 0
      add :violence_hardened, :integer, default: 0
      add :violence_failures, :integer, default: 0
      add :identities, :text, default: ""
      add :other, :text, default: ""
    end
  end
end
