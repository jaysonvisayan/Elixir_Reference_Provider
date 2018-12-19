defmodule ProviderLinkWeb.Api.V1.LoaControllerTest do
  use ProviderLinkWeb.ConnCase
  # use ProviderLinkWeb.SchemaCase

  import ProviderLinkWeb.TestHelper

  alias Ecto.UUID

  setup do
    conn = build_conn()

    user =
      :user
      |> insert

    conn =
      conn
      |> sign_in(user)

    {:ok, %{conn: conn, user: user}}
  end

  test "create_loa creates loa when params is valid", %{conn: conn, user: user} do
    :payor
    |> insert(
      code: "Maxicar"
    )

    params = %{
      "total_amount" => "100.00",
      "status" => "approved",
      "payor_pays" => "0.00",
      "member_pays" => "100.00",
      "loa_number" => "119212",
      "created_by_id" => user.id,
      "coverage" => "acu",
      "consultation_date" => "2018-12-12T12:12:12",
      "valid_until" => "2018-12-12",
      "issue_date" => "2018-12-12T12:12:12",
      "origin" => "payorlink",
      "payorlink_authorization_id" => UUID.generate,
      "member" => %{
        "payorlink_member_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "last_name" => "Dela Cruz",
        "gender" => "Female",
        "first_name" => "Janna",
        "birth_date" => "1992-07-30",
        "card_number" => "2832983238923"
      },
      "provider" => %{
        "payorlink_facility_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "name" => "Makati Medical Center Inc",
        "code" => "880000000006036",
        "phone_no" => "7656734",
        "email_address" => "g@medilink.com.ph",
        "line_1" => "Dela Rosa Street",
        "line_2" => "Legazpi Village",
        "city" => "Makati",
        "province" => "Metro Manila",
        "region" => "NCR",
        "country" => "Philippines",
        "postal_code" => "1200"
      },
      "request_date" => "2013-12-12T12:12:12"
    }

    conn =
      conn
      |> post(api_loa_path(conn, :create_loa), params)

    result =
      conn
      |> json_response(200)

    assert result["status"] == "ok"
    assert result["loa"] == params
  end

  test "create_loa creates loa when params is invalid", %{conn: conn, user: user} do
    params = %{
      "total_amount" => "100.00",
      "status" => "approved",
      "payor_pays" => "0.00",
      "member_pays" => "100.00",
      "loa_number" => "119212",
      "created_by_id" => user.id,
      "coverage" => "acu",
      "consultation_date" => "2018-12-12",
      "valid_until" => "2018-12-12",
      "member" => %{
        "payorlink_member_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "last_name" => "Dela Cruz",
        "gender" => "Female",
        "first_name" => "Janna",
        "birth_date" => "1992-07-30",
        "card_number" => "2832983238923"
      },
      "provider" => %{
        "payorlink_facility_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "name" => "Makati Medical Center Inc",
        "code" => "880000000006036"
      }
    }

    conn =
      conn
      |> post(api_loa_path(conn, :create_loa), params)

    result =
      conn
      |> json_response(400)

    assert result["status"] == "error"
    assert result["loa"]["issue_date"] == "Issue date is required"
  end

  test "create_loa does not create loa when member details does not exists", %{conn: conn, user: user} do
    params = %{
      "total_amount" => "100.00",
      "status" => "approved",
      "payor_pays" => "0.00",
      "member_pays" => "100.00",
      "loa_number" => "119212",
      "created_by_id" => user.id,
      "coverage" => "acu",
      "consultation_date" => "2018-12-12",
      "valid_until" => "2018-12-12",
      "issue_date" => "2018-12-12",
      "provider" => %{
        "payorlink_facility_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "name" => "Makati Medical Center Inc",
        "code" => "880000000006036"
      }
    }

    conn =
      conn
      |> post(api_loa_path(conn, :create_loa), params)

    result =
      conn
      |> json_response(400)

    assert result["status"] == "error"
    assert result["loa"]["member"] == %{
      "birth_date" => "Birth date is required",
      "card_number" => "Card number is required",
      "first_name" => "First name is required",
      "gender" => "Gender is required",
      "last_name" => "Last name is required",
      "payorlink_member_id" => "Payorlink member id is required"
    }
  end

  test "create_loa does not create loa when provider details does not exists", %{conn: conn, user: user} do
    params = %{
      "total_amount" => "100.00",
      "status" => "approved",
      "payor_pays" => "0.00",
      "member_pays" => "100.00",
      "loa_number" => "119212",
      "created_by_id" => user.id,
      "coverage" => "acu",
      "consultation_date" => "2018-12-12",
      "valid_until" => "2018-12-12",
      "issue_date" => "2018-12-12",
      "member" => %{
        "payorlink_member_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "last_name" => "Dela Cruz",
        "gender" => "Female",
        "first_name" => "Janna",
        "birth_date" => "1992-07-30",
        "card_number" => "2832983238923"
      },
    }

    conn =
      conn
      |> post(api_loa_path(conn, :create_loa), params)

    result =
      conn
      |> json_response(400)

    assert result["status"] == "error"
    assert result["loa"]["provider"] == %{
      "code" => "Code is required",
      "name" => "Name is required",
      "payorlink_facility_id" => "Payorlink facility id is required"
    }
  end

  describe "Updates acu loa status " do
    test "with valid params", %{conn: conn} do
      provider = insert(:provider)
      acu_schedule = insert(:acu_schedule, provider_id: provider.id, date_to: Ecto.Date.utc(), date_from: Ecto.Date.utc(), no_of_guaranteed: 0, guaranteed_amount: Decimal.new(1000))
      member = insert(:member)
      card = insert(:card, member: member)
      loa = insert(:loa, card: card)
      params = %{
        loa_ids: [loa.id],
        acu_schedule_ids: [acu_schedule.id]
      }
    result =
      conn
      |> post(api_loa_path(conn, :update_acu_loa_status), params)
      |> json_response(200)

    assert result["message"] == "Loas Successfully Updated Status as Stale"
    end
  end
end
