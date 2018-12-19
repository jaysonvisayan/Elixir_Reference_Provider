defmodule Data.Repo.Migrations.AddPrescriptionTermInAgents do
  use Ecto.Migration

  def change do
    alter table(:agents) do
      add :prescription_term, :integer
    end
  end
end
