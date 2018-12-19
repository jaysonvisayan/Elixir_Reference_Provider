defmodule ProviderLink.Auth.ErrorHandler do
  @moduledoc """
  """

  import Phoenix.Controller, only: [put_flash: 3, redirect: 2, put_layout: 2]
  import Plug.Conn

  alias ProviderLink.Guardian, as: PLG

  def auth_error(conn, {:unauthorized, reason}, options) do
    url = redirect_to_previous_url(conn)

    conn
    |> put_flash(:error, "You are not authorized to access this page")
    |> redirect(to: "#{url}")
  end

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_flash(:error, "You must be signed in to access that page.")
    |> redirect(to: "/sign_in")
  end

  def redirect_to_previous_url(conn) do
    conn
    |> get_req_header("referer")
    |> PLG.get_previous_url(conn.private.guardian_default_claims["pem"], conn.request_path)
  end

end
