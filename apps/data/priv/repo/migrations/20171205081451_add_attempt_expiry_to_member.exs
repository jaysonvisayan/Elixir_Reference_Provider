defmodule Data.Repo.Migrations.AddAttemptExpiryToMember do
  use Ecto.Migration

  def change do
  	alter table(:members) do
  		add :attempt_expiry, :utc_datetime
  	end
  end
end
