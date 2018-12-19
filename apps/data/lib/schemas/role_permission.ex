defmodule Data.Schemas.RolePermission do
  @moduledoc """
  """
  use Data.Schema

  schema "role_permissions" do
    belongs_to :role, Data.Schemas.Role
    belongs_to :permission, Data.Schemas.Permission
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :role_id,
      :permission_id
    ])
    |> assoc_constraint(:permission)
    |> assoc_constraint(:role)
  end
end
