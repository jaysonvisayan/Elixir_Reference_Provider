defmodule Data.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string
      add :hashed_password, :string
      add :email, :string
      add :mobile, :string
      add :avatar, :string

      timestamps()
    end
  end
end
