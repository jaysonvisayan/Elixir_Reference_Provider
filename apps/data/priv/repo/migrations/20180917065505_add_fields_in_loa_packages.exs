defmodule Data.Repo.Migrations.AddFieldsInLoaPackages do
  use Ecto.Migration

  def change do
    alter table("loa_packages") do
      add :loa_benefit_acu_type, :string
      add :loa_limit_amount, :decimal
    end
  end
end
