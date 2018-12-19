defmodule Data.Repo.Migrations.RemoveSubmitBatchFileToAcuSchedules do
  use Ecto.Migration

  def up do
    alter table(:acu_schedules) do
      remove :submit_batch_file
    end
  end

  def down do
    alter table(:acu_schedules) do
      add :submit_batch_file, :string
    end
  end

end
