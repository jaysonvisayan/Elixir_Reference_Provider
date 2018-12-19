defmodule Data.Repo.Migrations.RenameIsPeme do
  use Ecto.Migration

  def up do
    rename table(:loas), :is_peme?, to: :is_peme
  end

  def down do
    rename table(:loas), :is_peme, to: :is_peme?
  end
end
