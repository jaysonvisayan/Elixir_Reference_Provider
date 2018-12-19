defmodule Data.Repo.Migrations.AddLoaIdInLoaProcedures do
  use Ecto.Migration

  def change do
    alter table(:loa_procedures) do
      add :loa_id, references(:loas, type: :binary_id, on_delete: :delete_all)
    end
  end
end
