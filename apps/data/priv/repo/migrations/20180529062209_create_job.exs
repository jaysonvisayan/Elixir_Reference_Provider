defmodule Data.Repo.Migrations.CreateJob do
  use Ecto.Migration

  def change do
    create table(:jobs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_done, :boolean
      add :name, :string
      add :api_name, :string
      add :params, :map
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create index(:jobs, [:user_id])
  end
end
