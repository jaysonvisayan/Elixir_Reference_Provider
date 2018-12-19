defmodule Data.Repo.Migrations.CreateAcuScheduleMember do
  use Ecto.Migration

  def change do
    create table(:acu_schedule_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :acu_schedule_id, references(:acu_schedules, type: :binary_id, on_delete: :delete_all)
      add :acu_schedule_package_id, references(:acu_schedule_packages, type: :binary_id, on_delete: :nothing)
      add :member_id, references(:members, type: :binary_id, on_delete: :nothing)
      timestamps()
    end
  end
end
