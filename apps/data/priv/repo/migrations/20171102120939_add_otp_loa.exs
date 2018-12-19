defmodule Data.Repo.Migrations.AddOtpLoa do
  use Ecto.Migration

  def change do
    alter table(:loas) do
      add :otp, :string
    end
  end
end
