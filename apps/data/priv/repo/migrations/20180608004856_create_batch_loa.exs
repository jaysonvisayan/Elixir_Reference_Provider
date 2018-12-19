defmodule Data.Repo.Migrations.CreateBatchLoa do
  use Ecto.Migration

  def change do
    create table(:batch_loas, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :batch_id, references(:batches, type: :binary_id, on_delete: :nothing)
      add :loa_id, references(:loas, type: :binary_id, on_delete: :nothing)

      timestamps()
    end
  end
end
