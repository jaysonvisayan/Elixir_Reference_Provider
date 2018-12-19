defmodule Data.Repo.Migrations.CreateLoa do
  use Ecto.Migration

  def change do
    create table(:loas, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :card_id, references(:cards, type: :binary_id, on_delete: :nothing)
      add :consultation_datetime, :utc_datetime
      add :coverage, :string
      add :status, :string
    end
  end
end
