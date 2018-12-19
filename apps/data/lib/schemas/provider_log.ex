defmodule Data.Schemas.ProviderLog do
    @moduledoc """
    """

    use Data.Schema
  
    schema "provider_logs" do
        field :module, :string
        field :module_id, :binary_id
        field :details, :string
        field :remarks, :string
        timestamps()
    end
  
    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [
        :module,
        :module_id,
        :details,
        :remarks
      ])
    end
  
  end
  