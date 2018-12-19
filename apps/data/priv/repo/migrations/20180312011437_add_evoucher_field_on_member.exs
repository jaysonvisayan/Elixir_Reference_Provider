defmodule Data.Repo.Migrations.AddEvoucherFieldOnMember do
  use Ecto.Migration

  def change do
  	alter table(:members) do
      add :evoucher_number, :string
      add :evoucher_qr_code, :string
    end
  end
end
