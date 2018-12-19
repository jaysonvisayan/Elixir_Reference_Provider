defmodule Data.Repo.Migrations.AddLoaStatusInAcuScheduleMember do
  use Ecto.Migration

  def change do
    alter table(:acu_schedule_members) do
      add :loa_status, :string
    end
  end
end
