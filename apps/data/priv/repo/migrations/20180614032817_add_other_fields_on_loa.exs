defmodule Data.Repo.Migrations.AddOtherFieldsOnLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :payorlink_member_id, :string
      add :member_evoucher_number, :string
      add :member_evoucher_qr_code, :string
      add :member_male?, :boolean
      add :member_female?, :boolean
      add :member_status, :string
      add :member_email, :string
      add :member_mobile, :string
      add :member_type, :string
      add :member_account_code, :string
      add :member_account_name, :string
      add :member_gender, :string
    end
  end
end
