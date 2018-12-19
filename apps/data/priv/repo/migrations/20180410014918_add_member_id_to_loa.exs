defmodule Data.Repo.Migrations.AddMemberIdToLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :member_id, references(:members, type: :binary_id, on_delete: :delete_all)
    end
    create index(:loas, [:member_id])
  end
end
