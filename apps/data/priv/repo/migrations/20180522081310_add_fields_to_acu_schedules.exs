defmodule Data.Repo.Migrations.AddFieldsToAcuSchedules do
  use Ecto.Migration

  def change do
    alter table(:acu_schedules) do
      add :time_from, :time
      add :time_to, :time
    end
  end
end
