defmodule Data.Repo.Migrations.AddProviderIdLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :provider_id, references(:providers,
                                   type: :binary_id,
                                   on_delete: :nothing)
    end
  end
end
