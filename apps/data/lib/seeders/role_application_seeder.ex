defmodule Data.Seeders.RoleApplicationSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_role_application(params) do
        {:ok, ra} ->
          ra
      end
    end)
  end
end
