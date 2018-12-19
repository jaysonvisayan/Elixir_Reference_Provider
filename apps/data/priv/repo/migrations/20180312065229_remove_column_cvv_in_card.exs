defmodule Data.Repo.Migrations.RemoveColumnCvvInCard do
  use Ecto.Migration

  def up do
    alter table(:cards) do
      remove :cvv
    end
  end

  def down do
    alter table(:cards) do
      add :cvv, :string
    end
  end
end
