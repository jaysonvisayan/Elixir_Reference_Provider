defmodule Data.Seeders.UserRoleSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_user_role(params) do
        {:ok, ur} ->
          ur
      end
    end)
  end
end
