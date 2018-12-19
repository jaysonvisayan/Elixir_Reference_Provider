defmodule Data.Contexts.ProcedureContext do
  @moduledoc """
  """

  alias Data.Contexts.UtilityContext
  alias Poison.Parser

  def payor_link_procedure(params, payor_code, conn) do
    with {:ok, response} <- UtilityContext.connect_to_api_get(conn, payor_code,
                                                              "procedures")
    do
      params =  Parser.parse!(response.body, keys: :atoms)
      {:procedure, params.procedures}
    else
      {:unable_to_login} ->
        {:unable_to_login}
      {:error_connecting_api} ->
        {:error_connecting_api}
      {:payor_does_not_exists} ->
        {:payor_does_not_exists}
    end

  end

  def get_payor_link_payor_procedure(id, payor_code, conn) do
    with {:ok, response} <- UtilityContext.connect_to_api_get(conn, payor_code,
                                                              "#{id}/get_payor_procedure")
    do
      Poison.decode!(response.body)
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
