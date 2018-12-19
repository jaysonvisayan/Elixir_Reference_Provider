defmodule Data.Repo.Migrations.AddFileNameInAsm do
  use Ecto.Migration

  def change do
    alter table(:acu_schedule_members) do
      add :file_name, :string
    end
  end
end
