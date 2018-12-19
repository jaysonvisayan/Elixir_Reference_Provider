defmodule Data.Seeders.ProviderSeederTest do
  use Data.SchemaCase

  alias Data.Seeders.ProviderSeeder
  alias Ecto.UUID

  @name "Makati Medical Center"
  @code "8800000000006035"

  test "seed provider with new data" do
    [u1] = ProviderSeeder.seed(data())
    assert u1.code == @code
  end

  test "seed provider with existing data" do
    insert(:provider, code: @code)
    [u1] = ProviderSeeder.seed(data())
    assert u1.code == @code
  end

  defp data do
    [
      %{
        name: @name,
        code: @code,
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
    ]
  end

end
