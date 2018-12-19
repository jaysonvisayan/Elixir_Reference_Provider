defmodule Data.Repo.Migrations.RemovePrimaryKey do
  use Ecto.Migration

  def up do
    alter table(:loa_diagnoses) do
      remove :payorlink_diagnosis_id

      add :payorlink_diagnosis_id, :binary_id
    end
  end

  def down do
    alter table(:loa_diagnoses) do
      remove :payorlink_diagnosis_id

      add :payorlink_diagnosis_id, :string
    end
  end
end
