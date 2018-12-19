defmodule Data.Contexts.ProviderContextTest do
  use Data.SchemaCase

  alias Data.Contexts.ProviderContext
  alias Ecto.UUID

  test "get_all_providers with return" do
    insert(:provider, name: "test provider", code: "test code")

    result = ProviderContext.get_all_providers()

    assert length(result) == 1
  end

  test "get_all_providers without return" do
    result = ProviderContext.get_all_providers()

    assert length(result) == 0
  end

  test "get_provider_by_code with return" do
    provider = insert(:provider, name: "test provider", code: "test code")

    result = ProviderContext.get_provider_by_code("test code")

    assert result.code == provider.code
  end

  test "get_provider_by_code without return" do
    insert(:provider, name: "test provider", code: "test code")

    result = ProviderContext.get_provider_by_code("test")

    assert is_nil(result)
  end

  test "create_provider with valid params" do
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
      |> ProviderContext.create_provider()

    assert status == :ok
    assert result.name == "test name"
  end

  test "create_provider with invalid params" do
    params = %{
      name: "test name",
    }

    {status, result} =
      params
      |> ProviderContext.create_provider()

    assert status == :error
    refute result.valid?
  end

  test "update_provider with valid params" do
    provider = insert(:provider)
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
      provider
      |> ProviderContext.update_provider(params)

    assert status == :ok
    assert result.name == "test name"
  end

  test "update_provider with invalid params" do
    provider = insert(:provider)
    params = %{
      name: "test name",
    }

    {status, result} =
      provider
      |> ProviderContext.update_provider(params)

    assert status == :error
    refute result.valid?
  end

  test "insert_provider_not_exist with invalid params" do
    params = %{
      code: "test"
    }

    {status, result} =
      params
      |> ProviderContext.insert_provider_not_exist

    assert status == :error
    refute result.valid?
  end

  test "insert_provider_not_exist with new provider code" do
    params = %{
      code: "test",
      name: "test",
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
      |> ProviderContext.insert_provider_not_exist

    assert status == :ok
    assert result.name == params.name
  end

  test "insert_provider_not_exist with existing provider code" do
    provider =
      :provider
      |> insert(
        code: "test"
      )

    params = %{
      code: "test",
      name: "test"
    }

    {status, result} =
      params
      |> ProviderContext.insert_provider_not_exist

    assert status == :ok
    assert result.id == provider.id
    refute result.name == params.name
  end
end
