defmodule Data.Repo.Migrations.AddFieldsOnLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :consultation_type, :string
      add :chief_complaint, :string
      add :chief_complaint_others, :string
      add :transaction_id, :string
    end
  end
end
