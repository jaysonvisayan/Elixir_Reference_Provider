defmodule ProviderLinkWeb.Api.V1.ProviderController do
  use ProviderLinkWeb, :controller

  alias Data.Contexts.{
    ProviderContext,
    UtilityContext,
    AcuScheduleContext
  }
  alias Data.Schemas.Provider
  alias ProviderLinkWeb.MemberView
  alias ProviderLinkWeb.Api.V1.ErrorView
  alias ProviderLinkWeb.Api.V1.AcuScheduleView
  alias Guardian.Plug

  def insert_update_provider(conn, params) do
    provider = ProviderContext.get_provider_by_code(params["code"])
    if is_nil(provider) do
      insert_provider_from_payorlink(conn, params)
    else
      update_provider_from_payorlink(conn, provider, params)
    end
  end

  defp insert_provider_from_payorlink(conn, params) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "facilities/get_by_code?code=#{params["code"]}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            params =
            %{
              payorlink_facility_id: decoded["id"],
              name: decoded["name"],
              code: decoded["code"],
              phone_no: decoded["phone_no"],
              email_address: decoded["email_address"],
              line_1: decoded["line_1"],
              line_2: decoded["line_2"],
              city: decoded["city"],
              province: decoded["province"],
              region: decoded["region"],
              country: decoded["country"],
              postal_code: decoded["postal_code"]
            }
            with {:ok, provider} <- ProviderContext.create_provider(params) do
              render(conn, MemberView, "message.json", message: "Successfully inserted provider")
            else
              _ ->
              conn
              |> put_status(400)
              |> render(ErrorView, "error.json", message: "Error inserting provider")
            end
            _ ->
              conn
              |> put_status(400)
              |> render(ErrorView, "error.json", message: "Error connecting to PayorLink")
        end
      _ ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Error connecting to PayorLink")
    end
  end

  defp update_provider_from_payorlink(conn, provider, params) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "facilities/get_by_code?code=#{params["code"]}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            params =
            %{
              payorlink_facility_id: decoded["id"],
              name: decoded["name"],
              code: decoded["code"],
              phone_no: decoded["phone_no"],
              email_address: decoded["email_address"],
              line_1: decoded["line_1"],
              line_2: decoded["line_2"],
              city: decoded["city"],
              province: decoded["province"],
              region: decoded["region"],
              country: decoded["country"],
              postal_code: decoded["postal_code"]
            }
            with {:ok, provider} <- ProviderContext.update_provider(provider, params) do
              render(conn, MemberView, "message.json", message: "Successfully updated provider")
            else
              _ ->
              conn
              |> put_status(400)
              |> render(ErrorView, "error.json", message: "Error updating provider")
            end
            _ ->
              conn
              |> put_status(400)
              |> render(ErrorView, "error.json", message: "Error connecting to PayorLink")
        end
      _ ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Error connecting to PayorLink")
    end
  end

  def get_acu_schedules(conn, params) do
    with true <- Map.has_key?(params, "account_code"),
         true <- Map.has_key?(params, "provider_code"),
         false <- is_nil(params["account_code"]),
         false <- is_nil(params["provider_code"]),
         %Provider{} = provider <- ProviderContext.get_provider_by_code(params["provider_code"])
    do
      acu_schedules = AcuScheduleContext.get_acu_schedules(provider.id, params["account_code"])
      render(conn, AcuScheduleView, "acu_schedules.json", acu_schedules: acu_schedules)
    else
      _ ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid parameters!")
    end
  end

end
