defmodule Data.Repo.Migrations.AddFieldsInLoa do
  use Ecto.Migration

 def change do
    alter table(:loas) do
      add :member_first_name, :string
      add :member_middle_name, :string
      add :member_last_name, :string
      add :member_suffix, :string
      add :member_birth_date, :date
      add :member_age, :integer
      add :member_card_no, :string
    end
  end
end
