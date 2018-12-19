defmodule Data.Schemas.LoaDoctor do
  @moduledoc """
  """

  use Data.Schema

  schema "loa_doctors" do
    belongs_to :loa, Data.Schemas.Loa
    belongs_to :doctor, Data.Schemas.Doctor

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :loa_id,
      :doctor_id
    ])
    |> validate_required([
      :loa_id,
      :doctor_id
    ])
  end
end
