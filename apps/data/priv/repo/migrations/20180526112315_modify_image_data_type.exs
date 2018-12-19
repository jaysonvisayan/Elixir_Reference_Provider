defmodule Data.Repo.Migrations.ModifyImageDataType do
  use Ecto.Migration

  def up do
  	alter table(:acu_schedule_members) do
  	 remove :image
  	 add :image, :string
  	end
  end

  def down do
  	alter table(:acu_schedule_members) do
  	 add :image, :text
  	end
  end
end
