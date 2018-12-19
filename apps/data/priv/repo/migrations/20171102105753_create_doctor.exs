defmodule Data.Repo.Migrations.CreateDoctor do
  use Ecto.Migration

  def change do
  	create table(:doctors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :extension, :string
      add :prc_number, :string
      add :specialization, :string
      add :status, :string
      add :affiliated, :boolean
      timestamps()
    end
  end
end
