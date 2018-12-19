defmodule Data.Repo.Migrations.CreateCard do
  use Ecto.Migration

  def change do
    create table(:cards, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :member_id, references(:members,
                                 type: :binary_id,
                                 on_delete: :nothing)
      add :number, :string
      add :cvv, :string

      timestamps()
    end

      create unique_index(:cards, [:number])
  end
end
