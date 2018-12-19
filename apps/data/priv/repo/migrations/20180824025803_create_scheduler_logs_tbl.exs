defmodule Data.Repo.Migrations.CreateSchedulerLogsTbl do
  use Ecto.Migration

  def up do
    create table(:scheduler_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :module_name, :string
      add :method_name, :string
      add :message, :string

      timestamps()
    end
  end

  def down do
    drop table(:scheduler_logs)
  end
end

