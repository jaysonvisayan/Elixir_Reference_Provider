defmodule Data.Repo.Migrations.AddAccountDetailsToMember do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :account_code, :string
      add :account_name, :string
    end
  end
end
