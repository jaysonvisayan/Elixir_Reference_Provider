defmodule Data.Seeders.MemberSeederTest do
  use Data.SchemaCase

  alias Data.Seeders.MemberSeeder

  @payorlink_member_id "0b4858fe-99f5-4024-9a4f-547943ee077c"
  @first_name "Jayson"
  @middle_name "Junnie"
  @last_name "Boy"
  @extension "Mr."
  @gender "Male"
  @birth_date "1997-09-21"
  @pin "1234"
  @pin_expires_at Ecto.DateTime.cast!("2017-10-31T13:58:46Z")

  test "seed member with new data" do
    [m1] = MemberSeeder.seed(data())
    assert m1.payorlink_member_id == @payorlink_member_id
  end

  test "seed member with existing data" do
    payor = insert(:payor)
    insert(:member, payorlink_member_id: @payorlink_member_id, payor: payor)
    [m1] = MemberSeeder.seed(data())
    assert m1.payorlink_member_id == @payorlink_member_id
  end

  defp data do
    [
      %{
        payorlink_member_id: @payorlink_member_id,
        first_name: @first_name,
        middle_name: @middle_name,
        last_name: @last_name,
        extension: @extension,
        gender: @gender,
        birth_date: @birth_date,
        pin: @pin,
        pin_expires_at: @pin_expires_at
      }
    ]
  end

end
