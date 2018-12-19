defmodule Data.Schemas.MemberTest do
  use Data.SchemaCase

  alias Data.Schemas.Member
  alias Ecto.UUID

  test "changeset with valid params" do
    params = %{
      first_name: "test",
      last_name: "test",
      payorlink_member_id: UUID.generate,
      gender: "Female",
      birth_date: "2018-12-12"
    }

    result =
      %Member{}
      |> Member.changeset(params)

    assert result.valid?
  end

  test "changeset with invalid params" do
    params = %{
      first_name: "test",
      last_name: "test",
      payorlink_member_id: UUID.generate,
      gender: "Female"
    }

    result =
      %Member{}
      |> Member.changeset(params)

    refute result.valid?
  end
end
