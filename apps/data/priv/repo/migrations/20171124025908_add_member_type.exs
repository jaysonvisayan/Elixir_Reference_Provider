defmodule Data.Repo.Migrations.AddMemberType do
  use Ecto.Migration

  def up do
    alter table(:members) do
      remove :number_of_consultations
      add :type, :string
    end
  end

  def down do
    alter table(:members) do
      remove :type
      add :number_of_consultations, :string
    end
  end
end
