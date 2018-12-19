defmodule Data.Repo.Migrations.AddTimestampsLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      timestamps()
    end
  end
end
