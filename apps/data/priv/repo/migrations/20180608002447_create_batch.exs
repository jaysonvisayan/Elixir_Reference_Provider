defmodule Data.Repo.Migrations.CreateBatch do
  use Ecto.Migration

  def change do
    create table(:batches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :string
      add :soa_reference_no, :string
      add :soa_amount, :decimal, default: 0
      add :edited_soa_amount, :decimal, default: 0
      add :status, :string
      add :type, :string
      add :doctor_id, references(:doctors, type: :binary_id, on_delete: :nothing)
      add :created_by_id, references(:users, type: :binary_id, on_delete: :nothing)

      timestamps()
    end
  end
end
