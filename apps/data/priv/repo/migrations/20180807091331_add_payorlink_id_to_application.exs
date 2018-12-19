defmodule Data.Repo.Migrations.AddPayorlinkIdToApplication do
  use Ecto.Migration

  def change do
    alter table(:applications) do
      add :payorlink_application_id, :binary_id
    end
  end
end
