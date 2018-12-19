defmodule Data.Repo.Migrations.CreateJobStatus do
  use Ecto.Migration

  def change do
    create table(:job_statuses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_success, :boolean
      add :params, :map
      add :return, {:array, :string}
      add :job_id, references(:jobs, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create index(:job_statuses, [:job_id])
  end
end
