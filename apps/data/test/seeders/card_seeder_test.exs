defmodule Data.Seeders.CardSeederTest do
  use Data.SchemaCase

  alias Data.Seeders.CardSeeder
  alias Ecto.UUID

  @number "1234567891234567"
  @cvv "123"

  test "seed card with new data" do
    member = insert(:member)
    [c1] = CardSeeder.seed(data(member))
    assert c1.number == @number
  end

  test "seed amount with existing data" do
    member = insert(:member)
    card = insert(:card, number: @number)
    [c1] = CardSeeder.seed(data(member))
    assert c1.number == card.number
  end

  defp data(member) do
    [
      %{
        member_id: member.id,
        number: @number,
        cvv: @cvv,
        payorlink_member_id: UUID.generate
      }
    ]
  end

end
