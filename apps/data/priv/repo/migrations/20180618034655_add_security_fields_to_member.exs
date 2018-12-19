defmodule Data.Repo.Migrations.AddSecurityFieldsToMember do
  use Ecto.Migration

  def up do
    alter table(:loas) do
      add :member_attempts, :integer
      add :member_attempt_expiry, :utc_datetime
    end
  end

  def down do
    alter table(:loas) do
      remove :member_attempts
      remove :member_attempt_expiry
    end
  end

end
