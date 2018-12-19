defmodule Data.Repo.Migrations.AddFieldsInAcuSchedule do
  use Ecto.Migration

  def change do
    alter table(:acu_schedules) do
      add :registered, :string
      add :unregistered, :string
    end
  end
end
