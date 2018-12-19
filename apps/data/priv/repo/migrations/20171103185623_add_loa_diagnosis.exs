defmodule Data.Repo.Migrations.AddLoaDiagnosis do
  use Ecto.Migration

  def change do
    create table(:loa_diagnoses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :payorlink_diagnosis_id, :binary_id, primary_key: true
      add :diagnosis_code, :string
      add :diagnosis_description, :string

      timestamps()
    end
  end
end
