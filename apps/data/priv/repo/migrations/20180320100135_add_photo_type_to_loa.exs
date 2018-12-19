defmodule Data.Repo.Migrations.AddPhotoTypeToLoa do
  use Ecto.Migration

  def up do
  	alter table(:loas) do
  	 add :photo_type, :string
  	end
  end

  def down do
  	alter table(:loas) do
  	 remove :photo_type
  	end
  end
end
