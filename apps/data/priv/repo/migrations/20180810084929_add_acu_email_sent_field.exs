defmodule Data.Repo.Migrations.AddAcuEmailSentField do
  use Ecto.Migration

  def up do
    alter table(:acu_schedules) do
      add :acu_email_sent, :boolean, default: true
    end
  end

  def down do
    alter table(:acu_schedules) do
      remove :acu_email_sent
    end
  end

end
