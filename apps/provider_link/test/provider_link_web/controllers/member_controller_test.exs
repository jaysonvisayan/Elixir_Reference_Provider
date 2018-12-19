defmodule ProviderLinkWeb.MemberControllerTest do
  use ProviderLinkWeb.ConnCase
  # import ProviderLinkWeb.TestHelper
  use ProviderLinkWeb.SchemaCase

  # setup do
  #   conn = build_conn()
  #   user = insert(:user)
  #   conn = sign_in(conn, user)
  #   {:ok, %{conn: conn, user: user}}
  # end

  # test "validate number renders error json when card number is not 16-digit are invalid", %{conn: conn, user: user} do
  #   member = insert(:member)
  #   card = insert(:card, member: member)
  #   insert(:loa, card: card)
  #   number = "1"
  #   bdate = "1992-01-01"

  #   provider = insert(:provider)
  #   insert(:agent, provider: provider, user: user)

  #   conn =
  #     conn
  #     |> get("/loas/card/#{number}/with_loa_validation/#{bdate}/ACU", %{"number": number})
  #   assert json_response(conn, 200) == %{"message" => "Card Number should be 16-digit"}
  # end

  # # test "validate cvv renders error json when cvv is not 3-digit", %{conn: conn} do
  # #   member = insert(:member)
  # #   insert(:card, member: member)
  # #   number = "0123456789123456"
  # #   cvv = "12"
  # #   conn =
  # #     conn
  # #     |> get("/members/card/#{number}/#{cvv}", %{"number": number, "cvv": cvv})
  # #   assert json_response(conn, 200) == %{"message" => "CVV should be 3-digit"}
  # # end

  # test "validate_pin renders loa when parameters are valid", %{conn: conn} do
  #   member = insert(:member, type: "principal")
  #   card = insert(:card, member: member)
  #   provider = insert(:provider)
  #   insert(:loa, status: "approved", card: card, provider: provider)
  #   id = member.id
  #   pin = "1234"
  #   conn =
  #     conn
  #     |> get("/members/pin/#{id}/#{pin}", %{"id": id, "pin": pin})
  #     assert json_response(conn, 200)["id"] == member.id
  # end

  # test "validate_pin renders error when pin is not 4-digit", %{conn: conn} do
  #   member = insert(:member)
  #   card = insert(:card, member: member)
  #   provider = insert(:provider)
  #   insert(:loa, card: card, provider: provider)
  #   id = member.id
  #   pin = "12345"
  #   conn =
  #     conn
  #     |> get("/members/pin/#{id}/#{pin}", %{"id": id, "pin": pin})
  #   assert json_response(conn, 200) == %{"message" => "Pin should be 4-digit"}
  # end

  # test "validate_pin renders error when pin is already expired", %{conn: conn} do
  #     utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds
  #     pin_expiry = (utc - 1 * 60)
  #     |> :calendar.gregorian_seconds_to_datetime
  #     |> Ecto.DateTime.cast!
  #   member = insert(:member, pin: "2345", pin_expires_at: pin_expiry)
  #   card = insert(:card, member: member)
  #   provider = insert(:provider)
  #   insert(:loa, card: card, provider: provider)
  #   id = member.id
  #   pin = "2345"
  #   conn =
  #     conn
  #     |> get("/members/pin/#{id}/#{pin}", %{"id": id, "pin": pin})
  #   assert json_response(conn, 200) == %{"message" => "Pin already expired"}
  # end

end
