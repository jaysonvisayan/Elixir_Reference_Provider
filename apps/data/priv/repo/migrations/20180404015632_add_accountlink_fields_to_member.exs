defmodule Data.Repo.Migrations.AddAccountlinkFieldsToMember do
  use Ecto.Migration

  def up do
  	alter table(:members) do
  	 add :civil_status, :string
  	 add :male?, :boolean
  	 add :female?, :boolean
     add :age_from, :integer
     add :age_to, :integer
  	end
  end

  def down do
  	alter table(:members) do
  	 remove :civil_status
  	 remove :male?
  	 remove :female?
     remove :age_from
     remove :age_to
  	end
  end

end
