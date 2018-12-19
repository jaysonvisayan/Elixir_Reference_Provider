defmodule Data.Repo.Migrations.AddHiddenFromMobileFieldToAcuSchedule do
  use Ecto.Migration

  def up do
    alter table(:acu_schedules) do
     add :hidden_from_mobile, :boolean, default: false
    end
  end

  def down do
    alter table(:acu_schedules) do
     remove :hidden_from_mobile
    end
  end

end
