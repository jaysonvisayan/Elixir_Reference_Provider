defmodule Data.Contexts.SeederContextTest do
  use Data.SchemaCase

  alias Data.Contexts.SeederContext
  alias Ecto.UUID

  test "insert_or_update_user with valid params" do
    params = %{
      username: "Janna123",
      password: "P@ssw0rd",
      password_confirmation: "P@ssw0rd"
    }

    {status, result} = SeederContext.insert_or_update_user(params)
    assert status == :ok
    assert result.username == "Janna123"
  end

  test "insert_or_update_user with invalid params" do
    params = %{
      username: "Janna"
    }

    {status, result} = SeederContext.insert_or_update_user(params)
    assert status == :error
    refute result.valid?
  end

  test "insert_or_update_provider with valid params" do
    params = %{
      name: "test name",
      code: "test code",
      payorlink_facility_id: UUID.generate,
      phone_no: "7656734",
      email_address: "g@medilink.com.ph",
      line_1: "Dela Rosa Street",
      line_2: "Legazpi Village",
      city: "Makati",
      province: "Metro Manila",
      region: "NCR",
      country: "Philippines",
      postal_code: "1200"
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_provider()

    assert status == :ok
    assert result.name == "test name"
  end

  test "insert_or_update_provider with invalid params" do
    params = %{
      code: "test code"
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_provider()

    assert status == :error
    refute result.valid?
  end

  test "insert_or_update_card with valid params" do
    member =
      :member
      |> insert

    params = %{
      number: "1234567890123456",
      member_id: member.id,
      payorlink_member_id: UUID.generate
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_card()

    assert status == :ok
    assert result.member_id == member.id
  end

  test "insert_or_update_card with invalid params" do
    params = %{
      number: "1234567890123456",
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_card()

    assert status == :error
    refute result.valid?
  end

  test "insert_or_update_doctor with valid params" do
    params = %{
      first_name: "first_name",
      last_name: "last_name",
      prc_number: "1234567",
      status: "active",
      affiliated: true,
      code: "237283",
      payorlink_practitioner_id: UUID.generate
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_doctor()

    assert status == :ok
    assert result.last_name == "last_name"
  end

  test "insert_or_update_doctor with invalid params" do
    params = %{
      first_name: "first_name",
      prc_number: "1234567"
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_doctor()

    assert status == :error
    refute result.valid?
  end

  test "insert_or_update_agent with valid params" do
    provider =
      :provider
      |> insert

    user =
      :user
      |> insert

    params = %{
      first_name: "firstname",
      last_name: "lastname",
      department: "department",
      role: "role",
      mobile: "09156826861",
      email: "janna_delacruz@medilink.com.ph",
      provider_id: provider.id,
      user_id: user.id
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_agent()

    assert status == :ok
    assert result.mobile == "09156826861"
  end

  test "insert_or_update_agent with invalid params" do
    provider =
      :provider
      |> insert

    user =
      :user
      |> insert

    params = %{
      first_name: "first_name",
      last_name: "lastname",
      department: "department",
      role: "role",
      mobile: "09156826861",
      email: "janna_delacruz@medilink.com.ph",
      provider_id: provider.id,
      user_id: user.id
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_agent()

    assert status == :error
    refute result.valid?
  end

  test "insert_or_update_payor with valid params" do
    params = %{
      code: "MAXICAR",
      name: "test",
      endpoint: "test",
      username: "test",
      password: "test"
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_payor()

    assert status == :ok
    assert result.code == "MAXICAR"
  end

  test "insert_or_update_payor with invalid params" do
    params = %{
      code: "MAXICAR",
      endpoint: "test",
      username: "test",
      password: "test"
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_payor()

    assert status == :error
    refute result.valid?
  end

  test "insert_or_update_member with valid params" do
    {_, id} = UUID.load(UUID.bingenerate)
    params = %{
      payorlink_member_id: id,
      first_name: "first_name",
      middle_name: "middle_name",
      last_name: "last_name",
      extension: "extension",
      gender: "gender",
      birth_date: "1997-09-21",
      pin: "pin"
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_member()

    assert status == :ok
    assert result.first_name == "first_name"
  end

  test "insert_or_update_member with invalid params" do
    {_, id} = UUID.load(UUID.bingenerate)
    params = %{
      payorlink_member_id: id,
      middle_name: "middle_name",
      last_name: "last_name",
      extension: "extension",
      gender: "gender",
      birth_date: "birth_date",
      pin: "pin"
    }

    {status, result} =
      params
      |> SeederContext.insert_or_update_member()

    assert status == :error
    refute result.valid?
  end
end
