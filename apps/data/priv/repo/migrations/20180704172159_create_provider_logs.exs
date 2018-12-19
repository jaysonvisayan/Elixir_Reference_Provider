defmodule Data.Repo.Migrations.CreateProviderLogs do
  use Ecto.Migration

  def change do
    create table(:provider_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :module, :string
      add :module_id, :binary_id
      add :details, :string
      add :remarks, :string

      timestamps()
    end
  end
end
