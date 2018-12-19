defmodule Data.Repo.Migrations.AddFieldsOnAcuschedule do
  use Ecto.Migration

  def change do
    alter table(:acu_schedule_members) do
      add :is_availed, :boolean
      add :is_registered, :boolean
    end
  end
end
