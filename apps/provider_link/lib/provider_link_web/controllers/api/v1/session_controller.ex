defmodule ProviderLinkWeb.Api.V1.SessionController do
  use ProviderLinkWeb, :controller

  alias ProviderLink.{
    EmailSmtp,
    Mailer
  }
  alias Data.Utilities.SMS

  alias ProviderLink.Guardian.Plug
  alias ProviderLinkWeb.Api.V1.UserView
  alias ProviderLinkWeb.Api.V1.ErrorView
  alias ProviderLink.Guardian, as: PG

  alias Data.Schemas.User
  alias Data.Schemas.Agent
  alias Data.Contexts.{
    AgentContext,
    UserContext
  }

  def login(conn, params) do
    if (params |> Map.has_key?("username") && not is_nil(params["username"])) && (params |> Map.has_key?("password") && not is_nil(params["password"])) do
      username = params["username"]
      password = params["password"]

      with {:ok, conn} <- Auth.username_and_pass(conn, username, password)
      do
        jwt =
          conn
          |> Auth.current_token()

        claims =
          conn
          |> Auth.current_claims()

        _exp =
          claims
          |> Map.get("exp")

        user = PG.current_resource_api(conn)

        conn
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> render(ProviderLinkWeb.Api.V1.UserView, "login.json", user: user, jwt: jwt)
      else
        {:error, reason, conn, user} ->
          case reason do
            :not_found ->
              error_msg(conn, 404, "Not Found!")
            :unauthorized ->
              error_msg(conn, 403, "The username or password you have entered is invalid")
            :locked ->
              error_msg(conn, 400, "Your account has been locked.")
          end
      end
    else
      error_msg(conn, 403, "Unauthorized")
    end
  end

  def logout(conn, _params) do
    with  jwt <- Auth.current_token(conn),
          claims <- Auth.current_claims(conn),
          {:ok, _a} <- ProviderLink.Guardian.revoke(jwt, claims)
     do
      conn
      |> put_status(200)
      |> render(ProviderLinkWeb.Api.V1.UserView, "logout.json", message: "Signed out!")
     else
       nil ->
         error_msg(conn, 404, "No session found!")
       {:error, _error} ->
         error_msg(conn, 404, "Invalid token!")
       {:error, :no_session} ->
         error_msg(conn, 404, "No session found!")
       {:error, :token_not_found} ->
         error_msg(conn, 404, "Invalid token!")
    end
  end

  defp error_msg(conn, status, message) do
    conn
    |> put_status(status)
    |> render(ProviderLinkWeb.Api.V1.ErrorView, "error.json", message: message)
  end

  def forgot_password(conn, params) do
   send_thru = params["recovery"]

    with {:ok, _email_validate} <- AgentContext.validate_forgot_password(params)
    do
     cond do
       send_thru == "email" ->
        with {:ok, user} <- AgentContext.get_user_by_email(
            params["username"], params["text"]),
          {:ok, user} <- AgentContext.get_agent_username(
            params["username"])
          # {:ok, user} <- AgentContext.validate_request(user)
        do
          user
          |> AgentContext.delete_verification_code()

          {:ok, user} = AgentContext.update_verification_code_agent(
            user.agent, %{"verification_code" => AgentContext.generate_verification_code()})
          AgentContext.update_user_expiry(user)
          _email =
            user
            |> EmailSmtp.reset_password(conn)
            |> Mailer.deliver_now
          conn
          |> put_status(200)
          |> render(UserView, "forgot_credential_password.json", message: "Successfully sent the PIN to the user's email", code: 200, user: user)
        else
          {:inactive_member} ->
            error_msg(conn, 400, "The member you have entered is not active")
          {:not_verified} ->
            error_msg(conn, 400, "user is not a registered member!")
          {:not_found} ->
            error_msg(conn, 400, "username not found")
          {:user_not_found} ->
            error_msg(conn, 404, "User not found")
        _ ->
          error_msg(conn, 500, "Server error")
        end
      send_thru == "mobile" ->
        with {:ok, user} <- AgentContext.get_user_by_mobile(
            params["username"], params["text"]),
             {:ok, user} <- AgentContext.get_agent_username(
            params["username"])
          # {:ok, user} <- AgentContext.validate_request(user)
        do
          user
          |> AgentContext.delete_verification_code()

          {:ok, user} =
            user.agent
            |> AgentContext.update_verification_code_agent(
              %{"verification_code" => AgentContext.generate_verification_code()}
            )
          AgentContext.update_user_expiry(user)

          agent_mobile =
            if not is_nil(user.mobile) do
              transforms_number(user.mobile)
            end

          SMS.send(%{text: "Your verification code for reset password is #{user.verification_code}", to: agent_mobile})
          conn
          |> put_status(200)
          |> render(UserView, "forgot_credential_password.json",
                    message: "Successfully sent the PIN to the user's mobile number",
                    code: 200,
                    user: user
          )
        else
          {:inactive_member} ->
            error_msg(conn, 400, "The member you have entered is not active")
          {:not_verified} ->
            error_msg(conn, 400, "user is not a registered member!")
          {:not_found} ->
            error_msg(conn, 400, "username not found")
          {:user_not_found} ->
            error_msg(conn, 404, "User not found")
        _ ->
          error_msg(conn, 500, "Server error")
        end
       true ->
          error_msg(conn, 400, "recovery is invalid")
     end
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "changeset_error_api.json", changeset: changeset)
      {:recovery_not_found} ->
        error_msg(conn, 404, "Recovery not found")
    end
 end

 def resend_code_api(conn, params) do
    send_thru = params["recovery"]

    with {:ok, _email_validate} <- AgentContext.validate_forgot_password(params)
    do
      cond do
        send_thru == "email" ->
        with {:ok, user} <- AgentContext.get_user_by_email(
            params["username"], params["text"]),
          {:ok, user} <- AgentContext.get_agent_username(
            params["username"])
          # {:ok, user} <- AgentContext.validate_request(user)
        do
          user
          |> AgentContext.delete_verification_code()
          {:ok, user} = AgentContext.update_verification_code_agent(
            user.agent, %{"verification_code" => AgentContext.generate_verification_code()})
          AgentContext.update_user_expiry(user)
          _email =
            user
            |> EmailSmtp.reset_password(conn)
            |> Mailer.deliver_now
          conn
          |> put_status(200)
          |> render(UserView, "forgot_credential_password.json", message: "Successfully sent the PIN to the user's email", code: 200, user: user)
        else
          {:inactive_member} ->
            error_msg(conn, 400, "The member you have entered is not active")
          {:not_verified} ->
            error_msg(conn, 400, "user is not a registered member!")
          {:not_found} ->
            error_msg(conn, 400, "username not found")
          {:user_not_found} ->
            error_msg(conn, 404, "User not found")
        _ ->
          error_msg(conn, 500, "Server error")
        end
      send_thru == "mobile" ->
        with {:ok, user} <- AgentContext.get_user_by_mobile(
            params["username"], params["text"]),
              {:ok, user} <- AgentContext.get_agent_username(
            params["username"])
          # {:ok, user} <- AgentContext.validate_request(user)
        do
          user
          |> AgentContext.delete_verification_code()

          {:ok, user} =
            user.agent
            |> AgentContext.update_verification_code_agent(
              %{"verification_code" => AgentContext.generate_verification_code()}
            )

          AgentContext.update_user_expiry(user)

          agent_mobile =
            if not is_nil(user.mobile) do
              transforms_number(user.mobile)
            end

          SMS.send(%{text: "Your verification code for reset password is #{user.verification_code}", to: agent_mobile})
          conn
          |> put_status(200)
          |> render(UserView, "forgot_credential_password.json",
                    message: "Successfully sent the PIN to the user's mobile number",
                    code: 200,
                    user: user
          )
        else
          {:inactive_member} ->
            error_msg(conn, 400, "The member you have entered is not active")
          {:not_verified} ->
            error_msg(conn, 400, "user is not a registered member!")
          {:not_found} ->
            error_msg(conn, 400, "username not found")
          {:user_not_found} ->
            error_msg(conn, 404, "User not found")
        _ ->
          error_msg(conn, 500, "Server error")
        end
        true ->
          error_msg(conn, 400, "recovery is invalid")
      end
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "changeset_error_api.json", changeset: changeset)
      {:recovery_not_found} ->
        error_msg(conn, 404, "Recovery not found")
    end
  end

  def forgot_password_confirm(conn, %{"user_id" => id, "verification_code" => pin}) do
    cond do
      id == "" && pin == "" ->
        error_msg(conn, 400, "user id and verification code can't be blank")
      id == "" ->
        error_msg(conn, 400, "user id can't be blank")
      pin == "" ->
        error_msg(conn, 400, "verification code can't be blank")
      true ->
        with agent = %Agent{} <- AgentContext.get_agent_by_id(id),
             {:ok, agent} <- AgentContext.validate_request(agent),
             true <- AgentContext.check_pin_expiry_forgot(agent),
             %Agent{} <- AgentContext.validate_user_verification_code(id, pin),
             {:ok, agent} <- AgentContext.update_verification(
              agent, %{verification: false})
        do
          conn
          |> render(UserView, "forgot_password_confirm.json",
                    user: agent, message: "Valid verification code", code: 200)
        else
          false ->
            error_msg(conn, 400, "pin expired")
          {:not_verified} ->
            error_msg(conn, 400, "user is not a registered member!")
          {:locked} ->
            error_msg(conn, 404, "User is locked please reset your password")
          nil ->
            error_msg(conn, 400, "Invalid pin")
          {:user_not_found} ->
            error_msg(conn, 404, "User not found")
          _ ->
            error_msg(conn, 500, "Server error")
        end
    end
  end

  def forgot_password_reset(conn, params) do
    if params["user_id"] == "" do
      error_msg(conn, 400, "User id can't be blank")
    else
        with agent = %Agent{} <- AgentContext.get_agent_by_id(params["user_id"]),
            {:ok, user} <- AgentContext.validate_request(agent),
            {:ok, user} <- UserContext.reset_password_providerlink(agent.user, params),
            {:ok, user} <- UserContext.attempts_reset(user, %{attempt: nil}),
            {:ok, user} <- UserContext.update_user_status_active(user)
        do
          new_conn = Plug.sign_in(conn, user)
          token = Plug.current_token(new_conn)

          claims = Plug.current_claims(new_conn)
          exp = Map.get(claims, "exp")
          new_conn
          |> put_status(200)
          |> put_resp_header("authorization", "Bearer #{token}")
          |> render(UserView, "login.json",
                    user_id: agent.id,
                    token: token,
                    exp: exp,
                    verified: agent.verification
          )
        else
          {:not_verified} ->
            error_msg(conn, 400, "user is not a registered member!")
          {:old_password} ->
            error_msg(conn, 400, "Cannot use old password")
          {:user_not_found} ->
            error_msg(conn, 404, "User not found")
          {:error, changeset} ->
            conn
            |> put_status(400)
            |> render(ErrorView, "changeset_error_api.json", changeset: changeset)
          _ ->
            error_msg(conn, 500, "Server error")
        end
    end
  end

 defp transforms_number(number) do
   number =
     number
     |> String.slice(1..11)
   "63#{number}"
 end


end
