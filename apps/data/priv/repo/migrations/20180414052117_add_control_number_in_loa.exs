defmodule Data.Repo.Migrations.AddControlNumberInLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :control_number, :string
    end
  end
end
