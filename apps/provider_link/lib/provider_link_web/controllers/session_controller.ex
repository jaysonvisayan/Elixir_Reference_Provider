defmodule ProviderLinkWeb.SessionController do
  use ProviderLinkWeb, :controller

  alias Data.Contexts.{
    UserContext,
    AgentContext,
    LoginIpAddressContext,
    UtilityContext
  }
  alias Data.Schemas.{
    LoginIpAddress,
    Agent
  }

  alias Data.Utilities.SMS
  alias ProviderLink.{
    EmailSmtp,
    Mailer
  }

  alias Data.Schemas.User

  def new(conn, _) do
    ip = UtilityContext.get_ip(conn)
    with %LoginIpAddress{} = ip_address <- LoginIpAddressContext.get_ip_address(ip)
    do
      conn
      |> render("new.html", attempts: ip_address.attempts)
    else
      _ ->
        {:ok, ip_address} = LoginIpAddressContext.create_ip_address(ip)
        conn
        |> render("new.html", attempts: ip_address.attempts)
    end
  end

  def create(conn, %{"session" => params}) do
    username = params["username"]
    password = params["password"]
    ip = UtilityContext.get_ip(conn)
    ip_address = LoginIpAddressContext.get_ip_address(ip)
    user_details = UserContext.get_user_by_username(username)

    {:ok, ip_address} =
      if is_nil(ip_address) do
        LoginIpAddressContext.create_ip_address(ip)
      else
        {:ok, ip_address}
      end

    with {:ok, conn} <- Auth.username_and_pass(conn, username, password),
         {:valid} <- validate_captcha(ip_address, params["captcha"])
    do
        LoginIpAddressContext.remove_attempt(ip_address)
        user = conn.private[:guardian_default_resource]

        if is_nil(user_details.first_time) || user_details.first_time == false do
           conn
           |> put_flash(:info, "You’re now signed in!")
           |> redirect(to: page_path(conn, :index))
        else
          conn
          |> redirect(to: user_path(conn, :reset_password, user_details.id))
        end

    else
      {:error, reason, conn, user} ->
        LoginIpAddressContext.add_attempt(ip_address)
        if is_nil(user) do
          conn
          |> put_flash(:error, "The username or password you have entered is invalid.")
          |> redirect(to: session_path(conn, :new))
        else
          if user.status == "locked" do
            conn
            |> put_flash(:error, "Your account has been locked, you are advised to reset your password.")
            |> redirect(to: session_path(conn, :new))
          else
            conn
            |> put_flash(:error, "The username or password you have entered is invalid.")
            |> redirect(to: session_path(conn, :new))
          end
        end
      {:invalid, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: session_path(conn, :new))
     end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout
    |> put_flash(:info, "See you later!")
    |> redirect(to: session_path(conn, :new))
  end

  def forgot_password(conn, _) do
    changeset = Agent.pnumber_or_email_changeset(%Agent{})
    render conn, "forgot_password.html", changeset: changeset
  end

  def send_verification(conn, %{"session" => params}) do
    changeset = Agent.pnumber_or_email_changeset(%Agent{})
    with {:ok, params} <- UserContext.is_pnum_or_email?(params),
         {:valid, user} <- UserContext.validate_channel(params)
    do
      if is_nil(params["mobile"]) do
        user
        |> EmailSmtp.reset_password(conn)
        |> Mailer.deliver_now()
        conn
        |> put_flash(:info, "We've sent you a mail with instructions on how to reset your password.")
        |> redirect(to: session_path(conn, :new))
      else
        # transform number to 639
        agent_mobile =
          user.agent.mobile
          |> SMS.transforms_number

        %{
          text: "Your verification code is #{user.pin}",
          to: agent_mobile
        }
        |> SMS.send()

      if params["status"] do
        conn
        |> put_flash(:info, "Resent")
        |> render("forgot_password/mobile_verification.html",
                changeset: changeset,
                user: user,
                params: params
               )
      else
        conn
        |> render("forgot_password/mobile_verification.html",
                changeset: changeset,
                user: user,
                params: params
               )
      end

      end
    else
      {:error} ->
        conn
        |> put_flash(:error, "The Email or Mobile number that you entered is invalid")
        |> redirect(to: session_path(conn, :forgot_password))
      {:invalid_email} ->
        conn
        |> put_flash(:error, "The email address you entered did not match with the registered email address")
        |> redirect(to: session_path(conn, :forgot_password))
      {:invalid_mobile} ->
        conn
        |> put_flash(:error, "The mobile number you entered did not match with the registered mobile number")
        |> redirect(to: session_path(conn, :forgot_password))
      {:invalid} ->
        conn
        |> put_flash(:error, "We don't recognize the email address/phone number you have entered. Please try again.")
        |> redirect(to: session_path(conn, :forgot_password))
    end
    rescue
    _ ->
      conn
      |> put_flash(:error, "Error in getting user")
      |> redirect(to: "/forgot_password")
  end

 #  def send_verification_v2(conn, %{"session" => params}) do
 #    changeset = Agent.pnumber_or_email_changeset(%Agent{})
 #    with {:ok, params} <- UserContext.is_pnum_or_email?(params)
 #    do
 #      if check_data(params["pnumber_or_email"]) == "Email" do
 #        with {:valid, user} <- UserContext.validate_user_email_v2(params["email"]) do
 #          user
 #          |> EmailSmtp.reset_password()
 #          |> Mailer.deliver_now()
 #          conn
 #          |> put_flash(:info, "We've sent you a mail with instructions on how to reset your password")
 #          |> render("new.html",
 #                    changeset: changeset,
 #                    pnumber_or_email: params["pnumber_or_email"],
 #                    user: user)

 #        else
 #          _ ->
 #          conn
 #          |> put_flash(:error, "We don't recognize the email address/phone number you have entered. Try entering it again")
 #          |> render("forgot_password.html", changeset: changeset)
 #        end
 #      else
 #        with {:valid, user} <- UserContext.validate_user_mobile_v2(params["mobile"]) do
 #          # transform number to 639
 #          agent_mobile =
 #            user.agent.mobile
 #            |> SMS.transforms_number

 #          %{
 #            text: "Your verification code is #{user.pin}",
 #            to: agent_mobile
 #          }
 #          |> SMS.send()

 #          conn
 #          |> render("forgot_password/mobile_verification.html",
 #                    changeset: changeset,
 #                    pnumber_or_email: params["pnumber_or_email"],
 #                   user: user)

 #        else_
 #          _ ->
 #          conn
 #          |> put_flash(:error, "We don't recognize the email address/phone number you have entered. Try entering it again")
 #          |> render("forgot_password.html", changeset: changeset)
 #        end
 #      end
 #    else
 #      _ ->
 #      conn
 #        |> put_flash(:error, "We don't recognize the email address/phone number you have entered. Try entering it again")
 #        |> render("forgot_password.html", changeset: changeset)

 #    end

 # end

 defp check_data(data) do
    String.to_integer(data)
    "Mobile"
   rescue
    _ ->
      "Email"
 end

 def mobile_verification(conn, params) do
    with {:pin_not_expired, user} <- UserContext.pin_expired?(params["session"]["user_id"]),
         {:valid, user} <- UserContext.validate_pin(user,params["verification_code"]),
         {:ok, user} <- UserContext.update_pin_validated(user, %{pin: "validated"})
    do
      changeset = User.password_changeset(%User{})
      user = UserContext.get_user_by_id(params["session"]["user_id"])
      if is_nil(user) and user.id == user.agent.id do
        conn
        |> put_flash(:error, "User ID not Found!")
        |> render("forgot_password/mobile_verification.html",
          changeset: changeset,
          user: user,
          params: params
        )
      else
       conn
       |> redirect(to: user_path(conn, :reset_password, user))
    end
    else
      {:invalid} ->
        changeset = User.password_changeset(%User{})
        user = UserContext.get_user_by_id(params["session"]["user_id"])
          if params["verification_code"] != "" do
              conn
              |> put_flash(:error, "Wrong verification code, Try to re-enter verification code.")
              |> render("forgot_password/mobile_verification.html",
                changeset: changeset,
                user: user,
                params: params
              )
          else
              conn
              |> put_flash(:error, "Please enter verification code")
              |> render("forgot_password/mobile_verification.html",
                changeset: changeset,
                user: user,
                params: params
              )
          end
      {:pin_expired} ->
        # json conn, "pin_expired"
        changeset = User.password_changeset(%User{})
        user = UserContext.get_user_by_id(params["session"]["user_id"])

        conn
        |> put_flash(:error, "Verification code has expired, request for a new code")
        |> render("forgot_password/mobile_verification.html",
          changeset: changeset,
          user: user,
          params: params
        )
    end
  end

  defp validate_captcha(ip_address, captcha) do
    if ip_address.attempts >= 3 and is_nil(captcha) do
      {:invalid, "Captcha is required."}
    else
      {:valid}
    end
  end

end
