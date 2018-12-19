defmodule ProviderLinkWeb.Api.V1.UserControllerTest do
  use ProviderLinkWeb.ConnCase
  # use ProviderLinkWeb.SchemaCase

  import ProviderLinkWeb.TestHelper

  setup do
    conn = build_conn()

    user = insert(:user, username: "masteradmin")
    provider = insert(:provider)
    agent = insert(:agent, first_name: "test", last_name: "test",
                   email: "masteradmin@yahoo.com", user: user,
                  provider: provider)

    conn =
      conn
      |> sign_in(user)

    {:ok, %{conn: conn, provider: provider, agent: agent}}
  end

  describe "get user" do
    test "with no username parameter", %{conn: conn} do
      params = %{}

      conn =
        conn
        |> post(api_user_path(conn, :get_users), params)

      result = json_response(conn, 400)
      assert result["message"] == "username is required"
    end

    test "with no username value", %{conn: conn} do
      params = %{"username" => ""}

      conn =
        conn
        |> post(api_user_path(conn, :get_users), params)

      result = json_response(conn, 400)
      assert result["message"] == "Please specify username value"
    end

    test "with valid parameters but returns no result", %{conn: conn} do
      params = %{"username" => "masteradmin2"}

      conn =
        conn
        |> post(api_user_path(conn, :get_users), params)

      result = json_response(conn, 400)
      assert result["message"] == "User Not Found"
    end

    test "with valid parameters and returns result", %{conn: conn} do
      params = %{"username" => "masteradmin"}

      conn =
        conn
        |> post(api_user_path(conn, :get_users), params)

      result = json_response(conn, 200)

      assert result["email"] == "masteradmin@yahoo.com"
      assert result["username"] == "masteradmin"
      assert result["provider_code"] == "880000000006035"
      assert result["provider_name"] == "Makati Medical Center"
    end
  end

  describe "user_update" do
    test "with no parameters", %{conn: conn} do
      params = %{}

      conn =
        conn
        |> put(api_user_path(conn, :user_update), params)

      result = json_response(conn, 403)
      errors = result["errors"]
      assert errors["password"]  == ["can't be blank"]
      assert errors["username"]  == ["can't be blank"]
    end

    test "with no username ", %{conn: conn} do
      params = %{"username" => "","password" =>"P@ssw0rd" }

      conn =
        conn
        |> put(api_user_path(conn, :user_update), params)

      result = json_response(conn, 403)
      errors = result["errors"]
      assert errors["username"] == ["can't be blank"]
    end

    test "with no password ", %{conn: conn} do
      params = %{"username" => "masteradmin","password" =>"" }

      conn =
        conn
        |> put(api_user_path(conn, :user_update), params)

      result = json_response(conn, 403)
      errors = result["errors"]
      assert errors["password"] == ["can't be blank"]
    end

    test "with valid password and username", %{conn: conn} do
      params = %{"username" => "masteradmin","password" => "P@ssw0rd"}

      conn =
        conn
        |> put(api_user_path(conn, :user_update), params)

      result = json_response(conn, 200)
      assert result["message"] == "Password Successfully Updated!"
    end

    test "with invalid username", %{conn: conn} do
      params = %{
        "username" => "password",
        "password" => "P@ssw0rd"
      }

      conn =
        conn
        |> put(api_user_path(conn, :user_update), params)

      result = json_response(conn, 400)
      assert result["message"] ==  "User not found"
    end
  end

end
