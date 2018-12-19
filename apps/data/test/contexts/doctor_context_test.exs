defmodule Data.Contexts.DoctorContextTest do
  use Data.SchemaCase

  alias Data.Contexts.DoctorContext
  alias Ecto.UUID

  test "get_all_doctors with result" do
    :doctor
    |> insert

    result = DoctorContext.get_all_doctors

    assert length(result) == 0
  end

  test "get_all_doctors without result" do
    result = DoctorContext.get_all_doctors

    assert length(result) == 0
  end

  test "get_all_doctors with multiple result" do
    :doctor
    |> insert

    :doctor
    |> insert

    result = DoctorContext.get_all_doctors

    assert length(result) == 0
  end

  test "get_doctor_by_prc_number with valid prc number" do
    doctor =
      :doctor
      |> insert(prc_number: "121212")

    result =
      "121212"
      |> DoctorContext.get_doctor_by_prc_number

    assert result.id == doctor.id
    assert result.prc_number == doctor.prc_number
  end

  test "get_doctor_by_prc_number with invalid prc number" do
    result =
      "121213"
      |> DoctorContext.get_doctor_by_prc_number

    assert is_nil(result)
  end

  test "create_doctor with valid params" do
    params = %{
      first_name: "Arizona",
      last_name: "Robbins",
      prc_number: "1213121",
      status: "active",
      affiliated: true,
      code: "1212121",
      payorlink_practitioner_id: UUID.generate
    }

    {status, result} =
      params
      |> DoctorContext.create_doctor

    assert result.first_name == "Arizona"
    assert status == :ok
  end

  test "create_doctor with invalid params" do
    params = %{
      first_name: "Arizona",
      last_name: "Robbins",
      prc_number: "1213121",
      status: "active",
      affiliated: true,
      code: "1212121"
    }

    {status, result} =
      params
      |> DoctorContext.create_doctor

    assert status == :error
    refute result.valid?
  end

  test "update_doctor with valid params" do
    doctor =
      :doctor
      |> insert(
        first_name: "Arizona",
        last_name: "Robbins",
        prc_number: "1213121",
        status: "active",
        affiliated: true,
        code: "1212121",
        payorlink_practitioner_id: UUID.generate
      )

    params = %{
      status: "inactive"
    }

    {status, result} =
      doctor
      |> DoctorContext.update_doctor(params)

    assert result.first_name == "Arizona"
    assert status == :ok
    refute result.status == doctor.status
  end

  test "update_doctor with invalid params" do
    doctor =
      :doctor
      |> insert(
        first_name: "Arizona",
        last_name: "Robbins",
        prc_number: "1213121",
        status: "active",
        affiliated: true,
        code: "1212121"
      )

    params = %{
      code: "1212122"
    }

    {status, result} =
      doctor
      |> DoctorContext.update_doctor(params)

    assert status == :error
    refute result.valid?
  end

  test "insert_doctor_not_exist with existing doctor" do
    doctor =
      :doctor
      |> insert(
        first_name: "Arizona",
        last_name: "Robbins",
        prc_number: "1213121",
        status: "active",
        affiliated: true,
        code: "1212121",
        payorlink_practitioner_id: UUID.generate
      )

    params = [{:ok,
      %{
        first_name: "Arizona",
        last_name: "Robbins",
        prc_number: "1213121",
        status: "active",
        affiliated: true,
        code: "1212121",
        payorlink_practitioner_id: UUID.generate
      }
    }]

    {status, result} =
      params
      |> DoctorContext.insert_doctor_not_exist

    assert status == :ok
    assert result == [doctor.id]
  end

  test "insert_doctor_not_exist with new doctor" do
    params = [{:ok,
      %{
        first_name: "Arizona",
        last_name: "Robbins",
        prc_number: "1213121",
        status: "active",
        affiliated: true,
        code: "1212121",
        payorlink_practitioner_id: UUID.generate
      }
    }]

    {status, result} =
      params
      |> DoctorContext.insert_doctor_not_exist

    assert status == :ok
    assert Enum.count(result) == 1
  end

  test "insert_doctor_not_exist with invalid params" do
    params = [{:error,
      %{
        first_name: "Arizona",
        last_name: "Robbins",
        prc_number: "1213121",
        status: "active",
        affiliated: true,
        code: "1212121"
      }
    }]

    {status, result} =
      params
      |> DoctorContext.insert_doctor_not_exist

    assert status == :ok
    assert result == [nil]
  end
end
