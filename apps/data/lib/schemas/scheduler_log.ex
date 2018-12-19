defmodule Data.Schemas.SchedulerLog do
  @moduledoc """
  """
  use Data.Schema

  schema "scheduler_logs" do
    field :module_name, :string
    field :method_name, :string
    field :message, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :module_name,
      :method_name,
      :message
    ])
    |> validate_required([
      :module_name,
      :method_name,
      :message
    ])
  end
end
