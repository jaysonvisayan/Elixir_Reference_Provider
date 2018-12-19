defmodule Data.Seeders.AgentSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_agent(params) do
        {:ok, agent} ->
          agent
      end
    end)
  end
end
