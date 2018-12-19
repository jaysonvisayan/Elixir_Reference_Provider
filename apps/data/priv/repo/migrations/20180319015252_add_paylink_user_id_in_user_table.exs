defmodule Data.Repo.Migrations.AddPaylinkUserIdInUserTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :paylink_user_id, :string
    end
  end
end
