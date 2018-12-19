defmodule Data.Schemas.LoaDoctorTest do
  use Data.SchemaCase

  alias Data.Schemas.LoaDoctor
  alias Ecto.UUID

  test "create_changeset with valid params" do
    params = %{
      loa_id: UUID.bingenerate(),
      doctor_id: UUID.bingenerate()
    }

    result =
      %LoaDoctor{}
      |> LoaDoctor.create_changeset(params)

    assert result.valid?
  end

  test "create_changeset with invalid params" do
    params = %{
      doctor_id: UUID.bingenerate()
    }

    result =
      %LoaDoctor{}
      |> LoaDoctor.create_changeset(params)

    refute result.valid?
  end
end
