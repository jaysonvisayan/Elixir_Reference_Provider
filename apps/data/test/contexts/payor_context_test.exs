defmodule Data.Contexts.PayorContextTest do
  use Data.SchemaCase

  alias Data.Contexts.PayorContext

  test "get_payor_by_code with valid code" do
    payor = insert(:payor, code: "MAXICAR")
    result = PayorContext.get_payor_by_code("MAXICAR")
    assert result.code == payor.code
  end

  test "get_payor_by_code with invalid code" do
    insert(:payor, code: "MAXICAR")
    result = PayorContext.get_payor_by_code("MAXICA")
    assert is_nil(result)
  end

  test "create_payor with valid params" do
    params = %{
      code: "MAXICAR",
      name: "test",
      endpoint: "test",
      username: "test",
      password: "test"
    }

    {status, result} = PayorContext.create_payor(params)
    assert status == :ok
    assert result.code == "MAXICAR"
  end

  test "create_payor with invalid params" do
    params = %{
      name: "test",
      endpoint: "test",
      username: "test",
      password: "test"
    }

    {status, result} = PayorContext.create_payor(params)
    assert status == :error
    refute result.valid?
  end

  test "update_payor with valid params" do
    payor = insert(:payor)
    params = %{
      code: "MAXICAR",
      name: "test",
      endpoint: "test",
      username: "test",
      password: "test"
    }

    {status, result} = PayorContext.update_payor(payor, params)
    assert status == :ok
    assert result.code == "MAXICAR"
  end

  test "update_payor with invalid params" do
    payor = insert(:payor)
    params = %{
      name: "test",
      endpoint: "test",
      username: "test",
      password: "test"
    }

    {status, result} = PayorContext.update_payor(payor, params)
    assert status == :error
    refute result.valid?
  end

end
