defmodule Data.Repo.Migrations.AddVerificationOnAgent do
  use Ecto.Migration

  def change do
    alter table(:agents) do
      add :verification, :boolean
    end
  end
end
