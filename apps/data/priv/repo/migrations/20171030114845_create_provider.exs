defmodule Data.Repo.Migrations.CreateProvider do
  use Ecto.Migration

  def change do
    create table(:providers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :payorlink_facility_id, :binary_id
      add :name, :string

      timestamps()
    end
  end
end
