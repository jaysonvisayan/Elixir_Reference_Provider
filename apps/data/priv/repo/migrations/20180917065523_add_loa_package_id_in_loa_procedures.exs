defmodule Data.Repo.Migrations.AddLoaPackageIdInLoaProcedures do
  use Ecto.Migration

  def change do
    alter table("loa_procedures") do
      add :package_id, references(:loa_packages, type: :binary_id, on_delete: :nothing)
    end
  end
end
