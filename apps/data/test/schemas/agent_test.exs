defmodule Data.Schemas.AgentTest do
  use Data.SchemaCase

  alias Data.Schemas.Agent
  alias Ecto.UUID

  test "create_changeset with valid params" do
    params = %{
      first_name: "Janna",
      middle_name: "Ureta",
      last_name: "Dela Cruz",
      extension: "",
      department: "SDDD",
      role: "TL",
      mobile: "09156826861",
      email: "janna_delacruz@medilink.com.ph",
      provider_id: UUID.bingenerate()
    }

    result = Agent.create_changeset(%Agent{}, params)
    assert result.valid?
  end

  test "create_changeset with invalid params" do
    params = %{
      first_name: "Janna",
      middle_name: "Ureta",
      extension: "",
      department: "SDDD",
      role: "TL",
      mobile: "09156826861",
      email: "janna_delacruz@medilink.com.ph"
    }

    result = Agent.create_changeset(%Agent{}, params)
    refute result.valid?
  end

  test "assoc_user_changeset  with valid params" do
    params = %{
      user_id: UUID.bingenerate()
    }

    result = Agent.assoc_user_changeset(%Agent{}, params)
    assert result.valid?
  end

  test "assoc_user_changeset with invalid params" do
    result = Agent.assoc_user_changeset(%Agent{}, %{})
    refute result.valid?
  end

  test "status_changeset with valid params" do
    params = %{
      status: "Pending"
    }

    result = Agent.status_changeset(%Agent{}, params)
    assert result.valid?
  end

  test "status_changeset with invalid params" do
    result = Agent.status_changeset(%Agent{}, %{})
    refute result.valid?
  end
end
