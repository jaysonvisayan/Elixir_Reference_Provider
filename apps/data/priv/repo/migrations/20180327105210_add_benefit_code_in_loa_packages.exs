defmodule Data.Repo.Migrations.AddBenefitCodeInLoaPackages do
  use Ecto.Migration

  def change do
    alter table(:loa_packages) do
      add :benefit_code, :string
    end
  end
end
