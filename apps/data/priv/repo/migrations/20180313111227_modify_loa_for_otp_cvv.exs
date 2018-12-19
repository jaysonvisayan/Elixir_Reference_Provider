defmodule Data.Repo.Migrations.ModifyLoaForOtpCvv do
  use Ecto.Migration

  def up do
  	alter table(:loas) do
  	 remove :otp
  	 add :otp, :boolean
  	 add :pin, :string
  	 add :pin_expires_at, :utc_datetime
  	end
  end

  def down do
  	alter table(:loas) do
  	 add :otp, :string
  	 remove :otp
  	 remove :pin
  	 remove :pin_expires_at
  	end
  end
end
