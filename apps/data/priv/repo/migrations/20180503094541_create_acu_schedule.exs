defmodule Data.Repo.Migrations.CreateAcuSchedule do
  use Ecto.Migration

  def change do
    create table(:acu_schedules, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :batch_no, :integer
      add :account_code, :string
      add :account_name, :string
      add :date_to, :date
      add :date_from, :date
      add :no_of_members, :integer
      add :no_of_guaranteed, :integer
      add :payorlink_acu_schedule_id, :binary_id
      add :created_by, :string

      add :provider_id, references(:providers, type: :binary_id, on_delete: :nothing)
      timestamps()
    end
  end
end
