defmodule Data.Repo.Migrations.AddStatusToAcuScheduleMembers do
  use Ecto.Migration

  def up do
    alter table(:acu_schedule_members) do
      add :status, :string
    end
  end

  def down do
    alter table(:acu_schedule_members) do
      remove :status
    end
  end
end
