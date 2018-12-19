defmodule Data.Repo.Migrations.AddPhotoToLoa do
  use Ecto.Migration

  def up do
  	alter table(:loas) do
  	 add :photo, :string
  	end
  end

  def down do
  	alter table(:loas) do
  	 remove :photo
  	end
  end
end
