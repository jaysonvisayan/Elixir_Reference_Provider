defmodule Data.Repo.Migrations.AddEffectiveAndExpiryDateInMember do
  use Ecto.Migration

  def change do
  	alter table(:members) do
  	 add :effective_date, :date
  	 add :expiry_date, :date
    end
  end
end
