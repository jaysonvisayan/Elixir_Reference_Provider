defmodule Data.Seeders.PayorSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_payor(params) do
        {:ok, payor} ->
          payor
      end
    end)
  end
end
