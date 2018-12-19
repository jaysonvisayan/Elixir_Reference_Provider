defmodule Data.Seeders.UserSeeder do
  @moduledoc """
  """

  alias Data.Contexts.SeederContext

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_user(params) do
        {:ok, user} ->
          user
      end
    end)
  end
end
