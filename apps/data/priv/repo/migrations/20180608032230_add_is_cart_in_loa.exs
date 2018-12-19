defmodule Data.Repo.Migrations.AddIsCartInLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :is_cart, :boolean, default: false
      add :is_batch, :boolean, default: false
    end
  end
end
