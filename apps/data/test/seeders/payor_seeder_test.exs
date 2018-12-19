defmodule Data.Seeders.PayorSeederTest do
  use Data.SchemaCase

  alias Data.Seeders.PayorSeeder

  @code "MAXICAR"
  @name "Maxicare"
  @endpoint "test"
  @username "masteradmin"
  @password "test"

  test "seed member with new data" do
    [m1] = PayorSeeder.seed(data())
    assert m1.code == @code
  end

  test "seed member with existing data" do
    insert(:payor, code: @code)
    [m1] = PayorSeeder.seed(data())
    assert m1.code == @code
  end

  defp data do
    [
      %{
        code: @code,
        name: @name,
        endpoint: @endpoint,
        username: @username,
        password: @password
      }
    ]
  end

end
