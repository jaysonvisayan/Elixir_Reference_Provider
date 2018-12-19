defmodule Data.Schemas.LoaDiagnosisTest do
  use Data.SchemaCase

  alias Data.Schemas.LoaDiagnosis
  alias Ecto.UUID

  test "create_changeset with valid params" do
    params = %{
      payorlink_diagnosis_id: UUID.bingenerate(),
      diagnosis_code: "testcode",
      diagnosis_description: "test description",
      loa_id: UUID.bingenerate()
    }

    result =
      %LoaDiagnosis{}
      |> LoaDiagnosis.create_changeset(params)

    assert result.valid?
  end

  test "create_changeset with invalid params" do
    params = %{
      diagnosis_code: "testcode",
      diagnosis_description: "test description"
    }

    result =
      %LoaDiagnosis{}
      |> LoaDiagnosis.create_changeset(params)

    refute result.valid?
  end
end
