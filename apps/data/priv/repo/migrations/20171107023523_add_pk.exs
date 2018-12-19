defmodule Data.Repo.Migrations.AddPk do
  use Ecto.Migration

  def up do
    alter table(:loa_diagnoses) do
      remove :id

      add :id, :binary_id, primary_key: true
    end
  end

  def down do
    alter table(:loa_diagnoses) do
      remove :id

      add :id, :integer, primary_key: true
    end
  end
end
