defmodule Data.Repo.Migrations.AddRemarksToMember do
  use Ecto.Migration

  def up do
  	alter table(:members) do
  	 add :remarks, :string
  	end
  end

  def down do
  	alter table(:members) do
  	 remove :remarks
  	end
  end
end
