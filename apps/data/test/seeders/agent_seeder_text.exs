defmodule Data.Seeders.AgentSeederTest do
  use Data.SchemaCase

  alias Data.Seeders.AgentSeeder

  @first_name "Janna"
  @last_name "Dela Cruz"
  @department "SDDD"
  @role "TL"
  @email "janna_delacruz@medilink.com.ph"
  @mobile "09156826861",
  @provider_id "0b4858fe-99f5-4024-9a4f-547943ee077c"

  test "seed member with new data" do
    [a1] = AgentSeeder.seed(data())
    assert a1.email == "janna_delacruz@medilink.com.ph"
  end

  defp data do
    [
      %{
        first_name: @first_name,
        last_name: @last_name,
        department: @department,
        role: @role,
        email: @email,
        mobile: @mobile,
        provider_id: @provider_id,
      }
    ]
  end
end
