defmodule Data.Schemas.LoaProcedure do
  @moduledoc """
  """

  use Data.Schema

  schema "loa_procedures" do
    field :payorlink_procedure_id, :binary_id, primary_key: true
    field :procedure_code, :string
    field :procedure_description, :string
    field :unit, :string
    field :amount, :string

    belongs_to :loa_diagnosis, Data.Schemas.LoaDiagnosis
    belongs_to :package, Data.Schemas.LoaPackage, foreign_key: :package_id
    belongs_to :loa, Data.Schemas.Loa
    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :payorlink_procedure_id,
      :loa_diagnosis_id,
      :procedure_code,
      :procedure_description,
      :unit,
      :amount,
      :loa_id,
      :package_id
    ])
  end
end
