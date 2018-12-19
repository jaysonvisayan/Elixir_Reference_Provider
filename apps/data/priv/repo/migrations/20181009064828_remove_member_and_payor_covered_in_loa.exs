defmodule Data.Repo.Migrations.RemoveMemberAndPayorCoveredInLoa do
  use Ecto.Migration

  def up do
    alter table(:loas) do
      remove :member_covered
      remove :payor_covered
      remove :date_from
      remove :date_to
    end
  end

  def down do
    alter table(:loas) do
      add :member_covered, :decimal
      add :payor_covered, :decimal
      add :date_from, :date
      add :date_to, :date
    end
  end

end
