defmodule Data.Repo.Migrations.AddUsernamePasswordPayor do
  use Ecto.Migration

  def change do
    alter table(:payors) do
      add :username, :string
      add :password, :string
    end
  end
end
