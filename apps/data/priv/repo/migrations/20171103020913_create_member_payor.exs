defmodule Data.Repo.Migrations.CreateMemberPayor do
  use Ecto.Migration

  def up do
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

      create unique_index(:member_payors, [:member_id])
      create unique_index(:member_payors, [:payor_id])
  end

  def down do
    drop table(:member_payors)
  end
end
