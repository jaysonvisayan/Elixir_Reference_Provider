defmodule Data.Repo.Migrations.AddBatchIdInFile do
  use Ecto.Migration

  def change do
    alter table(:files) do
      add :batch_id, references(:batches, type: :binary_id, on_delete: :delete_all)
    end
  end
end
