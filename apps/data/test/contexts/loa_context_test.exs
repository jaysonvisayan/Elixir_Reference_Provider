defmodule Data.Contexts.LoaContextTest do
  use Data.SchemaCase

  alias Data.Contexts.LoaContext
  alias Ecto.UUID

  setup do
    payor =
      insert(:payor,
             endpoint: "https://payorlink-ip-staging.medilink.com.ph/api/v1/",
             code: "Maxicar",
             username: "masteradmin",
             password: "P@ssw0rd")
    user =
      :user
      |> insert

    {:ok, %{payor: payor, user: user}}
  end

  test "create_loa with valid params" do
    card =
      :card
      |> insert

    user =
      :user
      |> insert

    provider =
      :provider
      |> insert

    params = %{
      consultation_date: Ecto.DateTime.cast!("2017-12-15 12:12:12"),
      coverage: "consult",
      status: "approved",
      card_id: card.id,
      loa_number: "412932",
      created_by_id: user.id,
      provider_id: provider.id,
      verification_type: "member_details",
      member_card_no: "443434",
      member_birth_date: Ecto.Date.cast!("1995-11-18")
    }

    {status, result} =
      params
      |> LoaContext.create_loa()

    assert status == :ok
    assert result.coverage == "consult"
  end

  test "create_loa with invalid params" do
    card = insert(:card)
    params = %{
      consultation_date: Ecto.Date.cast!("2017-12-15"),
      status: "approved",
      card_id: card.id,
      loa_number: "412932"
    }

    {status, result} =
      params
      |> LoaContext.create_loa()

    assert status == :error
    refute result.valid?
  end

  test "update_loa with valid params" do
    card =
      :card
      |> insert

    user =
      :user
      |> insert

    provider =
      :provider
      |> insert

    loa =
      :loa
      |> insert(
        coverage: "lab",
        status: "draft",
        card_id: card.id,
        loa_number: "223341",
        consultation_date: Ecto.DateTime.cast!("2017-12-12 12:12:12"),
        created_by_id: user.id,
        provider_id: provider.id,
        verification_type: "member_details",
        member_card_no: "23232",
        member_birth_date: Ecto.Date.cast!("1994-11-18")
      )

    params = %{status: "approved"}

    {status, result} =
      loa
      |> LoaContext.update_loa(params)

    assert status == :ok
    assert result.status == "approved"
  end

  test "update_loa with invalid params" do
    card =
      :card
      |> insert()

    loa =
     :loa
     |> insert(
       coverage: "lab",
       status: "draft",
       card_id: card.id,
       loa_number: "223341",
       consultation_date: Ecto.DateTime.cast!("2017-12-12 12:12:12")
     )

    params = %{status: Ecto.Date.cast!("2017-12-12")}

    {status, result} =
      loa
      |> LoaContext.update_loa(params)

    assert status == :error
    refute result.valid?
  end

  test "get_loa_by_coverage_by_provider with return" do
    card = insert(:card)
    provider = insert(:provider)
    insert(:loa, card: card, provider: provider, coverage: "consult")

    result = LoaContext.get_loa_by_coverage_by_provider("consult", provider.id, false)

    assert length(result) == 1
  end

  test "get_loa_by_coverage_by_provider without return" do
    card = insert(:card)
    provider = insert(:provider)
    insert(:loa, card: card, provider: provider, coverage: "consult")

    result = LoaContext.get_loa_by_coverage_by_provider("lab", provider.id, false)

    assert length(result) == 0
  end

  test "get_loa_by_id with return" do
    member = insert(:member)
    card = insert(:card, member: member)
    loa = insert(:loa, card: card, coverage: "lab")
    result = LoaContext.get_loa_by_id(loa.id)
    assert result.coverage == "lab"
  end

  test "get_loa_by_id with invalid id" do
    {_, id} = UUID.load(UUID.bingenerate())
    result = LoaContext.get_loa_by_id(id)
    assert is_nil(result)
  end

  test "insert_loa_doctor with valid params" do
    doctor = insert(:doctor)
    loa = insert(:loa)
    params = %{
      loa_id: loa.id,
      doctor_id: doctor.id
    }

    {status, result} =
      params
      |> LoaContext.insert_loa_doctor()

    assert status == :ok
    assert result.loa_id == loa.id
    assert result.doctor_id == doctor.id
  end

  test "insert_loa_doctor with invalid params" do
    loa = insert(:loa)
    params = %{
      loa_id: loa.id,
    }

    {status, result} =
      params
      |> LoaContext.insert_loa_doctor()

    assert status == :error
    refute result.valid?
  end

  test "insert_loa_diagnosis with valid params" do
    id = UUID.generate
    loa = insert(:loa)
    params = %{
      loa_id: loa.id,
      payorlink_diagnosis_id: id,
      diagnosis_code: "test description",
      diagnosis_description: "test description"
    }

    {status, result} =
      params
      |> LoaContext.insert_loa_diagnosis()

    assert status == :ok
    assert result.loa_id == loa.id
  end

  test "insert_loa_diagnosis with invalid params" do
    loa = insert(:loa)
    params = %{
      loa_id: loa.id
    }

    {status, result} =
      params
      |> LoaContext.insert_loa_diagnosis()

    assert status == :error
    refute result.valid?
  end

    test "insert_loa_procedure with valid params" do
    {_, id} = UUID.load(UUID.bingenerate())
    loa_diagnosis = insert(:loa_diagnosis)
    params = %{
      loa_diagnosis_id: loa_diagnosis.id,
      payorlink_procedure_id: id,
      procedure_code: "test description",
      procedure_description: "test description",
      unit: "123",
      amount: "123"
    }

    {status, result} =
      params
      |> LoaContext.insert_loa_procedure()

    assert status == :ok
    assert result.loa_diagnosis_id == loa_diagnosis.id
  end

  test "cancel_loa cancels loa with valid params" do
    loa = insert(:loa)

    {:ok, cancel} = LoaContext.cancel_loa(loa)

    assert cancel.status == "Cancelled"

  end

  test "create_loa_api with valid params returns ok" do
    user =
      :user
      |> insert

    params = %{
      "total_amount" => 100.00,
      "status" => "approved",
      "payor_pays" => 0.00,
      "member_pays" => 100.00,
      "loa_number" => "119212",
      "created_by_id" => user.id,
      "coverage" => "acu",
      "consultation_date" => "2018-12-12 12:12:12",
      "valid_until" => "2018-12-12",
      "issue_date" => "2018-12-12 12:12:12",
      "member" => %{
        "payorlink_member_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "last_name" => "Dela Cruz",
        "gender" => "Female",
        "first_name" => "Janna",
        "birth_date" => "1992-07-30",
        "card_number" => "2832983238923"
      },
      "provider" => %{
        "payorlink_facility_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "name" => "Makati Medical Center Inc",
        "code" => "880000000006036",
        "phone_no" => "7656734",
        "email_address" => "g@medilink.com.ph",
        "line_1" => "Dela Rosa Street",
        "line_2" => "Legazpi Village",
        "city" => "Makati",
        "province" => "Metro Manila",
        "region" => "NCR",
        "country" => "Philippines",
        "postal_code" => "1200"
      },
      "diagnosis" => [
        %{
          "payorlink_diagnosis_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
          "diagnosis_code" => "test",
          "diagnosis_description" => "test"
        }
      ],
      "origin" => "payorlink",
      "payorlink_authorization_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
      "request_date" => "2018-12-12 12:12:12"
    }

    {status, result} =
      params
      |> LoaContext.create_loa_api

    assert status == :ok
    assert result.coverage == params["coverage"]
  end

  test "create_loa_api without diagnosis params returns ok" do
    user =
      :user
      |> insert

    params = %{
      "total_amount" => 100.00,
      "status" => "approved",
      "payor_pays" => 0.00,
      "member_pays" => 100.00,
      "loa_number" => "119212",
      "created_by_id" => user.id,
      "coverage" => "acu",
      "consultation_date" => "2018-12-12 12:12:12",
      "valid_until" => "2018-12-12",
      "issue_date" => "2018-12-12 12:12:12",
      "member" => %{
        "payorlink_member_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "last_name" => "Dela Cruz",
        "gender" => "Female",
        "first_name" => "Janna",
        "birth_date" => "1992-07-30",
        "card_number" => "2832983238923"
      },
      "provider" => %{
        "payorlink_facility_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "name" => "Makati Medical Center Inc",
        "code" => "880000000006036",
        "phone_no" => "7656734",
        "email_address" => "g@medilink.com.ph",
        "line_1" => "Dela Rosa Street",
        "line_2" => "Legazpi Village",
        "city" => "Makati",
        "province" => "Metro Manila",
        "region" => "NCR",
        "country" => "Philippines",
        "postal_code" => "1200"
      },
      "origin" => "payorlink",
      "payorlink_authorization_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
      "request_date" => "2018-12-12 12:12:12"
    }

    {status, result} =
      params
      |> LoaContext.create_loa_api

    assert status == :ok
    assert result.coverage == params["coverage"]
  end

  test "create_loa_api without member params returns error" do
    user =
      :user
      |> insert

    params = %{
      "total_amount" => 100.00,
      "status" => "approved",
      "payor_pays" => 0.00,
      "member_pays" => 100.00,
      "loa_number" => "119212",
      "created_by_id" => user.id,
      "coverage" => "acu",
      "consultation_date" => "2018-12-12",
      "valid_until" => "2018-12-12",
      "issue_date" => "2018-12-12",
      "provider" => %{
        "payorlink_facility_id" => "a9ec6e36-22b8-11e8-b467-0ed5f89f718b",
        "name" => "Makati Medical Center Inc",
        "code" => "880000000006036"
      }
    }

    {status, result} =
      params
      |> LoaContext.create_loa_api

    assert status == :error
    assert result.member.first_name == "First name is required"
  end

  test "create_loa_api without provider params returns error" do
    user =
      :user
      |> insert

    params = %{
      "total_amount" => 100.00,
      "status" => "approved",
      "payor_pays" => 0.00,
      "member_pays" => 100.00,
      "loa_number" => "119212",
      "created_by_id" => user.id,
      "coverage" => "acu",
      "consultation_date" => "2018-12-12",
      "valid_until" => "2018-12-12",
      "issue_date" => "2018-12-12"
    }

    {status, result} =
      params
      |> LoaContext.create_loa_api

    assert status == :error
    assert result.provider.name == "Name is required"
  end

  test "create_loa_api with invalid params" do
    user =
      :user
      |> insert

    params = %{
      "total_amount" => 100.00,
      "status" => "approved",
      "payor_pays" => 0.00,
      "member_pays" => 100.00,
      "created_by_id" => user.id,
      "coverage" => "acu",
      "consultation_date" => "2018-12-12 12:12:12",
      "valid_until" => "2018-12-12",
      "issue_date" => "2018-12-12 12:12:12"
    }

    {status, result} =
      params
      |> LoaContext.create_loa_api

    assert status == :error
    assert result.issue_date == Ecto.DateTime.cast!(params["issue_date"])
  end

  # test "get_acu_details/1" do
  #   params = %{
  #     facility_code: "880000000013184",
  #     coverage_code: "ACU",
  #     card_no: "6050831100008550",
  #   }

  #   {:ok, result} = LoaContext.get_acu_details(params)

  #   assert Map.has_key?(result, "acu_type")
  #   assert Map.has_key?(result, "package_facility_rate")
  #   assert Map.has_key?(result, "procedure")
  #   assert Map.has_key?(result, "package_name")
  #   assert Map.has_key?(result, "package_code")
  #   assert Map.has_key?(result, "acu_coverage")
  # end

   # test "request loa acu" do
   #   payor = insert(:payor, endpoint: "https://payorlink-ip-staging.medilink.com.ph/api/v1/",
   #   code: "Maxicar", username: "masteradmin", password: "P@ssw0rd")
   #   provider = insert(:provider, code: "880000000013184")
   #   agent = insert(:agent, provider: provider)
   #   user = insert(:user, agent: agent)
   #   params = %{
   #    "origin" =>"providerlink",
   #    "facilty_code" => "880000000013184",
   #    "coverage_code" => "ACU",
   #     "card_no" => "6050831100008550",
   #     "admission_date" => "2017-01-01",
   #     "discharge_date" => "2017-01-01"
   #   }

   #  raise LoaContext.request_loa_acu(params)
   # end

   test "insert_acu_loa/1" do
     params = %{
      "origin" =>"providerlink",
      "facilty_code" => "880000000013184",
      "coverage_code" => "ACU",
       "card_no" => "6050831100008550",
       "admission_date" => "2017-01-01 00:00:00",
       "discharge_date" => "2017-01-01 00:00:00"
     }

    assert {:ok, _loa} = LoaContext.insert_acu_loa(params)
   end

   describe "Adds Government ID" do
     test "with valid params" do
       loa = insert(:loa)
       params = %{
         "name" =>"providerlink"
       }

       assert {:ok, response} = LoaContext.insert_government_id(Map.put(params, "loa_id", loa.id))
     end
   end
end
