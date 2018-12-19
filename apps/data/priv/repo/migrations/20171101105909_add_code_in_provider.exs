defmodule Data.Repo.Migrations.AddCodeInProvider do
  use Ecto.Migration

  def change do
    alter table(:providers) do
      add :code, :string
    end
  end
end
