defmodule Data.Schemas.AcuSchedulePackage do
  @moduledoc """
  """

  use Data.Schema

  schema "acu_schedule_packages" do
    field :payorlink_benefit_package_id, :binary_id, primary_key: true
    field :code, :string
    field :name, :string
    field :description, :string

    belongs_to :acu_schedule, Data.Schemas.AcuSchedule
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :payorlink_benefit_package_id,
      :code,
      :name,
      :description,
      :acu_schedule_id
    ])
  end
end
