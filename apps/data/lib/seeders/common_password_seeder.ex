defmodule Data.Seeders.CommonPasswordSeeder do
  @moduledoc """
  """

  alias Data.Contexts.SeederContext

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_common_password(params) do
        {:ok, commonPass} ->
          commonPass
      end
    end)
  end
end
