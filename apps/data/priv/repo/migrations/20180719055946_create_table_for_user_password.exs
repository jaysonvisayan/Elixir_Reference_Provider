defmodule Data.Repo.Migrations.CreateTableForUserPassword do
  use Ecto.Migration

  def change do
    create table(:user_passwords, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :nothing)
      add :hashed_password, :string

      timestamps()
    end
  end

end
