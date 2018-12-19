defmodule Data.Repo.Migrations.AddTypeFieldInProvider do
  use Ecto.Migration

  def change do
    alter table(:providers) do
      add :type, :string
    end
  end
end
