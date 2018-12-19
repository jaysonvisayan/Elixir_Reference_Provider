defmodule Data.Repo.Migrations.AddStatusAgent do
  use Ecto.Migration

  def change do
    alter table(:agents) do
      add :status, :string
    end
  end
end
