defmodule Data.Schemas.DoctorProvider do
    @moduledoc """
    """
    use Data.Schema
  
    schema "doctor_providers" do
      belongs_to :doctor, Data.Schemas.Doctor
      belongs_to :provider, Data.Schemas.Provider
      timestamps()
    end
  
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [
          :doctor_id,
          :provider_id
        ])
    end
  end