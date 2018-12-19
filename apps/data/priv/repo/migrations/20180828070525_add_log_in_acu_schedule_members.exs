defmodule Data.Repo.Migrations.AddLogInAcuScheduleMembers do
  use Ecto.Migration

  def change do
    alter table("acu_schedule_members") do
      add :submit_log, :string
    end
  end
end
