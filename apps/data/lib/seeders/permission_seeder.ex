defmodule Data.Seeders.PermissionSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_permission(params) do
        {:ok, permission} ->
          permission
      end
    end)
  end
end
