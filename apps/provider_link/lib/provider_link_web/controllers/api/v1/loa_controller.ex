defmodule ProviderLinkWeb.Api.V1.LoaController do
  use ProviderLinkWeb, :controller

  alias Data.Contexts.LoaContext
  alias Data.Contexts.UtilityContext
  alias Data.Schemas.User
  alias ProviderLink.Guardian, as: PG

  def create_loa(conn, params) do
    user =
      conn
      |> PG.current_resource_api

    with user = %User{} <- conn |> PG.current_resource_api,
         {:ok, loa_params} <- params |> Map.put("created_by_id", user.id) |> LoaContext.create_loa_api
    do

      conn
      |> put_status(200)
      |> render(
        ProviderLinkWeb.Api.V1.LoaView,
        "loa_required.json",
        loa_params: loa_params,
        status: "ok"
      )
    else
      {:error, loa_params} ->

        conn
        |> put_status(400)
        |> render(
          ProviderLinkWeb.Api.V1.LoaView,
          "loa_required.json",
          loa_params: loa_params,
          status: "error"
        )
      nil ->
        conn
        |> put_status(403)
        |> render(
          ProviderLinkWeb.Api.V1.ErrorView,
          "error.json",
          message: "Unauthorized"
        )
    end
  end

  def update_acu_loa_status(conn, params) do
    l_ids = params["loa_ids"]
    as_ids = params["acu_schedule_ids"]

    with {:ok, loa_ids} <- validate_loa_ids(is_list(l_ids), l_ids),
         {:ok, acu_schedule_ids} <- validate_acu_schedule_ids(is_list(as_ids), as_ids)
    do
      loa_ids
      |> Enum.uniq()
      |> List.delete("")
      |> List.delete(nil)
      |> validate_ids()
      |> LoaContext.update_acu_loa_status()

      acu_schedule_ids
      |> Enum.uniq()
      |> List.delete("")
      |> List.delete(nil)
      |> validate_ids()
      |> LoaContext.update_acu_schedule_status()

      conn
      |> put_status(200)
      |> render(
        ProviderLinkWeb.Api.V1.LoaView,
        "message.json",
        message: "Loas Successfully Updated Status as Stale"
      )
    else
      {:invalid, message} ->
       conn
        |> put_status(400)
        |> render(ProviderLinkWeb.Api.V1.LoaView, "message.json", message: message)
      _ ->
       conn
        |> put_status(400)
        |> render(ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "Error updating acu loa status.")
    end
  end

  defp validate_loa_ids(true, list), do: {:ok, list}
  defp validate_loa_ids(false, _), do: {:invalid, "Invalid loa_ids"}

  defp validate_acu_schedule_ids(true, list), do: {:ok, list}
  defp validate_acu_schedule_ids(false, _), do: {:invalid, "Invalid acu_schedule_ids"}

  defp validate_ids(loa_ids) do
    validated_result =
      loa_ids
      |> Enum.map(&(
        case UtilityContext.valid_uuid?(&1) do
          {true, id} ->
            id
          {:invalid_id} ->
            false
          _ ->
            false
        end
      ))
    validated_result
    |> Enum.uniq()
    |> List.delete(false)
  end

  def create_loa_peme_from_accountlink(conn, peme_params) do
    user =
      conn
      |> PG.current_resource_api

    peme_params =
      peme_params
      |> Map.put("created_by_id", user.id)


    with {:ok, loa} <- LoaContext.create_peme_loa_accountlink(conn, peme_params) do
      conn
      |> json(%{message: "Succesfully Created Peme Loa"})
    else
       _ ->
      conn
      |> json(%{message: "Fail creating Peme Loa in Providerlink"})
    end
  end
end
