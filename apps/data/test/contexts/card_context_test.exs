defmodule Data.Contexts.CardContextTest do
  use Data.SchemaCase

  alias Data.Contexts.CardContext
  alias Ecto.UUID

  test "get_card with valid number" do
    card = insert(:card, number: "1234567890123456")
    result = CardContext.get_card("1234567890123456")

    assert result.number == card.number
  end

  test "get_card with invalid number" do
    insert(:card, number: "1234567890123456")
    result = CardContext.get_card("123456789012345")

    assert result == nil
  end

  test "insert_card with valid params" do
    member =
      :member
      |> insert

    params = %{
      number: "1234567890123456",
      member_id: member.id,
      payorlink_member_id: UUID.generate
    }

    {status, result} = CardContext.insert_card(params)

    assert status == :ok
    assert result.number == "1234567890123456"
  end

  test "insert_card with invalid params" do
    params = %{
      number: "1234567890123456",
    }

    {status, result} = CardContext.insert_card(params)

    assert status == :error
    refute result.valid?
  end

  test "update_card with valid params" do
    card = insert(:card)
    member =
      :member
      |> insert

    params = %{
      number: "1234567890123456",
      member_id: member.id,
      payorlink_member_id: UUID.generate
    }

    {status, result} = CardContext.update_card(card, params)

    assert status == :ok
    assert result.number == "1234567890123456"
  end

  test "update_card with invalid params" do
    card = insert(:card)

    params = %{
      number: "1234567890123456",
    }

    {status, result} = CardContext.update_card(card, params)

    assert status == :error
    refute result.valid?
  end
end
