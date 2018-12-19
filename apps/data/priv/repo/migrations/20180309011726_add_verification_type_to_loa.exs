defmodule Data.Repo.Migrations.AddVerificationTypeToLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :verification_type, :string
    end
  end
end
