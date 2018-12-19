defmodule ProviderLinkWeb.Api.V1.SessionControllerTest do
  use ProviderLinkWeb.ConnCase
  # use ProviderLinkWeb.SchemaCase

  import ProviderLinkWeb.TestHelper
  alias ProviderLinkWeb.Api.V1.ErrorView

  alias Data.Schemas.{
    User,
    Provider,
    Agent
  }

  setup do
    conn = build_conn()

    params = %{
      username: "janna_mamer",
      password: "P@ssw0rd",
      password_confirmation: "P@ssw0rd",
      pin: "validated"
    }

    user =
      %User{}
      |> User.create_changeset(params)
      |> Repo.insert!

    provider_params = %{
      payorlink_facility_id: "89dabc9d-c3a0-41c1-8eab-b79c3ebcb1ba",
      name: "DANIEL O MERCADO MEDICAL CENTER",
      code: "DMMC",
      phone_no: "999-9999",
      email_address: "dmmc@yahoo.com",
      line_1: "267",
      line_2: "",
      city: "Tanauan City",
      province: "Batangas",
      region: "CALABARZON",
      country: "Philippines",
      postal_code: "4232"
    }

    provider =
      %Provider{}
      |> Provider.create_changeset(provider_params)
      |> Repo.insert!

    agent_params = %{
      first_name: "Daniel Eduard",
      middle_name: "Murao",
      last_name: "Andal",
      extension: "Dr.",
      department: "Admin",
      role: "Admin",
      mobile: "09123456789",
      email: "andaldanieleduard@yahoo.com",
      verification_expiry: Ecto.DateTime.from_erl(:erlang.localtime),
      provider_id: provider.id,
      user_id: user.id
    }


    %Agent{}
    |> Agent.create_changeset(agent_params)
    |> Repo.insert!

    jwt =
      conn
      |> Guardian.Plug.current_token()

    conn =
      conn
      |> sign_in(user)
    {:ok, %{conn: conn, user: user, jwt: jwt}}
  end

  test "login user when params is valid", %{conn: conn, user: user} do
    params = %{
      username: "janna_mamer",
      password: "P@ssw0rd"
    }

    conn =
      conn
      |> post(api_session_path(conn, :login), params)

    result =
      conn
      |> json_response(200)

    assert result["user_id"] == user.id
    assert result["validated"] == true
  end

  test "login user when params is invalid", %{conn: conn} do
    params = %{
      username: "janna_mamer",
      password: "@ssw0rd"
    }

    conn =
      conn
      |> post(api_session_path(conn, :login), params)

    result =
      conn
      |> json_response(403)

    assert result["message"] == "The username or password you have entered is invalid"
  end

  # test "login when user is locked", %{conn: conn, user: user} do
  #   user
  #   |> User.login_attempt_changeset(%{
  #     attempt: 3,
  #     status: "locked"
  #   })
  #   |> Repo.update!

  #   params = %{
  #     username: "janna_mamer",
  #     password: "@ssw0rd"
  #   }

  #   conn =
  #     conn
  #     |> post(api_session_path(conn, :login), params)

  #   result =
  #     conn
  #     |> json_response(400)

  #   assert result["message"] == "Your account has been locked."
  # end

  test "login when user is not found", %{conn: conn} do
    params = %{
      username: "janna_delacruz",
      password: "@ssw0rd"
    }

    conn =
      conn
      |> post(api_session_path(conn, :login), params)

    result =
      conn
      |> json_response(404)

    assert result["message"] == "Not Found!"
  end

  test "login when no parameter", %{conn: conn} do
    conn =
      conn
      |> post(api_session_path(conn, :login))

    result =
      conn
      |> json_response(403)

    assert result["message"] == "Unauthorized"
  end

  test "logout with valid token", %{conn: conn, jwt: jwt} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> get(api_session_path(conn, :logout))

    assert json_response(conn, 200) == %{"message" => "Signed out!"}
  end

  test "logout with invalid token" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer 12313213213")
      |> recycle
      |> get("/api/v1/sign_out")

    assert json_response(conn, 401) == %{"error" => %{"message" => "Unauthorized"}}
  end

  test "logout without token" do
    conn =
      build_conn()
      |> get("/api/v1/sign_out")

    assert json_response(conn, 401) == %{"error" => %{"message" => "Unauthorized"}}
  end

  test "forgot_password returns error message when user's email is blank", %{conn: conn} do
    params = %{
      "username" => "test_user",
      "recovery" => "email",
      "text" => ""
    }

    conn =
      build_conn()
      |> post(api_session_path(conn, :forgot_password, params))

    changeset = conn.assigns.changeset
    assert json_response(conn, 400) == render_error_json("changeset_error_api.json", changeset: changeset)
  end

  defp render_error_json(template, assigns) do
    assigns = Map.new(assigns)

    view = ErrorView.render(template, assigns)
    view
    |> Poison.encode!
    |> Poison.decode!
  end
end
