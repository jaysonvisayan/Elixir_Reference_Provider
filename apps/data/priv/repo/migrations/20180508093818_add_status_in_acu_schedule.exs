defmodule Data.Repo.Migrations.AddStatusInAcuSchedule do
  use Ecto.Migration

  def change do
    alter table(:acu_schedules) do
      add :status, :string
    end
  end
end
