defmodule Data.Schemas.BatchLoa do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "batch_loas" do
    belongs_to :batch, Data.Schemas.Batch
    belongs_to :loa, Data.Schemas.Loa

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
        :batch_id,
        :loa_id
      ])
    |> validate_required([
        :batch_id,
        :loa_id
      ])
  end
end
