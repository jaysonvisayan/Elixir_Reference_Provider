defmodule Data.Schemas.BatchTest do
    use Data.SchemaCase
  
    alias Data.Schemas.Batch
    alias Ecto.UUID
  
    test "changeset with valid params" do
      params = %{
        created_by_id: UUID.bingenerate(),
        number: "8888",
        soa_amount: "1500",
        edited_soa_amount: "2000",
        status: "Active",
        type: "LOA",
        soa_reference_no: "A12345678901234567890123456789"
      }
  
      result =
        %Batch{}
        |> Batch.changeset(params)
  
      assert result.valid?
    end
  
    test "changeset with invalid params" do
      params = %{
        created_by_id: UUID.bingenerate(),
        number: "8888",
        soa_amount: "1500",
        edited_soa_amount: "2000",
        status: "Active",
        type: "LOA",
        soa_reference_no: "B123456789012345678901234567890123456789"
      }
  
      result =
        %Batch{}
        |> Batch.changeset(params)
  
      refute result.valid?
    end
  end
  