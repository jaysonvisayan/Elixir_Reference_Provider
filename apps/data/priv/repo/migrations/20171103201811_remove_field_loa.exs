defmodule Data.Repo.Migrations.RemoveFieldLoa do
  use Ecto.Migration

  def up do
    alter table(:loas) do
      remove :consultation_datetime

      add :consultation_date, :date
    end
  end

  def down do
    alter table(:loas) do
      remove :consultation_date

      add :consultation_datetime, :utc_datetime
    end
  end
end
