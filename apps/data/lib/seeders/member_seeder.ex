defmodule Data.Seeders.MemberSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_member(params) do
        {:ok, member} ->
          member
      end
    end)
  end
end
