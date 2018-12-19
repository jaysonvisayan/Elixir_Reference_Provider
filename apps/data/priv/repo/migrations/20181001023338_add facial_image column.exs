defmodule :"Elixir.Data.Repo.Migrations.Add facialImage column" do
  use Ecto.Migration

  def up do
    alter table(:loas) do
      add :facial_image, :string
    end
  end

  def down do
    alter table(:loas) do
      remove :facial_image
    end
  end

end
