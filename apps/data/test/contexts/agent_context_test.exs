defmodule Data.Contexts.AgentContextTest do
  use Data.SchemaCase

  alias Data.Contexts.AgentContext
  alias Ecto.UUID

  test "create_agent with valid params" do
    provider = insert(:provider)
    params = %{
      first_name: "Janna",
      last_name: "Dela Cruz",
      department: "SDDD",
      role: "TL",
      mobile: "09156826861",
      email: "janna_delacruz@medilink.com.ph",
      provider_id: provider.id
    }

    {status, result} = AgentContext.create_agent(params)
    assert result.mobile == "09156826861"
    assert status == :ok
  end

  test "create_agent with invalid params" do
    params = %{
      last_name: "Dela Cruz",
      department: "SDDD",
      role: "TL",
      mobile: "09156826861",
      email: "janna_delacruz@medilink.com.ph"
    }

    {status, result} = AgentContext.create_agent(params)
    refute result.valid?
    assert status == :error
  end

  test "update_agent_user with valid params" do
    agent = insert(:agent)
    user = insert(:user, username: "test name")
    params = %{
      user_id: user.id
    }

    {status, result} =
      agent
      |> AgentContext.update_agent_user(params)

    assert status == :ok
    assert result.user_id == user.id
  end

  test "update_agent_user with invalid params" do
    agent = insert(:agent)

    {status, result} =
      agent
      |> AgentContext.update_agent_user(%{})

    assert status == :error
    refute result.valid?
  end

  test "get_agent_by_id with valid id" do
    agent = insert(:agent)

    result =
      agent.id
      |> AgentContext.get_agent_by_id()

    assert result.id == agent.id
  end

  test "get_agent_by_id with invalid id" do
    {_, id} = UUID.load(UUID.bingenerate())

    result =
      id
      |> AgentContext.get_agent_by_id()

    assert is_nil(result)
  end

  test "update_status with valid params" do
    agent = insert(:agent)

    {status, result} =
      agent
      |> AgentContext.update_status("activated")

    assert status == :ok
    assert result.status == "activated"
  end

  test "update_status with invalid params" do
    agent = insert(:agent)

    {status, result} =
      agent
      |> AgentContext.update_status(%{})

    assert status == :error
    refute result.valid?
  end
end
