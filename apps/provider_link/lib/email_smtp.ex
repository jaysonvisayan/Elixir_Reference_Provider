defmodule ProviderLink.EmailSmtp do
  @moduledoc """
  """

  use Bamboo.Phoenix, view: ProviderLinkWeb.EmailView
  import ProviderLinkWeb.Router.Helpers

  alias Data.Repo
  alias Data.Schemas.Agent
  alias Data.Schemas.User
  alias ProviderLinkWeb.Endpoint

  def base_email do
    new_email
    |> from("noreply@innerpeace.dev")
    |> put_header("Reply-To", "noreply@innerpeace.dev")
    |> put_html_layout({ProviderLinkWeb.LayoutView, "email.html"})
  end

  def account_activation(agent) do
    base_email
    |> to(agent.email)
    |> subject("Account Activation")
    |> render("account_activation.html", agent: agent , url: page_url(Endpoint, :index))
  end

  def reset_password(%User{} = user, conn) do
    base_email
    |> to(user.agent.email)
    |> subject("Reset Password")
    |> render("reset_password.html", user: user, conn: conn, url: page_url(Endpoint, :index))
  end

  def reset_password(%Agent{} = agent, conn) do
    agent = agent |> Repo.preload([:user])
    user = agent.user |> Repo.preload([:agent])

    base_email
    |> to(agent.email)
    |> subject("Reset Password")
    |> render("reset_password.html", user: user, conn: conn, url: page_url(Endpoint, :index))
  end

  def send_new_code(user) do
    base_email
    |> to(user.agent.email)
    |> subject("Account Verification")
    |> render("send_new_code.html", user: user, url: page_url(Endpoint, :index))
  end

  def send_pin(user, loa) do
    base_email
    |> to(user.agent.email)
    |> subject("LOA OTP Verification")
    |> render("send_pin.html", user: user, loa: loa, url: page_url(Endpoint, :index))
  end

  #def forgot_password(user) do
  #  base_email
  #  |> to(user.email)
  #  |> subject("Forgot Password")
  #  # |> render("forgot_password.html", user: user, url: page_url(Endpoint, :index, "en"))
  #end

  ##### acu email notification #####
  def send_acu_email(agent, acu_schedule, inserted_at, api_address) do
    values = %{id: acu_schedule.id, datetime: inserted_at}
    val = Poison.encode!(values)

    url =
      api_address.endpoint
      |> String.split("/api/v1")
      |> Enum.at(0)

    base_email
    |> to(agent.email)
    |> subject("ACU Schedule-" <> "#{acu_schedule.batch_no}" <> "-" <> "#{acu_schedule.account_name}")
    |> render("acu_schedule_notification.html", agent: agent, acu_schedule: acu_schedule, val: val, url: url, id: acu_schedule.id)
  end

end
