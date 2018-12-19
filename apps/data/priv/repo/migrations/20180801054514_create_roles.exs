defmodule Data.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :status, :string
      add :created_by_id, :binary_id
      add :updated_by_id, :binary_id
      add :step, :integer, default: 1
      add :approval_limit, :decimal

      add :pii, :boolean, default: false
      add :create_full_access, :string
      add :no_of_days, :integer
      add :cut_off_dates, {:array, :integer}
      add :member_permitted, :boolean, default: false

      timestamps()
    end
    create unique_index(:roles, [:name])
  end
end
