defmodule Data.Schemas.DoctorSpecialization do
    @moduledoc """
    """
    use Data.Schema
  
    schema "doctor_specializations" do
      field :name, :string
      field :type, :string
      field :payorlink_practitioner_specialization_id, :binary_id
  
      belongs_to :doctor, Data.Schemas.Doctor
      belongs_to :specialization, Data.Schemas.Specialization
      timestamps()
    end
  
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [
          :doctor_id,
          :specialization_id,
          :name,
          :type,
          :payorlink_practitioner_specialization_id
         ])
      |> validate_required([:doctor_id, :name, :type])
    end
  end