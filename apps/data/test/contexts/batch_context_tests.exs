defmodule Data.ContextsBatchContextTest do
  use Data.SchemaCase

  alias Data.Contexts.BatchContext
  alias Ecto.UUID

  setup do
    user = insert(:user)
    doctor = insert(:doctor,
      first_name: "Shaira",
      last_name: "Dizon",
      prc_number: "PRC-1234567",
      status: "validated",
      affiliated: true,
      code: "040296",
      payorlink_practitioner_id: "0b1b6194-f987-4818-9d22-03bfa7405332"
    )
    batch = insert(:batch,
      doctor_id: doctor.id,
      soa_reference_no: "123",
      soa_amount: 123,
      type: "practitioner")

    {:ok, %{doctor: doctor, batch: batch, user: user}}
  end

  test "list all batchs", %{batch: batch} do
    assert BatchContext.list_all() == [batch]
  end

  test "get batch returns batch when batch id is valid", %{batch: batch} do
    assert batch |> preload == BatchContext.get_batch(batch.id)
  end

  test "get batch returns nil when batch id is invalid" do
    assert nil == BatchContext.get_batch("5ec5c72e-2978-4d0e-8990-611934c1cb96")
  end

  test "create_batch/1 creates batch with valid attributes", %{batch: batch, user: user} do
    params = %{
      doctor_id: doctor.id,
      soa_reference_no: "123",
      soa_amount: 123,
      type: "practitioner"
    }
    created_batch = BatchContext.create_batch(params, user.id)
    assert created_batch == batch
  end

  test "create_batch/1 does not create batch with invalid attributes", %{batch: batch, user: user} do
    params = %{
      doctor_id: doctor.id,
      soa_reference_no: "123",
      type: "practitioner"
    }
    created_batch = BatchContext.create_batch(params, user.id)
    assert {:error, batch} == created_batch
  end

end
