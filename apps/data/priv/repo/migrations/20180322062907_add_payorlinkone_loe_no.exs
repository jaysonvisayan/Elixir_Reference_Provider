defmodule Data.Repo.Migrations.AddPayorlinkoneLoeNo do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :payorlinkone_loe_no, :string
    end
  end
end
