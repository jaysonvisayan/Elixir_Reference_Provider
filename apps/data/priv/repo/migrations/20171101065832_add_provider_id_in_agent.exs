defmodule Data.Repo.Migrations.AddProviderIdInAgent do
  use Ecto.Migration

  def change do
    alter table(:agents) do
      add :user_id, references(:users,
                               type: :binary_id,
                               on_delete: :delete_all)
      add :provider_id, references(:providers,
                                   type: :binary_id,
                                   on_delete: :nothing)
    end
  end
end
