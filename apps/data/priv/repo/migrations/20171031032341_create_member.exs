defmodule Data.Repo.Migrations.CreateMember do
  use Ecto.Migration

  def change do
    create table(:members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :payorlink_member_id, :string
      add :first_name, :string
      add :middle_name, :string
      add :last_name, :string
      add :extension, :string
      add :birth_date, :date
      add :gender, :string
      add :pin, :string
      add :pin_expires_at, :utc_datetime

      timestamps()
    end
  end
end
