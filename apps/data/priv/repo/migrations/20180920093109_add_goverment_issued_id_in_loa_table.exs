defmodule Data.Repo.Migrations.AddGovermentIssuedIdInLoaTable do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :member_goverment_issued_id, :string
    end
  end
end
