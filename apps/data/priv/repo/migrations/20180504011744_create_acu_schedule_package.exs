defmodule Data.Repo.Migrations.CreateAcuSchedulePackage do
  use Ecto.Migration

  def change do
    create table(:acu_schedule_packages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string
      add :name, :string
      add :description, :string
      add :payorlink_benefit_package_id, :binary_id

      add :acu_schedule_id, references(:acu_schedules, type: :binary_id, on_delete: :nothing)
      timestamps()
    end
  end
end
