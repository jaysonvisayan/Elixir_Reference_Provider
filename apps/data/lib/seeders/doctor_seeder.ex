defmodule Data.Seeders.DoctorSeeder do
  @moduledoc """
  """

  alias Data.Contexts.{
    SeederContext
  }

  def seed(data) do
    Enum.map(data, fn(params) ->
      case SeederContext.insert_or_update_doctor(params) do
        {:ok, doctor} ->
          doctor
      end
    end)
  end
end
