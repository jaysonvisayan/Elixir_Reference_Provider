defmodule Data.Repo.Migrations.CreateSpecialization do
  use Ecto.Migration

  def change do
    create table(:specializations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string
      add :payorlink_specialization_id, :binary_id

      timestamps()
    end
    
    alter table(:doctor_specializations) do
      remove :payorlink_specialization_id
      add :specialization_id, references(:specializations, type: :binary_id, on_delete: :nothing)
    end
  end
end
