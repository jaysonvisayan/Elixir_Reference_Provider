defmodule Data.Seeders.ApplicationSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_application(params) do
        {:ok, application} ->
          application
      end
    end)
  end
end
