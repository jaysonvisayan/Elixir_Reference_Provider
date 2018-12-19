defmodule Data.Schemas.CardTest do
  use Data.SchemaCase

  alias Data.Schemas.Card
  alias Ecto.UUID

  test "changeset with valid params" do
    params = %{
      payorlink_member_id: UUID.bingenerate,
      number: "12213213",
      member_id: UUID.bingenerate
    }

    result =
      %Card{}
      |> Card.changeset(params)

    assert result.valid?
  end

  test "changeset with invalid params" do
    params = %{
      number: "12213213",
      member_id: UUID.bingenerate
    }

    result =
      %Card{}
      |> Card.changeset(params)

    refute result.valid?
  end
end
