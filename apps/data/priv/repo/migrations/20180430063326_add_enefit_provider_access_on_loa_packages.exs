defmodule Data.Repo.Migrations.AddEnefitProviderAccessOnLoaPackages do
  use Ecto.Migration

  def change do
    alter table(:loa_packages) do
      add :benefit_provider_access, :string
    end
  end
end
