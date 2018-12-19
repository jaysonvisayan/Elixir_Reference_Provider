defmodule Data.Repo.Migrations.AddLoaIdLoaDiagnosis do
  use Ecto.Migration

  def change do
    alter table(:loa_diagnoses) do
      add :loa_id, references(:loas, type: :binary_id, on_delete: :nothing)
    end
  end
end
