defmodule Kami.Repo.Migrations.FixErroneousVarcharColumns do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :identities
      add :identities, :text, default: ""
    end
    alter table(:characters) do
      remove :id1_desc
      remove :id2_desc
      remove :id3_desc
      remove :id4_desc
      remove :id5_desc
      remove :id6_desc
      add :id1_desc, :text, default: "I am a ___, of course I can ___.\n\nSubstitutes for ___.\n\nFeatures:"
      add :id2_desc, :text, default: "I am a ___, of course I can ___.\n\nSubstitutes for ___.\n\nFeatures:"
      add :id3_desc, :text, default: "I am a ___, of course I can ___.\n\nSubstitutes for ___.\n\nFeatures:"
      add :id4_desc, :text, default: "I am a ___, of course I can ___.\n\nSubstitutes for ___.\n\nFeatures:"
      add :id5_desc, :text, default: "I am a ___, of course I can ___.\n\nSubstitutes for ___.\n\nFeatures:"
      add :id6_desc, :text, default: "I am a ___, of course I can ___.\n\nSubstitutes for ___.\n\nFeatures:"
    end
  end
end
