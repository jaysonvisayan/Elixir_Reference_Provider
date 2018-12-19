defmodule Data.Repo.Migrations.ModifyConsultationDateInLoaTable do
  use Ecto.Migration

  def up do
    alter table(:loas) do
      modify :consultation_date, :utc_datetime
      modify :issue_date, :utc_datetime
    end
  end

  def down do
    alter table(:loas) do
      modify :consultation_date, :date
      modify :issue_date, :date
    end
  end
end
