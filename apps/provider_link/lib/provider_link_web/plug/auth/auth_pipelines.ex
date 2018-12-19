defmodule ProviderLink.Guardian.AuthPipeline.Browser do
  @moduledoc """
  """

  use Guardian.Plug.Pipeline, otp_app: :provider_link,
  module: ProviderLink.Guardian,
  error_handler: ProviderLink.Auth.ErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.LoadResource, ensure: true, allow_blank: false
end

defmodule ProviderLink.Guardian.AuthPipeline.JSON do
  @moduledoc """
  """

  use Guardian.Plug.Pipeline, otp_app: :provider_link,
  module: ProviderLink.Guardian,
  error_handler: ProviderLink.Auth.Api.ErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.LoadResource, allow_blank: true
end

defmodule ProviderLink.Guardian.AuthPipeline.Authenticate do
  @moduledoc """
  """

  import Guardian.Plug
  alias ProviderLink.Guardian, as: PG
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  use Guardian.Plug.Pipeline, otp_app: :provider_link,
  module: ProviderLink.Guardian,
  error_handler: ProviderLink.Auth.ErrorHandler

  plug Guardian.Plug.EnsureAuthenticated
  plug Auth.SlidingSessionTimeout, timeout_after_seconds: 10_000

  def call(conn, _opts) do
    current_user = PG.current_resource(conn)
    case current_user do
      nil ->
        conn
        |> logout
      _ ->
        conn
    end
  end

  defp logout(conn) do
    conn
    |> Plug.Conn.delete_resp_cookie("nova", [
        secure: get_secure_by_env(),
        http_only: true,
        domain: conn.host
      ])
    |> ProviderLink.Guardian.Plug.sign_out
    |> Plug.Conn.configure_session(drop: true)
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/")
  end

  defp get_secure_by_env do
    case Application.get_env(:payor_link, :env) do
      :prod ->
        true
       _ ->
        false
    end
  end
end
