defmodule Data.Repo.Migrations.AddIsPemeToLoa do
  use Ecto.Migration

  def up do
    alter table(:loas) do
      add :is_peme?, :boolean
    end
  end

  def down do
    alter table(:loas) do
      remove :is_peme?
    end
  end
end
