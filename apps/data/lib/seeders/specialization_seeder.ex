defmodule Data.Seeders.SpecializationSeeder do
    @moduledoc false
  
    alias Data.Contexts.{
        SeederContext
      }
  
    def seed(data) do
      Enum.map(data, fn(params) ->
        case SeederContext.insert_or_update_specialization(params) do
          {:ok, specialization} ->
            specialization
        end
      end)
    end
  end
  