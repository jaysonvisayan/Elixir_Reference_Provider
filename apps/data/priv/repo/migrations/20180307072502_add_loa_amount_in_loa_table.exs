defmodule Data.Repo.Migrations.AddLoaAmountInLoaTable do
  use Ecto.Migration

  def up do
    alter table(:loas) do
      add :member_pays, :decimal
      add :payor_pays, :decimal
      add :total_amount, :decimal
    end
  end

  def down do
    alter table(:loas) do
      remove :member_pays
      remove :payor_pays
      remove :total_pays
    end
  end
end
