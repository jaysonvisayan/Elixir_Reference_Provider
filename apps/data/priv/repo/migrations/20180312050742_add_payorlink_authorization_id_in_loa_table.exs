defmodule Data.Repo.Migrations.AddPayorlinkAuthorizationIdInLoaTable do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :payorlink_authorization_id, :binary_id
    end
  end
end
