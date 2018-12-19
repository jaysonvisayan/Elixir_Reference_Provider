defmodule Data.Seeders.CardSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_card(params) do
        {:ok, card} ->
          card
      end
    end)
  end
end
