defmodule Data.Repo.Migrations.CreateLoaPackage do
  use Ecto.Migration

  def change do
    create table(:loa_packages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :payorlink_benefit_package_id, :binary_id
      add :loa_id, references(:loas, type: :binary_id, on_delete: :delete_all)
      add :code, :string
      add :description, :text
      add :amount, :decimal

      timestamps()
    end
  end
end
