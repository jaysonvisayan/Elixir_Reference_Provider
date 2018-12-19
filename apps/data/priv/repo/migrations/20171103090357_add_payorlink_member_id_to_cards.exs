defmodule Data.Repo.Migrations.AddPayorlinkMemberIdToCards do
  use Ecto.Migration

  def change do
    alter table(:cards) do
      add :payorlink_member_id, :string
    end
  end
end
