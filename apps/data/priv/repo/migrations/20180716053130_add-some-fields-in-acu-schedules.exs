defmodule :"Elixir.Data.Repo.Migrations.Add-some-fields-in-acu-schedules" do
  use Ecto.Migration

  def change do
    alter table(:acu_schedules) do
      add :guaranteed_amount, :decimal
      add :estimate_total_amount, :decimal
      add :actual_total_amount, :decimal
      add :soa_reference_no, :string
    end

    create unique_index(:acu_schedules, [:soa_reference_no])

  end
end
