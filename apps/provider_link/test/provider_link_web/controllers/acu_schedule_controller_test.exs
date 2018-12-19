defmodule ProviderLinkWeb.AcuScheduleControllerTest do
  use ProviderLinkWeb.ConnCase
  # import ProviderLinkWeb.TestHelper
  # use ProviderLinkWeb.SchemaCase

  setup do
    conn = build_conn()
    user = fixture(:user_permission, %{keyword: "manage_providerlink_acu_schedules", module: "ProviderLink_Acu_Schedules"})
    conn = authenticated(conn, user)
    provider = insert(:provider, prescription_term: 30)
    insert(:agent, user: user, provider: provider)
    acu_schedule = insert(:acu_schedule, provider_id: provider.id, date_to: Ecto.Date.utc(), date_from: Ecto.Date.utc(), no_of_guaranteed: 0, guaranteed_amount: Decimal.new(1000))
    # conn = sign_in(conn, user)
    {:ok, %{conn: conn, user: user, acu_schedule: acu_schedule}}
  end

  # @params %{
  #   "batch_no" => Enum.random(100000..999999),
  #   "account_code" => "C00918",
  #   "account_name" => "Jollibee World Wide",
  #   "date_to" => Ecto.Date.utc(),
  #   "date_from" => Ecto.Date.utc(),
  #   "no_of_members" => 5,
  #   "no_of_guaranteed" => 4,
  #   "payorlink_acu_schedule_id" => "74e4c08f-f325-4e3f-aec0-6757ada2b454",
  #   "created_by" => "MasterAdmin"
  # }

  test "index get all acu_schedules", %{conn: conn} do
    conn = get conn, "/acu_schedules"
    assert html_response(conn, 200) =~ "ACU Schedules"
  end

  test "render_upload", %{conn: conn, acu_schedule: acu_schedule} do
    loa = insert(:loa, total_amount: Decimal.new(1000))
    insert(:acu_schedule_member, acu_schedule: acu_schedule, loa: loa, status: "Encoded")
    conn = get conn, "/acu_schedules/#{acu_schedule.id}/upload"
    assert html_response(conn, 200) =~ "Upload ACU Schedule"
  end

  test "member_index", %{conn: conn, acu_schedule: acu_schedule} do
    card = insert(:card, number: "123123")
    insert(:member, card: card)
    loa = insert(:loa, member_first_name: "Test", member_middle_name: "Test", member_last_name: "Test", member_card_no: "Test")
    insert(:acu_schedule_member, acu_schedule_id: acu_schedule.id, loa: loa)
    conn = get conn, "/acu_schedules/#{acu_schedule.id}/members"
    assert html_response(conn, 200) =~ "ACU Members"
  end

  # test "create_schedule/2 success", %{conn: conn} do
  #   package = package()
  #   [m1, m2, m3, m4] = member_ids()
  #   insert_members([m1, m2, m3, m4])
  #   package1 = Enum.at(package, 0)
  #   members = [
  #     %{"benefit_package_id" => package1["payorlink_benefit_package_id"], "member_id" => m1},
  #     %{"benefit_package_id" => package1["payorlink_benefit_package_id"], "member_id" => m2},
  #     %{"benefit_package_id" => package1["payorlink_benefit_package_id"], "member_id" => m3},
  #     %{"benefit_package_id" => package1["payorlink_benefit_package_id"], "member_id" => m4}
  #   ]
  #   params =
  #     @params
  #     |> Map.put("members", members)
  #     |> Map.put("packages", package)

  #   conn = post conn, acu_schedule_path(conn, :create_schedule), params

  #   assert json_response(conn, 200)["success"] == "ACU Schedule successfully inserted."
  # end

  # test "create_schedule/2 failed", %{conn: conn} do
  #   package = package()
  #   [m1, m2, m3, m4] = member_ids()
  #   insert_members([m1, m2, m3, m4])
  #   members = []
  #   params =
  #     @params
  #     |> Map.put("members", members)
  #     |> Map.put("packages", package)

  #   conn = post conn, acu_schedule_path(conn, :create_schedule), params

  #   assert json_response(conn, 400)["error"] == "Error inserting ACU Schedule."
  # end

  # test "submit_upload", %{conn: conn} do
  #   m1 = insert(:member)
  #   m2 = insert(:member)
  #   m3 = insert(:member)
  #   m4 = insert(:member)
  #   as = insert(:acu_schedule, batch_no: 1)
  #   loa1 = insert(:loa, member: m1, payorlink_authorization_id: m1.id)
  #   loa2 = insert(:loa, member: m3, payorlink_authorization_id: m2.id)
  #   loa3 = insert(:loa, member: m3, payorlink_authorization_id: m2.id)
  #   loa4 = insert(:loa, member: m3, payorlink_authorization_id: m2.id)
  #   insert(:acu_schedule_member, acu_schedule: as, member: m1, loa: loa1, loa_status: "IBNR",  status: "Encoded")
  #   insert(:acu_schedule_member, acu_schedule: as, member: m3, loa: loa2, loa_status: "IBNR",  status: "Encoded")
  #   insert(:acu_schedule_member, acu_schedule: as, member: m2, loa: loa3)
  #   insert(:acu_schedule_member, acu_schedule: as, member: m4, loa: loa4)
  #   conn = post conn, acu_schedule_path(conn, :submit_upload, as.id)
  # end

  # defp package do
  #   Enum.into(0..1, [], fn(_) ->
  #     %{
  #       "code" => "PackageCode",
  #       "name" =>  "PackageName",
  #       "description" => "PackageDescription",
  #       "payorlink_benefit_package_id" => Ecto.UUID.generate()
  #      }
  #   end)
  # end

  # defp member_ids do
  #   Enum.into(1..4, [], fn(_) -> Ecto.UUID.generate() end)
  # end

  # defp insert_members(params) do
  #   Enum.each(params, &(insert(:member, payorlink_member_id: &1)))
  # end

end
