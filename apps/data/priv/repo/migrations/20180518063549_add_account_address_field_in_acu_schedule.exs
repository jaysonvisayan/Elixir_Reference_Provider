defmodule Data.Repo.Migrations.AddAccountAddressFieldInAcuSchedule do
  use Ecto.Migration

  def change do
    alter table(:acu_schedules) do
      add :account_address, :text
    end
  end
end
