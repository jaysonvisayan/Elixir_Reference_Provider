defmodule ProviderLinkWeb.Api.V1.StatusController do
  use ProviderLinkWeb, :controller

  def index(conn, _params) do
    version = :provider_link |> Application.spec(:vsn) |> String.Chars.to_string
    render(conn, "index.json", %{version: version})
  end
end
