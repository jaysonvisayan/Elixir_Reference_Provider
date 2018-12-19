defmodule Data.Seeders.RolePermissionSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_role_permission(params) do
        {:ok, rp} ->
          rp
      end
    end)
  end
end
