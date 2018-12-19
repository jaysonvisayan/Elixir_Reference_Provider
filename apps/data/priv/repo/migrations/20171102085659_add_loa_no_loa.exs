defmodule Data.Repo.Migrations.AddLoaNoLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :loa_number, :string
    end
  end
end
