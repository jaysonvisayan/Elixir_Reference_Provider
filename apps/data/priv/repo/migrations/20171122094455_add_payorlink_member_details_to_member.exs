defmodule Data.Repo.Migrations.AddPayorlinkMemberDetailsToMember do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :number_of_dependents, :string
      add :principal, :string
      add :relationship, :string
      add :email_address, :string
      add :email_address2, :string
      add :mobile2, :string
      add :number_of_consultations, :string
    end
  end
end
