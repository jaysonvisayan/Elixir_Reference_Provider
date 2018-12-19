defmodule Data.Repo.Migrations.CreateAgent do
  use Ecto.Migration

  def change do
    create table(:agents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :extension, :string
      add :department, :string
      add :role, :string
      add :mobile, :string
      add :email, :string

      timestamps()
    end
  end
end
