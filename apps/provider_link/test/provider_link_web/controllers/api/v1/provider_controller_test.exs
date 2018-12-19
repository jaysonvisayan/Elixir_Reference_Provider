defmodule ProviderLinkWeb.Api.V1.ProviderControllerTest do
  use ProviderLinkWeb.ConnCase
  # use ProviderLinkWeb.SchemaCase

  import ProviderLinkWeb.TestHelper

  setup do
    conn = build_conn()

    user =
      :user
      |> insert

    conn =
      conn
      |> sign_in(user)

    {:ok, %{conn: conn}}
  end

  test "get acu schedule with valid parameters", %{conn: conn} do
    insert(:provider, %{code: "provider_code"})
    insert(:acu_schedule_member, %{is_availed: true})
    conn = get(conn, api_provider_path(conn, :get_acu_schedules, %{
      provider_code: "provider_code",
      account_code: "123"
    }))
    result = json_response(conn, 200)
    assert result == []
  end

  test "get acu schedule with invalid parameters", %{conn: conn} do
    conn = get(conn, api_provider_path(conn, :get_acu_schedules))
    result = json_response(conn, 400)
    assert result["message"] == "Invalid parameters!"
  end

end
