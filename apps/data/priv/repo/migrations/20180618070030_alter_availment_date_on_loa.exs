defmodule Data.Repo.Migrations.AlterAvailmentDateOnLoa do
  use Ecto.Migration

  def up do
    alter table(:loas) do
      modify :availment_date, :date
    end
  end

  def down do
    alter table(:loas) do
      modify :availment_date, :utc_datetime
    end
  end
end
