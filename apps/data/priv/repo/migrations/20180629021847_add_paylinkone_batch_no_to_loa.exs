defmodule Data.Repo.Migrations.AddPaylinkoneBatchNoToLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :payorlinkone_batch_no, :string
    end
  end
end
