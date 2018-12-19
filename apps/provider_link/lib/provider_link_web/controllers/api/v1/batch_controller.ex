defmodule ProviderLinkWeb.Api.V1.BatchController do
  use ProviderLinkWeb, :controller
  alias ProviderLinkWeb.BatchView
  alias ProviderLinkWeb.Api.V1.ErrorView
  alias ProviderLinkWeb.Api.V1.StatusView
  alias Data.Schemas.{
    Batch,
    File,
  }
  alias Data.Contexts.{
    BatchContext,
    FileContext
  }
  alias Guardian.Plug

  def attach_soa_to_batch(conn, params) do
    with {:ok, batch} <- BatchContext.attach_soa(params)
    do
      conn
      |> put_status(200)
      |> render(
        StatusView,
        "success.json"
      )
    else
      {:error_upload_params} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid Upload Parameters")
      {:error_base_64} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid Upload Base 64")
      {:batch_not_found} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Batch Not Found")
      _ ->
        conn
        |> put_status(500)
        |> render(ErrorView, "error.json", message: "Server Error")
    end
  end
end
