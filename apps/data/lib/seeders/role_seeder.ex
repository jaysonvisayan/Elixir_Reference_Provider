defmodule Data.Seeders.RoleSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_role(params) do
        {:ok, role} ->
          role
      end
    end)
  end
end
