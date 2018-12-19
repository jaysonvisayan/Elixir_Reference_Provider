defmodule Data.Repo.Migrations.AddFacilityToMember do
  use Ecto.Migration

  def up do
  	alter table(:members) do
  	 add :facility_code, :string
  	end
  end

  def down do
  	alter table(:members) do
  	 remove :facility_code
  	end
  end
end
