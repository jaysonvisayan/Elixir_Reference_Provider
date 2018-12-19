defmodule Data.Repo.Migrations.AddLastFacilityToMember do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :last_facility, :string
    end
  end
end
