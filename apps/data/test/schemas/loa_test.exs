defmodule Data.Schemas.LoaTest do
  use Data.SchemaCase

  alias Data.Schemas.Loa
  alias Ecto.UUID

  test "create_changeset with valid params" do
    params = %{
      consultation_date: Ecto.DateTime.cast!("2017-12-15 12:12:12"),
      coverage: "consult",
      status: "approved",
      card_id: UUID.bingenerate(),
      loa_number: "412932",
      created_by_id: UUID.bingenerate,
      provider_id: UUID.bingenerate,
      verification_type: "member_details",
      member_card_no: "card",
      member_birth_date: Ecto.Date.cast!("1995-11-18")
  }

    result =
      %Loa{}
      |> Loa.create_changeset(params)


    assert result.valid?
  end

  test "create_changeset with invalid params" do
    params = %{
      coverage: "consult",
      status: "approved",
      card_id: UUID.bingenerate(),
      loa_number: "412932"
    }

    result =
      %Loa{}
      |> Loa.create_changeset(params)

    refute result.valid?
  end

  test "changeset_card with valid params" do
    params = %{
      card_id: UUID.bingenerate(),
      coverage: "lab",
      status: "pending",
      provider_id: UUID.bingenerate()
    }

    result =
      %Loa{}
      |> Loa.changeset_card(params)

    assert result.valid?
  end

  test "changeset_card with invalid params" do
    params = %{
      coverage: "lab",
      status: "pending",
      provider_id: UUID.bingenerate()
    }

    result =
      %Loa{}
      |> Loa.changeset_card(params)

    refute result.valid?
  end

  test "api_create_changeset with invalid params" do
    params = %{
      coverage: "acu",
      status: "approved",
      loa_number: "123312",
      member_pays: 0.00,
      payor_pays: 100,
      total_amount: 100,
      created_by_id: UUID.generate,
      card_id: UUID.generate,
      provider_id: UUID.generate,
      valid_until: "2018-12-12",
      issue_date: "2018-12-12"
    }

    result =
      %Loa{}
      |> Loa.api_create_changeset(params)

    refute result.valid?
  end

  test "api_create_changeset with valid params" do
    params = %{
      consultation_date: Ecto.DateTime.cast!("2018-12-12 12:12:12"),
      coverage: "acu",
      status: "approved",
      loa_number: "123312",
      member_pays: 0.00,
      payor_pays: 100,
      total_amount: 100,
      created_by_id: UUID.generate,
      card_id: UUID.generate,
      provider_id: UUID.generate,
      valid_until: "2018-12-12",
      issue_date: "2018-12-12 12:12:12",
      origin: "payorlink" ,
      payorlink_authorization_id: UUID.generate,
      request_date: "2018-12-12 12:12:12"
    }

    result =
      %Loa{}
      |> Loa.api_create_changeset(params)

    assert result.valid?
  end
end
