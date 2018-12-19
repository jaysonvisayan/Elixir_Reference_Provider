defmodule Data.Contexts.RoleContextTest do
  use Data.SchemaCase

  alias Data.Contexts.RoleContext

  describe "update_role" do
    test "with valid id" do
      role = insert(:role)
      params =
      %{
        name: "role"
      }

      {status, result} = RoleContext.update_role(role.id, params)
      assert status == :ok
      assert result.id == role.id
    end

    test "with empty id" do
      role = insert(:role)
      params =
      %{
        name: "role"
      }

      {status, result} = RoleContext.update_role(nil, params)
      assert status == :error
      assert result == nil
    end
  end

end
