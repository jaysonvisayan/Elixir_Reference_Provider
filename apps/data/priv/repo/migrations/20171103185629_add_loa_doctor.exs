defmodule Data.Repo.Migrations.AddLoaDoctor do
  use Ecto.Migration

  def change do
    create table(:loa_doctors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :loa_id, references(:loas, type: :binary_id, on_delete: :nothing)
      add :doctor_id, references(:doctors,
                                 type: :binary_id,
                                 on_delete: :nothing)

      timestamps()
    end
  end
end
