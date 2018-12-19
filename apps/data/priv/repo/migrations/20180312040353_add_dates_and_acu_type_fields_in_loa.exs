defmodule Data.Repo.Migrations.AddDatesAndAcuTypeFieldsInLoa do
  use Ecto.Migration

  def change do
  	alter table(:loas) do
  	 add :admission_date, :utc_datetime
  	 add :discharge_date, :utc_datetime
  	 add :request_date, :utc_datetime
     add :acu_type, :string
  	end
  end
end
