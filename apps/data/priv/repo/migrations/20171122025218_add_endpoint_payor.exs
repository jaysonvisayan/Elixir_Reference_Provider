defmodule Data.Repo.Migrations.AddEndpointPayor do
  use Ecto.Migration

  def change do
    alter table(:payors) do
      add :endpoint, :string
    end
  end
end
