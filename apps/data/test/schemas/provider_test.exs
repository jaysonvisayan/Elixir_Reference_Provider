defmodule Data.Schemas.ProviderTest do
  use Data.SchemaCase

  alias Data.Schemas.Provider
  alias Ecto.UUID

  test "create_changeset with valid params" do
    params = %{
      name: "test provider name",
      code: "test provider code",
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

    result =
      %Provider{}
      |> Provider.create_changeset(params)

    assert result.valid?
  end

  test "create_changeset with invalid params" do
    params = %{
      code: "test provider code"
    }

    result =
      %Provider{}
      |> Provider.create_changeset(params)

    refute result.valid?
  end
end
