defmodule Data.Repo.Migrations.AddPayorlinkIdsToRole do
  use Ecto.Migration

  def change do
    alter table(:roles) do
      add :payorlink_role_id, :binary_id
    end
  end
end
