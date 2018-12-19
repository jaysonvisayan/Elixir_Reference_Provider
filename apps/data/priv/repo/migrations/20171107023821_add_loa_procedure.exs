defmodule Data.Repo.Migrations.AddLoaProcedure do
  use Ecto.Migration

  def change do
    create table(:loa_procedures, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :payorlink_procedure_id, :binary_id
      add :loa_diagnosis_id, references(:loa_diagnoses, type: :binary_id,
                                        on_delete: :nothing)
      add :procedure_code, :string
      add :procedure_description, :string
      add :unit, :string
      add :amount, :string

      timestamps()
    end
  end
end
