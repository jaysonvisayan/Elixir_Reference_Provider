defmodule Data.Repo.Migrations.CreateFile do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false)  do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string
      add :loa_id, references(:loas, type: :binary_id, on_delete: :delete_all)
      timestamps()
    end
  end
end
