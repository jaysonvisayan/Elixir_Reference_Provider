defmodule ProviderLinkWeb.Api.V1.RoleController do
  use ProviderLinkWeb, :controller

  alias Data.Contexts.{
    RoleContext,
    UtilityContext,
    PermissionContext
  }
  alias Data.Schemas.Role
  alias ProviderLinkWeb.MemberView
  alias ProviderLinkWeb.Api.V1.ErrorView
  alias ProviderLinkWeb.Api.V1.RoleView
  alias ProviderLink.Guardian, as: PG

  def create_role_api(conn, params) do
    user = PG.current_resource_api(conn)
    application = RoleContext.get_application_by_payorlink_application_id(params["payorlink_application_id"])
    with {:ok, role} <- RoleContext.create_role(params),
         {:ok} <- RoleContext.create_role_application(role.id, [application.id])
    do
      PermissionContext.update_role_permissions(params["permissions"], role.id)
      conn
      |> put_status(200)
      |> render(RoleView, "success.json", message: "Role successfully inserted.")
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(RoleView, "error.json", message: "Error Inserting Role")
      _ ->
        conn
        |> put_status(400)
        |> render(RoleView, "error.json", message: "Error Inserting Role")
    end
  end

  def update_role_api(conn, params) do
    user = PG.current_resource_api(conn)
    role = RoleContext.get_role_by_payorlink_role_id(params["payorlink_role_id"])
    application = RoleContext.get_application_by_payorlink_application_id(params["payorlink_application_id"])
    with {:ok, role} <- RoleContext.update_role(role, params),
         {:ok} <- RoleContext.create_role_application(role.id, [application.id])
    do
      PermissionContext.update_role_permissions(params["permissions"], role.id)
      conn
      |> put_status(200)
      |> render(RoleView, "success.json", message: "Role successfully inserted.")
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(RoleView, "error.json", message: "Error Inserting Role")
      _ ->
        conn
        |> put_status(400)
        |> render(RoleView, "error.json", message: "Error Inserting Role")
    end
  end

  def create_permission_api(conn, params) do
    user = PG.current_resource_api(conn)
    with {:ok} <- PermissionContext.update_all_permissions(params) do
      conn
      |> put_status(200)
      |> render(RoleView, "success.json", message: "Role successfully inserted.")
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(RoleView, "error.json", message: "Error Inserting Role")
      _ ->
        conn
        |> put_status(400)
        |> render(RoleView, "error.json", message: "Error Inserting Role")
    end
  end

  def create_permission_api(conn, params) do
    conn
    |> put_status(:not_found)
    |> render(ProviderLinkWeb.Api.V1.ErrorView, "error.json", message: "Not Found")
  end

  def create_application_api(conn, params) do
    user = PG.current_resource_api(conn)

    application = RoleContext.get_application_by_name("ProviderLink")

    with {:ok, application} <- RoleContext.update_application(application, params) do
      conn
      |> put_status(200)
      |> render(RoleView, "success.json", message: "Application Successfully updated")
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(RoleView, "error.json", message: "Error updating Application")
      _ ->
        conn
        |> put_status(400)
        |> render(RoleView, "error.json", message: "Invalid Application ID")
    end
  end
end
