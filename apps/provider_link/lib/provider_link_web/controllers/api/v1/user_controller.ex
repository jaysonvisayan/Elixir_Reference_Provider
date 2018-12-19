defmodule ProviderLinkWeb.Api.V1.UserController do
  use ProviderLinkWeb, :controller

  alias ProviderLink.Guardian, as: PG

  alias Data.{
    Schemas.User,
    Contexts.UserContext
  }

  def match_user_payorlink(conn, params) do
    current_user = PG.current_resource_api(conn)
    with true <- not is_nil(current_user),
         {:ok, user} <- UserContext.validate_user(params) do
      conn
      |> put_status(200)
      |> render(ProviderLinkWeb.Api.V1.UserView, "user_result.json", user: user)
    else
      false ->
        error_msg(conn, 403, "Unauthorized")
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render(ProviderLinkWeb.Api.V1.ErrorView, "changeset_error_api.json", changeset: changeset)
    end
  end

  def get_users(conn, params) do
    with {:ok, username} <- UserContext.validate_user_params(params),
         user = %User{} <- UserContext.get_user_by_username(username)
    do
      conn
      |> put_status(200)
      |> render(ProviderLinkWeb.Api.V1.UserView, "user_info.json", user: user)
    else
      {:no_value_params} ->
        error_msg(conn, 400, "Please specify username value")
      {:username_required} ->
        error_msg(conn, 400, "username is required")
      {:invalid_params} ->
        error_msg(conn, 400, "Error in Server")
      nil ->
        error_msg(conn, 400, "User Not Found")
      _ ->
        error_msg(conn, 400, "Error in Server")
    end

  end

  defp error_msg(conn, status, message) do
    conn
    |> put_status(status)
    |> render(ProviderLinkWeb.Api.V1.ErrorView, "error.json", message: message)
  end

  def user_update(conn, params) do
    with {:ok, changeset} <- UserContext.validate_user_update_params(params),
         {:ok, user} <- UserContext.validate_username(changeset),
         {:ok, user} <- UserContext.update_user_information(user, changeset)
    do
      conn
      |> put_status(200)
      |> render(ProviderLinkWeb.Api.V1.UserView, "update_password.json", message: "Password Successfully Updated!")
    else
      {:error, changeset} ->
        conn
        |> put_status(403)
        |> render(ProviderLinkWeb.Api.V1.ErrorView, "changeset_error_api.json", changeset: changeset)
      nil ->
        error_msg(conn, 400, "User not found")
      _ ->
    end
  end

end
