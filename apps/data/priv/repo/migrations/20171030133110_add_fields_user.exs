defmodule Data.Repo.Migrations.AddFieldsUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :status, :string
      add :pin, :string
      add :pin_expires_at, :utc_datetime
      add :attempt, :integer
    end
  end
end
