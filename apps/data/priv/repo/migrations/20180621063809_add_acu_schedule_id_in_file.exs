defmodule Data.Repo.Migrations.AddAcuScheduleIdInFile do
  use Ecto.Migration

  def change do
    alter table(:files) do
      add :acu_schedule_id, references(:acu_schedules, type: :binary_id, on_delete: :delete_all)
    end
  end
end
