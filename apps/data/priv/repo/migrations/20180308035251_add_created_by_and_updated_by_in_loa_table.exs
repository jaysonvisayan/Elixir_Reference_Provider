defmodule Data.Repo.Migrations.AddCreatedByAndUpdatedByInLoaTable do
  use Ecto.Migration

  def up do
    alter table(:loas) do
      add :created_by_id, references(:users, type: :binary_id)
      add :updated_by_id, references(:users, type: :binary_id)
    end
  end

  def down do
    alter table(:loas) do
      remove :created_by_id
      remove :updated_by_id
    end
  end
end
