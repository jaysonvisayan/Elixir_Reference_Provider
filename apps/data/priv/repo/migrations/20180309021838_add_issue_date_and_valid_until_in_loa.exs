defmodule Data.Repo.Migrations.AddIssueDateAndValidUntilInLoa do
  use Ecto.Migration

  def change do
  	alter table(:loas) do
  	 add :issue_date, :date
  	 add :valid_until, :date
  	end
  end
end
