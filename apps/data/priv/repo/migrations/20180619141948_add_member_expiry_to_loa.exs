defmodule Data.Repo.Migrations.AddMemberExpiryToLoa do
  use Ecto.Migration

  def up do
    alter table(:loas) do
     add :member_expiry_date, :date
    end
  end

  def down do
    alter table(:loas) do
     remove :member_expiry_date
    end
  end
end
