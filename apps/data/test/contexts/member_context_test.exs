defmodule Data.MemberContextTest do
  use Data.SchemaCase

  alias Data.Contexts.MemberContext
  alias Ecto.UUID

  setup do
    member = insert(:member, first_name: "Junnie", birth_date: Ecto.Date.cast!("1995-12-12"))
    card = :card
           |> insert(number: "1234567891234567")
           |> Repo.preload([:member, :loa])

    {:ok, %{member: member, card: card}}
  end

  test "get member returns member when member id is valid", %{member: member} do
    assert member |> preload() == MemberContext.get_member(member.id)
  end

  test "get member returns nil when member id is invalid" do
    assert nil == MemberContext.get_member("5ec5c72e-2978-4d0e-8990-611934c1cb96")
  end

  test "get_member/1 returns the member with given id" do
    member = :member |> insert() |> preload()
    assert member == member.id |> MemberContext.get_member() |> preload()
  end

  test "get_card/1 returns the card with given id", %{card: card} do
    assert card == MemberContext.get_card(card.id)
  end

  test "get_card_by_number/1 returns the card with given number", %{card: card} do
    assert card == MemberContext.get_card_by_number(card.number)
  end

  # test "validate_card_number/1 returns error when card number is not a 16-digit" do
  #   card_number = "123456789"
  #   test_provider = "600026666"
  #   cvv = "123"
  #   coverage = "ACU"
  #   conn = ""

  #   assert {:invalid_number_length} ==
  #     MemberContext.validate_number(conn, card_number, cvv, test_provider, coverage)
  # end

  # test "validate_card_number/1 returns error when card number is empty" do
  #   card_number = ""
  #   test_provider = "600026666"
  #   cvv = '333'
  #   coverage = "ACU"
  #   conn = ""

  #   assert {:empty_number} == MemberContext.validate_number(conn, card_number, cvv, test_provider, coverage)
  # end

  defp preload(member), do: Repo.preload(member, [:loa, :card, :payor])

  test "insert_card insert card with valid params" do
    member =
      :member
      |> insert

    params = %{
      number: "1092012392013",
      payorlink_member_id: UUID.generate,
      member_id: member.id
    }

    {status, result} =
      params
      |> MemberContext.insert_card

    assert status == :ok
    assert result.number == params.number
  end

  test "insert_card does not insert card with invalid params" do
    member =
      :member
      |> insert

    params = %{
      number: "1092012392013",
      member_id: member.id
    }

    {status, result} =
      params
      |> MemberContext.insert_card

    assert status == :error
    refute result.valid?
  end

  test "insert_member_not_exist with invalid params" do
    :payor
    |> insert(
      code: "Maxicar"
    )

    params = %{
      first_name: "test",
      payorlink_member_id: UUID.generate
    }

    {status, result} =
      params
      |> MemberContext.insert_member_not_exist

    assert status == :error
    refute result.valid?
  end

  test "insert_member_not_exist with new payorlink member id" do
    :payor
    |> insert(
      code: "Maxicar"
    )

    params = %{
      first_name: "test",
      payorlink_member_id: UUID.generate,
      last_name: "test",
      birth_date: "2018-12-12",
      gender: "Female",
      card_number: "312312312"
    }

    {status, result} =
      params
      |> MemberContext.insert_member_not_exist

    assert status == :ok
    assert result.first_name == params.first_name
    assert result.gender == params.gender
  end

  test "insert_member_not_exist with existing payorlink member id" do
    id = UUID.generate

    :payor
    |> insert(
      code: "Maxicar"
    )

    member =
      :member
      |> insert(
        payorlink_member_id: id,
        first_name: "test"
      )

    params = %{
      first_name: "test",
      payorlink_member_id: id,
      last_name: "test",
      birth_date: "2018-12-12",
      gender: "Female",
      card_number: "312312312"
    }

    {status, result} =
      params
      |> MemberContext.insert_member_not_exist

    assert status == :ok
    assert result.first_name == params.first_name
    assert result.id == member.id
    refute result.last_name == params.last_name
  end
end
