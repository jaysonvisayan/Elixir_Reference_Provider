defmodule Data.Repo.Migrations.AddCodePayor do
  use Ecto.Migration

  def change do
    alter table(:payors) do
      add :code, :string
    end
  end
end
