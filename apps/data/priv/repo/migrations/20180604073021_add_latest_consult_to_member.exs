defmodule Data.Repo.Migrations.AddLatestConsultToMember do
  use Ecto.Migration

  def up do
    alter table(:members) do
     add :latest_consult, :string
    end
  end

  def down do
    alter table(:members) do
     remove :latest_consult
    end
  end
end
