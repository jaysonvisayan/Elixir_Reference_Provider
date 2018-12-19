defmodule Data.Repo.Migrations.CreateAcuScheduleMemberUploadLog do
  use Ecto.Migration

  def change do
    create table(:acu_schedule_member_upload_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :filename, :string
      add :card_no, :string
      add :full_name, :string
      add :gender, :string
      add :birthdate, :string
      add :age, :string
      add :package_code, :string
      add :signature, :string
      add :availed, :string
      add :remarks, :string

      add :acu_schedule_member_upload_file_id, references(:acu_schedule_member_upload_files, type: :binary_id, on_delete: :delete_all)
      add :created_by_id, references(:users, type: :binary_id)

      timestamps()
    end
  end

end
