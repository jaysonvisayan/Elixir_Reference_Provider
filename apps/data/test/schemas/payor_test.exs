defmodule Data.Schemas.PayorTest do
  use Data.SchemaCase

  alias Data.Schemas.Payor

  test "changeset with valid params" do
    params = %{
      name: "test name",
      code: "Maxicar",
      endpoint: "https://payorlink-ip-staging.medilink.com.ph/api/v1/",
      username: "masteradmin",
      password: "P@ssw0rd"
    }

    result =
      %Payor{}
      |> Payor.changeset(params)

    assert result.valid?
  end

  test "changeset with invalid params" do
    result =
      %Payor{}
      |> Payor.changeset(%{})

    refute result.valid?
  end
end
