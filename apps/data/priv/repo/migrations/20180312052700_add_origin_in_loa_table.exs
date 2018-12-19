defmodule Data.Repo.Migrations.AddOriginInLoaTable do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :origin, :string
    end
  end
end
