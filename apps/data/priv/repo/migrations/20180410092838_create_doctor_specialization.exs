defmodule Data.Repo.Migrations.CreateDoctorSpecialization do
  use Ecto.Migration

  def change do
    create table(:doctor_specializations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string
      add :payorlink_specialization_id, :binary_id
      add :payorlink_practitioner_specialization_id, :binary_id

      add :doctor_id, references(:doctors, type: :binary_id, on_delete: :nothing)
      timestamps()
    end

    create index(:doctor_specializations, [:doctor_id])
  end
end
