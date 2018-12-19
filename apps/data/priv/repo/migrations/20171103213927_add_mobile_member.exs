defmodule Data.Repo.Migrations.AddMobileMember do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :mobile, :string
    end
  end
end
