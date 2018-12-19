defmodule Data.Seeders.ProviderSeeder do
  @moduledoc """
  """

  alias Data.Contexts.SeederContext

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_provider(params) do
        {:ok, provider} ->
          provider
      end
    end)
  end
end
