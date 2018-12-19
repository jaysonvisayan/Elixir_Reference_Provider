defmodule Data.Repo.Migrations.AddDetailsFieldInLoaPackage do
  use Ecto.Migration

  def change do
    alter table(:loa_packages) do
      add :details, :text
    end
  end
end
