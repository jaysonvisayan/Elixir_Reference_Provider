defmodule Data.Contexts.DiagnosisContext do
  @moduledoc """
  """
  alias Data.Contexts.{
    UtilityContext
  }

  def payor_link_diagnosis(params, payor_code, conn) do
    with {:ok, response} <- UtilityContext.connect_to_api_get(conn,
      payor_code, "diagnoses")
    do
      decoded = Poison.decode!(response.body)

      params = for diagnosis <- decoded["data"] do
        params =
          params
          |> Map.put("payorlink_diagnosis_id", diagnosis["id"])
          |> Map.put("code", diagnosis["code"])
          |> Map.put("description", diagnosis["description"])
      end

      {:diagnosis, params}
    else
      {:unable_to_login} ->
        {:unable_to_login}
      {:error_connecting_api} ->
        {:error_connecting_api}
      {:payor_does_not_exists} ->
        {:payor_does_not_exists}
    end
  end

  def get_payor_link_diagnosis(id, payor_code, conn) do
    with {:ok, response} <- UtilityContext.connect_to_api_get(conn,
      payor_code, "#{id}/get_diagnosis")
    do
      Poison.decode!(response.body)["data"]
    else
      {:unable_to_login} ->
        {:unable_to_login}
      {:error_connecting_api} ->
        {:error_connecting_api}
      {:payor_does_not_exists} ->
        {:payor_does_not_exists}
    end
  end

end
