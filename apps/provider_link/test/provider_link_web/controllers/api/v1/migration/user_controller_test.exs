defmodule ProviderLinkWeb.Api.V1.Migration.UserControllerTest do
  use ProviderLinkWeb.ConnCase
  # use ProviderLinkWeb.SchemaCase

  import ProviderLinkWeb.TestHelper

  setup do
    conn = build_conn()

    user =
      :user
      |> insert(%{username: "masteradmin", password: "P@ssw0rd"})

    conn =
      conn
      |> sign_in(user)

    {:ok, %{conn: conn}}
  end

  test "create_batch_user returns no data", %{conn: conn} do
    params = %{}

    conn =
      conn
      |> post(api_user_path(conn, :create_batch_user), params)

    result = json_response(conn, 400)
    assert result["message"] == "No data provided"
  end

  test "create_batch_user returns params not exists", %{conn: conn} do
    params = %{
      "test" => ""
    }

    conn =
      conn
      |> post(api_user_path(conn, :create_batch_user), params)

    result = json_response(conn, 400)
    assert result["message"] == "params does not exists"
  end

  test "create_batch_user returns params empty", %{conn: conn} do
    params = %{
      "params" => []
    }

    conn =
      conn
      |> post(api_user_path(conn, :create_batch_user), params)

    result = json_response(conn, 400)
    assert result["message"] == "params list is empty"
  end

  # test "create_batch_user with invalid params", %{conn: conn} do
  #   params = %{
  #     "params": [
  #       %{
  #         "username": "test",
  #         "password": "password",
  #         "provider_code": "880000000015491",
  #         "mobile": "9156826861",
  #         "last_name": "test1",
  #         "first_name": "test1",
  #         "middle_name": "testm1",
  #         "extension": "test1",
  #         "email": "test_emaiedilink.com.ph",
  #       }
  #     ]
  #   }

  #   conn =
  #     conn
  #     |> post(user_path(conn, :create_batch_user), params)

  #   result = json_response(conn, 200)

  #   assert List.first(result)["username"] == ["Please enter at least 8 characters"]
  #   assert List.first(result)["password"] == ["Password must be at least 8 characters and should contain alpha-numeric, special-character, atleast 1 capital letter"]
  #   assert List.first(result)["provider_code"] == ["Provider code does not exists"]
  #   assert List.first(result)["role"] == ["This is a required field."]
  #   assert List.first(result)["mobile"] == ["The Mobile number you have entered is invalid"]
  #   assert List.first(result)["last_name"] == ["The last name you have entered is invalid"]
  #   assert List.first(result)["first_name"] == ["The first name you have entered is invalid"]
  #   assert List.first(result)["middle_name"] == ["The middle name you have entered is invalid"]
  #   assert List.first(result)["extension"] == ["The extension you have entered is invalid"]
  #   assert List.first(result)["email"] == ["The email you have entered is invalid"]
  #   assert List.first(result)["department"] == ["This is a required field."]
  #   assert List.first(result)["is_success"] == false
  # end

  test "create_batch_user with valid params", %{conn: conn} do
    :provider
    |> insert(code: "880000000015491")

    params = %{
      "params" => [
        %{
          "username" => "test1236",
          "password" => "P@ssw0rd",
          "provider_code" => "880000000015491",
          "role" => "admin",
          "mobile" => "09156826861",
          "last_name" => "test",
          "first_name" => "testf",
          "middle_name" => "testm",
          "extension" => "teste",
          "email" => "test_email@medilink.com.ph",
          "department" => "test dep",
          "paylink_user_id" => "test_paylink"
        }
      ]
    }

    conn =
      conn
      |> post(api_user_path(conn, :create_batch_user), params)

    result = json_response(conn, 200)

    assert List.first(result)["is_success"] == true
    assert List.first(result)["username"] == "test1236"
    assert List.first(result)["provider_code"] == "880000000015491"
  end

end
