defmodule Data.Repo.Migrations.AddPayorMember do
  use Ecto.Migration

  def up do
    drop table(:member_payors)
    alter table(:members) do
      add :payor_id, references(:payors, type: :binary_id, on_delete: :nothing)
    end
  end

  def down do
    create table(:member_payors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :member_id, references(:members,
                                 type: :binary_id,
                                 on_delete: :nothing)
      add :payor_id, references(:payors,
                                type: :binary_id,
                                on_delete: :nothing)

      timestamps()
    end

    execute "ALTER TABLE members DROP CONSTRAINT members_payor_id_fkey"
    alter table(:members) do
      remove :payor_id
    end
  end
end
