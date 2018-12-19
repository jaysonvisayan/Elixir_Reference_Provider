defmodule Data.Repo.Migrations.DropPrescriptionTermToAcuSchedule do
  use Ecto.Migration

  def up do
    alter table(:acu_schedules) do
      remove :prescription_term
    end
  end

  def down do
    alter table(:acu_schedules) do
      add :prescription_term, :integer
    end
  end

end
