defmodule Data.Repo.Migrations.AddPrescriptionTermInProvider do
  use Ecto.Migration

  def change do
    alter table(:agents) do
      remove :prescription_term
    end

    alter table(:providers) do
      add :prescription_term, :integer
    end
  end
end
