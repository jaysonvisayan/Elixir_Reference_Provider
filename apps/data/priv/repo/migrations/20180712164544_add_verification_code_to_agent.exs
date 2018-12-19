defmodule Data.Repo.Migrations.AddVerificationCodeToAgent do
  use Ecto.Migration

  def change do
    alter table(:agents) do
      add :verification_code, :string
      add :verification_expiry, :utc_datetime
    end
  end
end

