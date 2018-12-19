defmodule ProviderLinkWeb.Api.V1.Migration.UserController do
  use ProviderLinkWeb, :controller

  alias ProviderLinkWeb.Api.V1.{
    ErrorView,
    UserView
  }
  alias Data.Contexts.UserContext
  alias Ecto.Changeset

  def create_batch_user(conn, params)
    when params == %{}
    when params == %{"_json" => []}
  do
    conn
    |> put_status(400)
    |> render(
      ErrorView,
      "error.json",
      message: "No data provided"
    )
  end

  def create_batch_user(conn, params) do
    with result = [_ | _] <- UserContext.create_batch_user(params)
    do
      conn
      |> put_status(200)
      |> render(
        UserView,
        "create_agent_user.json",
        result: result
      )
    else
      {:error, :params_not_exists, message} ->
        conn
        |> return_error(message, 400)
      {:error, :params_is_empty, message} ->
        conn
        |> return_error(message, 400)
    end
  end

  def job_create_batch_user(conn, params)
    when params == %{}
    when params == %{"_json" => []}
  do
    conn
    |> put_status(400)
    |> render(
      ErrorView,
      "error.json",
      message: "No data provided"
    )
  end

  def job_create_batch_user(conn, params) do
    with {:ok, :queued, job_id} <- params |> UserContext.job_create_batch_user(
      conn.private[:guardian_default_resource].id,
      conn.request_path
    )
    do
      conn
      |> put_status(200)
      |> render(
        UserView,
        "create_agent_user.json",
        result: %{"id": job_id, "status": "queued"}
      )
    else
      {:error, :params_not_exists, message} ->
        conn
        |> return_error(message, 400)
      {:error, :params_is_empty, message} ->
        conn
        |> return_error(message, 400)
    end
  end

  defp return_error(conn, message, status) do
    conn
    |> put_status(status)
    |> render(
      ErrorView,
      "error.json",
      message: message
    )
  end
end
