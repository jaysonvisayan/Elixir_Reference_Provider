defmodule Data.Repo.Migrations.RemoveMobileEmailInUser do
  use Ecto.Migration

  def up do
    alter table(:users) do
      remove :email
      remove :mobile
    end
  end

  def down do
    alter table(:users) do
      add :email, :string
      add :mobile, :string
    end
  end
end
