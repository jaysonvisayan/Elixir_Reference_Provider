defmodule Data.Contexts.RoleContext do
  @moduledoc """
  """

  alias Data.Repo
  alias Data.Schemas.{
    Role,
    Permission,
    Application,
    RolePermission,
    RoleApplication
  }
  alias Innerpeace.Db.Base.{
    PermissionContext
  }

  import Ecto.Query

  def clear_role_permission_using_role_id(role_id, permission_id) do
    RolePermission
    |> where([rp], rp.role_id == ^role_id and rp.permission_id == ^permission_id)
    |> Repo.delete_all()
  end

  def get_role_application_by_role_id(role_id) do
    RoleApplication
    |> Repo.get_by(role_id: role_id)
  end

  def get_role_permission_by_role_id(role_id, permission_id) do
    RolePermission
    |> Repo.get_by(role_id: role_id, permission_id: permission_id)
  end

  def get_all_roles do
    Role
    |> order_by(asc: :updated_at)
    |> Repo.all
    |> Repo.preload([
      [role_applications: :application],
      [role_permissions: :permission],
    ])
  end

  def get_role(id) do
    Role
    |> Repo.get!(id)
    |> Repo.preload([
      [role_applications: :application],
      [role_permissions: :permission],
    ])
  end

  def get_role_permission(id) do
    RolePermission
    |> Repo.get_by!(role_id: id)
    |> Repo.preload([:permission, :role])
  end

  def create_role(role_param) do
    %Role{}
    |> Role.changeset(role_param)
    |> Repo.insert()
  end

  def create_role_permission(role_id, permission_id) do
    %RolePermission{}
    |> RolePermission.changeset(%{role_id: role_id, permission_id: permission_id})
    |> Repo.insert()
  end

  def create_role_permissions(role_id, permission_ids) do
    for permission_id <- permission_ids do
      if permission_id != "" do
        %RolePermission{}
        |> RolePermission.changeset(%{role_id: role_id, permission_id: permission_id})
        |> Repo.insert!()
      end
    end
  end

  def create_virtual_role_permission(params) do
    %RolePermission{}
    |> RolePermission.virtual_changeset(params)
    |> Repo.insert()
  end

  def update_role(nil, _param), do: {:error, nil}
  def update_role(id, role_param) do
    id
    |> get_role()
    |> Role.changeset(role_param)
    |> Repo.update()
  end

  def delete_role(id) do
    id
    |> get_role()
    |> Repo.delete()
  end

  def check_role_permission(role_id) do
    RolePermission
    |> where([rp], rp.role_id == ^role_id)
    |> select([rp], rp.permission_id)
    |> Repo.all()
  end

  def add_created_by(role, user) do
    if role.status == "submitted" do
      %{"updated_by_id" => user}
    else
      %{
        "status" => "submitted",
        "created_by_id" => user
      }
    end
  end

  def change_role(%Role{} = role) do
    Role.changeset(role, %{})
  end

  def change_role_permission(%RolePermission{} = role_permission) do
    RolePermission.changeset(role_permission, %{})
  end

  def payor_modules(param) do
    RolePermission
    |> where([rp], rp.role_id == ^param["role_permission"])
    |> Repo.delete_all()

    query = PermissionContext.load_all_permission()

    modules = Enum.map(query, fn(p) ->
      module = [p.module, "_permissions"] |> Enum.join() |> String.downcase
      param[module]
    end)

    modules
    |> Enum.reject(&(is_nil(&1)))
    |> Enum.map(fn(module) ->
      insert_role_permissions(module, param["role_permission"])
    end)
  end

  defp insert_role_permissions(module, role_id) do
    permission = PermissionContext.get_permission_by_keyword(module)
    %RolePermission{}
    |> RolePermission.changeset(%{
      role_id: role_id,
      permission_id: permission
    })
    |> Repo.insert()
  end

  def clear_role_permission do
    RolePermission
    |> where([rp], is_nil(rp.role_id) or is_nil(rp.permission_id))
    |> Repo.delete_all()
  end

  def load_role_permissions(role_id, permission_id) do
    role = Repo.get_by(RolePermission, role_id: role_id, permission_id: permission_id)

    if role != nil
    do
      permission  = Repo.get_by(Permission, id: role.permission_id)

      case permission.name =~ "Manage" do
        true ->
          "manage"
        false ->
          "access"
      end

      else
        "null"
    end
  end

  def create_role_application(role_id, application_ids) do
    RoleApplication
    |> where([ra], ra.role_id == ^role_id)
    |> Repo.delete_all
    for application_id <- application_ids do
      if application_id != "" do
        %RoleApplication{}
        |> RoleApplication.changeset(%{role_id: role_id, application_id: application_id})
        |> Repo.insert!()
      end
    end
    {:ok}
  end

  def clear_role_application(role_id, application_id) do
    RoleApplication
    |> where([ra], ra.role_id == ^role_id and ra.application_id == ^application_id)
    |> Repo.delete_all()
  end

  def create_role_application_seed(role_id, application_id) do
    %RoleApplication{}
    |> RoleApplication.changeset(%{role_id: role_id, application_id: application_id})
    |> Repo.insert()
  end

  def select_all_role_names do
    Role
    |> select([:name])
    |> Repo.all
  end

  def create_role_new(role_param) do
    %Role{}
    |> Role.changeset_role(role_param)
    |> Repo.insert()
  end

  def update_role_new(role, role_param) do
    role
    |> Role.changeset_role(role_param)
    |> Repo.update()
  end

  def get_application_by_payorlink_application_id(application_id) do
    Application
    |> Repo.get_by(payorlink_application_id: application_id)
  end

  def insert_or_update_application(params) do
    application = get_application_by_name(params.name)
    if is_nil(application) do
      create_application(params)
    else
      update_application(application.id, params)
    end
  end

  def get_application_by_name(name) do
    Application
    |> Repo.get_by(name: name)
  end

  def get_all_applications do
    Application
    |> Repo.all
    |> Repo.preload(:roles)
  end

  def get_application(id) do
    Application
    |> Repo.get!(id)
  end

  def create_application(application_param) do
    %Application{}
    |> Application.changeset(application_param)
    |> Repo.insert()
  end

  def update_application(application, application_param) do
    application =
      application
      |> check_ids
  end

  defp check_ids(nil), do: []
  defp check_ids(application_param), do: Application.changeset(application_param) |> Repo.update()

  def get_role_by_payorlink_role_id(payorlink_role_id) do
    Role
    |> where([r], r.payorlink_role_id == ^payorlink_role_id)
    |> Repo.one()
  end

  def get_role_by_name(name) do
    Role
    |> where([r], r.name == ^name)
    |> Repo.one()
  end

  def get_role_application_by_role_id(role_id, application_id) do
    RoleApplication
    |> Repo.get_by(role_id: role_id, application_id: application_id)
  end

  def get_permissions(role) do
    permissions = get_conn_role(role)

    %{
      #TODO: add permissions here
      loas: get_permissions(permissions, "LOAs"),
      acu_schedules: get_permissions(permissions, "ProviderLink_Acu_Schedules"),
      batch: get_permissions(permissions, "Batch"),
      home: get_permissions(permissions, "Home")
    }
  end

  defp get_conn_role(nil), do: permissions = []
  defp get_conn_role(role), do: role |> load_permissions

  defp load_permissions(role) do
    role =
      role
      |> Repo.preload(:permissions)

    role.permissions
  end

  defp get_permissions(permissions, module) do
    permissions
    |> loop_permissions([], module)
  end

  defp loop_permissions([], acc, module), do: acc
  defp loop_permissions([head | tail], acc, module) do
    if(head.module == module) do
      acc = acc ++ [String.to_existing_atom(head.keyword)]
    end
    loop_permissions(tail, acc, module)
  end
end
