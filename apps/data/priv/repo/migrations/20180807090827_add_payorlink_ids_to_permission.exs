defmodule Data.Repo.Migrations.AddPayorlinkIdsToPermission do
  use Ecto.Migration

  def change do
    alter table(:permissions) do
      add :payorlink_permission_id, :binary_id
      add :payorlink_application_id, :binary_id
    end
  end
end
