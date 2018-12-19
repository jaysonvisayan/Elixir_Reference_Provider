defmodule Data.Schemas.Specialization do
    @moduledoc """
    """
    use Data.Schema
  
    schema "specializations" do
      field :name, :string
      field :type, :string
      field :payorlink_specialization_id, :binary_id

      timestamps()
    end
  
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [
          :name,
          :type,
          :payorlink_specialization_id
        ])
    end
  end