defmodule ProviderLinkWeb.Api.V1.StatusControllerTest do
  use ProviderLinkWeb.ConnCase
  # use ProviderLinkWeb.SchemaCase

  setup do
    conn = build_conn()
    {:ok, %{conn: conn}}
  end

  test "index renders current version", %{conn: conn}  do
    conn =
      conn
      |> get(api_status_path(conn, :index))

    result =
      conn
      |> json_response(200)

    version =
      :provider_link
      |> Application.spec(:vsn)
      |> String.Chars.to_string

    assert result == %{"status" => "ok", "version" => version}
  end
end
