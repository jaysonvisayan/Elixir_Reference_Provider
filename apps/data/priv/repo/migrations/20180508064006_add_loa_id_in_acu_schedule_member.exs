defmodule Data.Repo.Migrations.AddLoaIdInAcuScheduleMember do
  use Ecto.Migration

  def change do
    alter table(:acu_schedule_members) do
      add :loa_id, references(:loas, type: :binary_id, on_delete: :nothing)
    end
  end
end
