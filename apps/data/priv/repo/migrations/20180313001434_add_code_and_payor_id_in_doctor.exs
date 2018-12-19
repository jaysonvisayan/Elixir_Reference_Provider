defmodule Data.Repo.Migrations.AddCodeAndPayorIdInDoctor do
  use Ecto.Migration

  def change do
    alter table(:doctors) do
      add :payor_id, references(:payors, type: :binary_id, on_delete: :nothing)
      add :code, :string
      add :payorlink_practitioner_id, :binary_id
    end
  end
end
