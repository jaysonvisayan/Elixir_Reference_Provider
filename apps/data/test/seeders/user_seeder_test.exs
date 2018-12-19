defmodule Data.Seeders.UserSeederTest do
  use Data.SchemaCase

  alias Data.Seeders.UserSeeder

  @username "masteradmin"
  @password "P@ssw0rd"
  @password_confirmation "P@ssw0rd"
  @is_admin true

  test "seed user with new data" do
    [u1] = UserSeeder.seed(data())
    assert u1.username == @username
  end

  test "seed user with existing data" do
    insert(:user, username: @username)
    [u1] = UserSeeder.seed(data())
    assert u1.username == @username
  end

  defp data do
    [
      %{
        username: @username,
        password: @password,
        password_confirmation: @password_confirmation,
        is_admin: @is_admin,
      }
    ]
  end

end
