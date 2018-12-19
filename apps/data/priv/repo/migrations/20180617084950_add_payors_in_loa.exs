defmodule Data.Repo.Migrations.AddPayorsInLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :payor_id, references(:payors,
          type: :binary_id,
          on_delete: :nothing)
      add :availment_date, :utc_datetime
    end
  end
end
