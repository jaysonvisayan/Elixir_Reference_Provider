defmodule ProviderLinkWeb.TestHelper do
  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt"
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  def conn_with_fetched_session(the_conn) do
    the_conn.secret_key_base
    |> put_in(@secret)
    |> Plug.Session.call(@signing_opts)
    |> Plug.Conn.fetch_session
  end

  def sign_in(conn, resource) do
    random = Ecto.UUID.generate
    secure_random = "#{resource.id}+#{random}"

    conn
    |> conn_with_fetched_session
    |> add_random_cookie(random)
    |> ProviderLink.Guardian.Plug.sign_in(secure_random)
  end

  defp add_random_cookie(conn, random) do
    random
    |> encrypt256
    |> store_cookie(conn)
  end

  defp encrypt256(value) do
    :sha256
    |> :crypto.hash(value)
    |> Base.encode16()
  end

  defp store_cookie(value, conn) do
    conn
    |> Plug.Conn.put_resp_cookie("nova", value, [
        secure: false,
        http_only: true,
        domain: conn.host
      ])
  end

end

{:ok, _} = Application.ensure_all_started(:ex_machina)

Application.ensure_all_started(:hound)
ExUnit.configure exclude: [integration: true]
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Data.Repo, :manual)
