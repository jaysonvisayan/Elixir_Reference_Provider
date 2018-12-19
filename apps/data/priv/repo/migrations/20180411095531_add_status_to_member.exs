defmodule Data.Repo.Migrations.AddStatusToMember do
  use Ecto.Migration

  def up do
    alter table(:members) do
      add :status, :string
    end
  end

  def down do
    alter table(:members) do
      remove :status
    end
  end
end
