defmodule Data.Repo.Migrations.CreateAcuScheduleMemberUploadFile do
  use Ecto.Migration

  def change do
    create table(:acu_schedule_member_upload_files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :filename, :string
      add :remarks, :string

      add :acu_schedule_id, references(:acu_schedules, type: :binary_id, on_delete: :delete_all)
      add :created_by_id, references(:users, type: :binary_id)

      timestamps()
    end

  end
end
