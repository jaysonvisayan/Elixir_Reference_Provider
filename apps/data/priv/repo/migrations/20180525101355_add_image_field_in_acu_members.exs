defmodule Data.Repo.Migrations.AddImageFieldInAcuMembers do
  use Ecto.Migration

  def change do
    alter table(:acu_schedule_members) do
      add :image, :text
    end
  end
end
