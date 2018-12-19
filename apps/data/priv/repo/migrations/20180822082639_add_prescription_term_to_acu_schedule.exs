defmodule Data.Repo.Migrations.AddPrescriptionTermToAcuSchedule do
  use Ecto.Migration

  def up do
    alter table(:acu_schedules) do
      add :prescription_term, :integer
    end
  end

  def down do
    alter table(:acu_schedules) do
      remove :prescription_term
    end
  end

end
