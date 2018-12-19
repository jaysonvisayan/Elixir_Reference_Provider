defmodule Data.Repo.Migrations.AddIsRecognizedInAcuScheduleMember do
  use Ecto.Migration

  def change do
    alter table(:acu_schedule_members) do
      add :is_recognized, :boolean
    end
  end
end
