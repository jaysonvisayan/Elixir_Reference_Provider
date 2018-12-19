defmodule Data.Schemas.LoaDiagnosis do
  @moduledoc """
  """

  use Data.Schema

  schema "loa_diagnoses" do
    field :payorlink_diagnosis_id, :binary_id
    field :diagnosis_code, :string
    field :diagnosis_description, :string

    has_many :loa_procedure, Data.Schemas.LoaProcedure, on_delete: :delete_all
    belongs_to :loa, Data.Schemas.Loa

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :loa_id,
      :payorlink_diagnosis_id,
      :diagnosis_code,
      :diagnosis_description
    ])
    |> validate_required([
      :loa_id,
      :payorlink_diagnosis_id,
      :diagnosis_code,
      :diagnosis_description
    ])
  end
end
