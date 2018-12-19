defmodule Data.Repo.Migrations.CreateDoctorProvider do
  use Ecto.Migration

  def change do
    create table(:doctor_providers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :doctor_id, references(:doctors, type: :binary_id, on_delete: :nothing)
      add :provider_id, references(:providers, type: :binary_id, on_delete: :nothing)
      timestamps()
    end
  end
end
