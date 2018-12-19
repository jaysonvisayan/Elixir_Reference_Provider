defmodule ProviderLinkWeb.SessionControllerTest do

    use ProviderLinkWeb.ConnCase
    # import ProviderLinkWeb.TestHelper
    # use ProviderLinkWeb.SchemaCase
    # import Ecto

  setup do

    conn = build_conn()
    user = fixture(:user_permission, %{keyword: "manage_providerlink_acu_schedules", module: "ProviderLink_Acu_Schedules"})
    conn = authenticated(conn, user)
    # user = insert(:user, pin: "123456")
    # user = insert(:user, is_admin: true)
    agent = insert(
      :agent,
      mobile: "09239049521",
      email: "mediadmin@medi.com",
      user: user
    )
    # conn = sign_in(conn, user)

    {:ok, %{conn: conn, agent: agent, user: user}}
  end

     test "renders forgot_password", %{conn: conn} do
        conn = get conn, session_path(conn, :forgot_password)
        assert html_response(conn, 200) =~ "Forgot Password"
     end

     test "send verification using phone number", %{conn: conn} do
       conn = post conn, session_path(conn, :send_verification, %{"session" =>  %{"pnumber_or_email" => "09195556688"}})
       assert redirected_to(conn) == session_path(conn, :forgot_password)

     end

     test "send verification using email address", %{conn: conn} do
        conn = post conn, session_path(conn, :send_verification, %{"session" => %{"pnumber_or_email" => "mediadmin@medi.com"}})
        assert redirected_to(conn) == session_path(conn, :new)
     end

    #  test "input valid verification code", %{conn: conn, user: user} do
    #     user = insert(:user, pin: "123456")
    #     conn = post conn, session_path(conn, :mobile_verification, %{"session" => %{"user_id" => "4af027fc-8afa-45df-b2ec-409c673a3c02"}, "verification_code" => user.pin})
    #     assert html_response(conn, 200) =~ "Mobile Verification"

    #  end

   describe "Login User" do
      test "with right credentials and redirect when valid", %{conn: conn} do
        Data.Contexts.UserContext.create_user(%{
          username: "masteradmin",
          password: "P@ssw0rd",
          password_confirmation: "P@ssw0rd",
          pin: "validated"
        })

        conn = post conn, session_path(conn, :create), session: %{
          username: "masteradmin",
          password: "P@ssw0rd",
          captcha: "generated_captcha_code"
        }
        user_details =   Data.Contexts.UserContext.get_user_by_username("masteradmin")

        assert redirected_to(conn) == "/reset_password/#{user_details.id}"
      end

      test "with invalid username", %{conn: conn} do
        Data.Contexts.UserContext.create_user(%{
          username: "masteradmin",
          password: "P@ssw0rd",
          password_confirmation: "P@ssw0rd",
          pin: "validated"
        })

        conn = post conn, session_path(conn, :create), session: %{
          username: "masteradmin1",
          password: "P@ssw0rd",
          captcha: "generated_captcha_code"
        }
        assert redirected_to(conn) == session_path(conn, :new)
        assert conn.private[:phoenix_flash]["error"] == "The username or password you have entered is invalid."
      end

      test "with invalid password", %{conn: conn} do
        Data.Contexts.UserContext.create_user(%{
          username: "masteradmin",
          password: "P@ssw0rd",
          password_confirmation: "P@ssw0rd",
          pin: "validated"
        })

        conn = post conn, session_path(conn, :create), session: %{
          username: "masteradmin",
          password: "P@ssw0rd1",
          captcha: "generated_captcha_code"
        }
        assert redirected_to(conn) == session_path(conn, :new)
        assert conn.private[:phoenix_flash]["error"] == "The username or password you have entered is invalid."
      end

      test "with no captcha", %{conn: conn} do
        Data.Contexts.UserContext.create_user(%{
          username: "masteradmin",
          password: "P@ssw0rd",
          password_confirmation: "P@ssw0rd",
          pin: "validated"
        })

        ip = Data.Contexts.UtilityContext.get_ip(conn)
        ip_address = insert(:login_ip_address, ip_address: ip)
        Data.Contexts.LoginIpAddressContext.update_ip_address(ip_address, %{attempts: 3})

        conn = post conn, session_path(conn, :create), session: %{
          username: "masteradmin",
          password: "P@ssw0rd"
        }
        assert redirected_to(conn) == session_path(conn, :new)
        assert conn.private[:phoenix_flash]["error"] == "Captcha is required."
      end
    end

end
