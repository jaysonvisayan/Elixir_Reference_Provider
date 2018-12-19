defmodule ProviderLinkWeb.Api.V1.UserView do
  use ProviderLinkWeb, :view

  def render("login.json", %{user: user, jwt: jwt}) do
    %{
      "user_id": user.id,
      "token": jwt,
      "provider_code": user.agent.provider.code,
      "validated": true,
      "prescription_term": user.agent.provider.prescription_term
    }
  end

  def render("logout.json", %{message: message}) do
    %{"message": message}
  end

  def render("update_password.json", %{message: message}) do
    %{"message": message}
  end

  def render("create_agent_user.json", %{result: result}) do
    result
  end

  def render("forgot_credential_password.json", %{message: message, code: code, user: user}) do
    {{y, m, d}, {h, min, s}} = Ecto.DateTime.to_erl(user.verification_expiry)
    expiry_date = {{y, m, d}, {h, min + 15, s}}
                  |> Ecto.DateTime.from_erl()
    %{
      user_id: user.id,
      pin_expiry: expiry_date,
      message: message,
      code: code
    }
  end

  def render("forgot_password_confirm.json", %{user: user, message: message, code: code}) do
    %{
      user_id: user.id,
      verified: user.verification,
      message: message,
      code: code
    }
  end

  def render("login.json", %{user_id: user_id, token: token, exp: exp, verified: verified}) do
    %{
      "user_id": user_id,
      "token": token,
      "expiry": Ecto.DateTime.from_unix!(exp, :second),
      "verified": verified
    }
  end

  def render("user_result.json", %{user: user}) do
    %{
      "username": user.username,
      "status": user.status
    }
  end

  def render("user_info.json", %{user: user}) do
    %{
      "username": user.username,
      "status": user.status,
      "first_name": user.agent.first_name,
      "last_name": user.agent.last_name,
      "mobile": user.agent.mobile,
      "email": user.agent.email,
      "department": user.agent.department,
      "role": user.agent.role,
      "is_admin": user.is_admin,
      "provider_code": user.agent.provider.code,
      "provider_name": user.agent.provider.name,
      "prescription_term": user.agent.provider.prescription_term
    }
  end
end
