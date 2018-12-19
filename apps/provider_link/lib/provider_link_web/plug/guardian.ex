defmodule ProviderLink.Guardian do
  @moduledoc """
  """
  use Guardian, otp_app: :provider_link,
    permissions: %{
      loas: [:manage_loas, :access_loas],
      acu_schedules: [:manage_providerlink_acu_schedules, :access_providerlink_acu_schedules],
      batch: [:manage_batch, :access_batch],
      home: [:manage_home, :access_home]
    }
  use Guardian.Permissions.Bitwise

  alias Data.Contexts.UserContext
  alias Data.Repo
  alias Data.Schemas.User

  def subject_for_token(resource, _claims) do
    {:ok, resource}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    {:ok, find_me_a_resource(claims["sub"])}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  def find_me_a_resource(token), do: token

  def build_claims(claims, _resource, opts) do
    claims =
      claims
      |> encode_permissions_into_claims!(Keyword.get(opts, :permissions))
    {:ok, claims}
  end

  def current_resource(conn) do
      [id, random] =
        conn
        |> Guardian.Plug.current_resource()
        |> String.split("+")

      get_encrypted_user(conn.cookies["nova"], encrypt256(random), id)
    rescue
     _ ->
      nil
  end

  defp get_encrypted_user(cookies, random, id) when cookies == random do
    User
    |> Repo.get(id)
    |> Repo.preload([
      agent: [:provider],
      roles: [
        role_applications: :application,
        role_permissions: :permission
      ]
    ])
  end

  defp get_encrypted_user(cookies, random, id), do: nil

  defp encrypt256(value) do
    :sha256
    |> :crypto.hash(value)
    |> Base.encode16()
  end

  def current_resource_api(conn) do
    user_id =
      conn
      |> Guardian.Plug.current_resource()
      |> String.split("+")

    id = Enum.at(user_id, 0)

    User
    |> Repo.get(id)
    |> Repo.preload([
      agent: [:provider]
    ])
  end

  # The following functions are for fetching of previous url for access rights
  
  defp check_referer(nil), do: nil
  defp check_referer(conn_referer) do
    conn_referer 
      |> List.first() 
      |> String.split("/")
  end

  def get_previous_url(conn_referer, permissions, request_path) do
    splitted_url = check_referer(conn_referer)
    conn_referer
    |> url_web_checker(splitted_url, permissions, request_path)
  end

  def url_web_checker(conn_referer, splitted_url, permissions, request_path) do
    splitted_request =
      request_path
      |> String.split("/")

    is_valid_request?(request_path, permissions, conn_referer, splitted_url)
  end

  defp is_valid_request?(request_path, permissions, conn_referer, splitted_url) do
    module =
      request_path
      |> String.split("/")
      |> Enum.at(1)

    if Enum.empty?(permissions[module]), do: "/", else: get_valid_link(conn_referer)
  end

  defp get_valid_link(conn_referer) do
    get_providerlink_modules
    |> Enum.find(&(&1 == conn_referer |> get_conn_referer_val()))
    |> nil_module?(conn_referer)
  end

  defp get_conn_referer_val(conn_referer) do
    val = conn_referer |> transforms_url("/", 3)
  end

  defp nil_module?(mod, _conn_referer) when is_nil(mod), do: "/"
  defp nil_module?(mod, conn_referer) when not is_nil(mod), do: conn_referer |> transforms_url(mod, 1)

  defp transforms_url(conn_referer, "/", count) when count == 3, do:
    conn_referer |> List.first() |> String.split("/") |> Enum.at(count)
  defp transforms_url(conn_referer, mod_link, count) do
    "/#{mod_link}#{conn_referer |> List.first() |> String.split("/#{mod_link}") |> Enum.at(count)}"
  end

  defp get_providerlink_modules do
    [
      "acu_schedules",
      "loas",
      "batch",
      "home"
    ]
  end
end
