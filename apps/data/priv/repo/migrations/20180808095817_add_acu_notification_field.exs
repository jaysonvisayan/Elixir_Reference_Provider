defmodule Data.Repo.Migrations.AddAcuNotificationField do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :acu_schedule_notification, :boolean, default: false
    end
  end

  def down do
    alter table(:users) do
      remove :acu_schedule_notification
    end
  end
end
