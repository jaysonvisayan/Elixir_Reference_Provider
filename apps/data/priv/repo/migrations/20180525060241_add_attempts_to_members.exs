defmodule Data.Repo.Migrations.AddAttemptsToMembers do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :attempts, :integer
    end
  end
end
