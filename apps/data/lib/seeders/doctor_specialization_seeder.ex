defmodule Data.Seeders.DoctorSpecializationSeeder do
    @moduledoc """
    """
  
    alias Data.Contexts.{
      SeederContext
    }
  
    def seed(data) do
      Enum.map(data, fn(params) ->
        case SeederContext.insert_or_update_doctor_specialization(params) do
          {:ok, doctor_specialization} ->
            doctor_specialization
        end
      end)
    end
  end
  