defmodule ProviderLinkWeb.FallbackController do
  use ProviderLinkWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> render(ProviderLinkWeb.ErrorView, :"404")
  end

  def call(conn, nil) do
    conn
    |> render(ProviderLinkWeb.ErrorView, :"404")
  end

  def call(conn, {:error, :unauthenticated}) do
    conn
    |> put_status(:unauthenticated)
    |> put_flash(:error, "Unauthenticated")
    |> render(ProviderLinkWeb.ErrorView, :"401")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_flash(:error, "Unauthorized")
    |> render(ProviderLinkWeb.ErrorView, :"401")
  end

  def call(conn, {:error, :no_resource_found}) do
    conn
    |> put_flash(:error, "You are not authorized to access this page")
    |> redirect(to: "/")
  end

  defp logout(conn) do
    conn
    |> ProviderLink.Guardian.Plug.sign_out
    |> Plug.Conn.configure_session(drop: true)
  end
end
