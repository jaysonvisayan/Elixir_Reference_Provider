defmodule Data.Repo.Migrations.AddClaimNoFieldInLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :payorlinkone_claim_no, :string
    end
  end
end
