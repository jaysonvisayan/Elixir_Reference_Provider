defmodule Data.Repo.Migrations.AddAddressAndContactFieldsInProviders do
  use Ecto.Migration

  def change do
    alter table(:providers) do
      add :phone_no, :string
      add :email_address, :string
      add :line_1, :string
      add :line_2, :string
      add :city, :string
      add :province, :string
      add :region, :string
      add :country, :string
      add :postal_code, :string
    end
  end
end
