defmodule Data.Contexts.AcuScheduleContextTest do
  use Data.SchemaCase


  alias Data.Contexts.AcuScheduleContext, as: ASC
  alias Data.Repo
  alias Ecto.UUID

  setup do
    provider = insert(:provider)
    batch = insert(:batch)
    acu_schedule =
       insert(:acu_schedule, batch_no: 111, payorlink_acu_schedule_id: UUID.generate(), provider: provider)
    member = insert(:member, payorlink_member_id: UUID.generate())

    {:ok, %{acu_schedule: acu_schedule, member: member, provider: provider}}
  end

  test "get_acu_schedule/1 valid", %{acu_schedule: acu_schedule} do
    result = ASC.get_acu_schedule(acu_schedule.id)

    assert result.batch_no == 111
  end

  test "get_acu_schedule/1 invalid" do
    acu_schedule = insert(:agent)

    result = ASC.get_acu_schedule(acu_schedule.id)

    assert is_nil(result)
  end

  test "get_acu_schedule_by_payorlink_id/1 valid", %{acu_schedule: acu_schedule} do
    result = ASC.get_acu_schedule_by_payorlink_id(acu_schedule.payorlink_acu_schedule_id)

    refute is_nil(result)
  end

  test "get_acu_schedule_by_payorlink_id/1 invalid", %{acu_schedule: acu_schedule} do
    acu_schedule = Map.put(acu_schedule, :payorlink_acu_schedule_id, UUID.generate())
    result = ASC.get_acu_schedule_by_payorlink_id(acu_schedule.payorlink_acu_schedule_id)

    assert is_nil(result)
  end

  test "insert_schedule/1 valid" do
    assert {:ok, _result} = ASC.insert_schedule(acu_schedule_params2())
  end

  test "insert_schedule/1 invalid" do
    assert {:error, _result} = ASC.insert_schedule(Map.delete(acu_schedule_params2(), "account_code"))
  end

  test "insert_acu_member/1 valid", %{acu_schedule: acu_schedule, member: member} do
    params = %{
      "member_id" => member.payorlink_member_id,
      "id" => acu_schedule.payorlink_acu_schedule_id
    }

    assert {:ok, _result} = ASC.insert_acu_member(params)
  end

  test "insert_acu_member/1 invalid", %{member: member} do
    params = %{
      "member_id" => member.payorlink_member_id,
      "id" => member.id
    }

    assert is_nil(ASC.insert_acu_member(params))
  end

  test "insert_schedule_member/1 valid", %{acu_schedule: acu_schedule, member: member} do
    params = %{
      "member_id" => member.payorlink_member_id,
      "id" => acu_schedule.payorlink_acu_schedule_id
    }

    assert {:ok, _result} = ASC.insert_acu_member(params)
  end

  test "get_member_by_payorlink_id/1 valid", %{member: member} do
    result = ASC.get_member_by_payorlink_id(member.payorlink_member_id)

    refute is_nil(result)
  end

  test "get_member_by_payorlink_id/1 invalid", %{member: member} do
    result = ASC.get_member_by_payorlink_id(member.id)

    assert is_nil(result)
  end

  test "get_acu_schedule_member/1 valid", %{member: member} do
    asm = insert(:acu_schedule_member, member: member)

    result = ASC.get_acu_schedule_member(asm.id)

    refute is_nil(result)
  end

  test "get_acu_schedule_member/1 invalid", %{member: member} do
    result = ASC.get_acu_schedule_member(member.id)

    assert is_nil(result)
  end

  # test "update_encode_status/1 valid", %{member: member} do
  #   asm = insert(:acu_schedule_member, member: member)

  #   {n, _} = ASC.update_encode_status([asm.id])

  #   assert n == 1
  # end

  test "update_encode_status/1 invalid" do
    {n, _} = ASC.update_encode_status([])

    assert n == 0
  end

  test "update_asm_loa_status/2 valid" do
    asm = insert(:acu_schedule_member)
    params = %{
      status: "Availed"
    }

    assert {:ok, _result} = ASC.update_asm_loa_status(asm, params)
  end

  test "update_acu_schedule_status/2 valid", %{acu_schedule: acu_schedule} do
    params = %{
      status: "Submitted"
    }

    assert {:ok, _result} = ASC.update_acu_schedule_status(acu_schedule, params)
  end

  test "update_acu_schedule_status/2 invalid", %{acu_schedule: acu_schedule} do
    params = %{}

    assert {:error, _result} = ASC.update_acu_schedule_status(acu_schedule, params)
  end

  test "get_acu_schedules/2 valid" do
    provider = insert(:provider)
    insert(:acu_schedule, provider: provider, account_code: "C00980")

    result = ASC.get_acu_schedules(provider.id, "C00980")

    refute Enum.empty?(result)
  end

  test "get_acu_schedules/2 invalid" do
    provider = insert(:provider)
    insert(:acu_schedule, provider: provider, account_code: "C00980")

    result = ASC.get_acu_schedules(provider.id, "C00981")

    assert Enum.empty?(result)
  end

  test "update_member_registration/1 valid" do
    asm = insert(:acu_schedule_member)

    assert {:ok, _result} = ASC.update_member_registration(asm)
  end

  test "update_member_availment/1 valid" do
    asm = insert(:acu_schedule_member)

    assert {:ok, _result} = ASC.update_member_availment(asm)
  end

  test "get_all_acu_schedule_by_provider/1 valid", %{acu_schedule: acu_schedule} do
    result = ASC.get_all_acu_schedule_by_provider(acu_schedule.provider.id)

    refute Enum.empty?(result)
  end

  test "get_all_acu_schedule_by_provider/1 invalid" do
    provider = insert(:provider)
    result = ASC.get_all_acu_schedule_by_provider(provider.id)

    assert Enum.empty?(result)
  end

  test "load_acu/1 valid", %{acu_schedule: acu_schedule} do
    result = ASC.load_acu(acu_schedule.id)

    refute is_nil(result)
  end

  test "load_acu/1 invalid", %{member: member} do
    result = ASC.load_acu(member.id)

    assert is_nil(result)
  end

  test "get_member_by_schedule_id/1 valid", %{acu_schedule: acu_schedule} do
    insert(:acu_schedule_member, acu_schedule: acu_schedule)

    result = ASC.get_member_by_schedule_id(acu_schedule.id)

    refute Enum.empty?(result)
  end

  test "get_member_by_schedule_id/1 invalid", %{acu_schedule: acu_schedule} do
    asm = insert(:acu_schedule_member, acu_schedule: acu_schedule)

    result = ASC.get_member_by_schedule_id(asm.id)

    assert Enum.empty?(result)
  end

  test "get_package_acu_schedule/1 valid", %{acu_schedule: acu_schedule} do
    loa = insert(:loa)
    insert(:acu_schedule_member, acu_schedule: acu_schedule, loa: loa)
    loa_package = insert(:loa_package, loa: loa, code: "Code", description: "Description", details: "Details")

    acu_schedule = preload(acu_schedule)

    result = ASC.get_package_acu_schedule(acu_schedule)

    assert result == [%{
      code: loa_package.code,
      description: loa_package.description,
      details: loa_package.details
    }]
  end

  test "get_package_acu_schedule/1 invalid", %{acu_schedule: acu_schedule} do
    loa = insert(:loa)
    insert(:loa_package, loa: loa, code: "0-100")
    insert(:acu_schedule_member, acu_schedule: acu_schedule, loa: loa)
    acu_schedule = preload(acu_schedule)

    result = ASC.get_package_acu_schedule(acu_schedule)

    refute Enum.empty?(result)
  end

  test "get_acu_package_by_member_id/1 valid", %{acu_schedule: acu_schedule, member: member} do
    insert(:acu_schedule_member, acu_schedule: acu_schedule)
    insert(:loa, payorlink_member_id: member.id)

    result = ASC.get_acu_package_by_member_id(member.id)

    refute Enum.empty?(result)
  end

  test "get_acu_package_by_member_id/1 invalid", %{member: member} do
    insert(:acu_schedule_member, member: member)

    result = ASC.get_acu_package_by_member_id(member.id)

    assert Enum.empty?(result)
  end

  test "get_all_acu_schedule_by_provider_id/1 valid", %{acu_schedule: acu_schedule} do
    result = ASC.get_all_acu_schedule_by_provider_id(acu_schedule.provider.id)

    refute Enum.empty? (result)
  end

  test "get_all_acu_schedule_by_provider_id/1 invalid" do
    provider = insert(:provider)
    result = ASC.get_all_acu_schedule_by_provider_id(provider.id)

    assert Enum.empty? (result)
  end

  test "get_all_acu_schedule_by_account_code/2 valid", %{provider: provider} do
    insert(:acu_schedule, provider: provider, account_code: "C00980")

    result = ASC.get_all_acu_schedule_by_account_code("C00980", provider.id)

    refute Enum.empty?(result)
  end

  test "get_all_acu_schedule_by_account_code/2 invalid", %{provider: provider} do
    insert(:acu_schedule, provider: provider, account_code: "C00980")

    result = ASC.get_all_acu_schedule_by_account_code("C00981", provider.id)

    assert Enum.empty?(result)
  end

  test "get_schedule_by_batch_no/1 valid" do
    result = ASC.get_schedule_by_batch_no(111)

    refute is_nil(result)
  end

  test "get_schedule_by_batch_no/1 invalid" do
    assert {:error, nil} = ASC.get_schedule_by_batch_no(112)
  end

  # defp acu_schedule_params do
  #   %{
  #     facility_id: UUID.generate(),
  #     account_code: "COO980",
  #     account_name: "Jollibee World Wide",
  #     account_address: "Jollibee st.",
  #     batch_no: 11111111,
  #     created_by: "Admin is trator",
  #     date_from: Ecto.Date.utc(),
  #     date_to: Ecto.Date.utc(),
  #     time_from: "09:00:00",
  #     time_to: "10:00:00",
  #     no_of_members: 10,
  #     no_of_guaranteed: 10,
  #     payorlink_acu_schedule_id: UUID.generate(),
  #     acu_email_sent: false
  #    }
  # end

  defp acu_schedule_params2 do
    %{
      "facility_id" => UUID.generate(),
      "account_code" => "COO980",
      "account_name" => "Jollibee World Wide",
      "account_address" => "Jollibee st.",
      "batch_no" => 11111111,
      "created_by" => "Admin is trator",
      "date_from" => Ecto.Date.utc(),
      "date_to"=> Ecto.Date.utc(),
      "time_from" => "09:00:00",
      "time_to" => "10:00:00",
      "no_of_members" => 10,
      "no_of_guaranteed" => 10,
      "payorlink_acu_schedule_id" => UUID.generate(),
      "acu_email_sent" => false
     }
  end

  # defp batch_params do
  #   %{
  #     facility_id: UUID.generate(),
  #     account_code: "COO980",
  #     account_name: "Jollibee World Wide",
  #     account_address: "Jollibee st.",
  #     batch_no: 11111111,
  #     created_by: "Admin is trator",
  #     date_from: Ecto.Date.utc(),
  #     date_to: Ecto.Date.utc(),
  #     time_from: "09:00:00",
  #     time_to: "10:00:00",
  #     no_of_members: 10,
  #     no_of_guaranteed: 10,
  #     payorlink_acu_schedule_id: UUID.generate()
  #    }
  # end

  defp preload(struct) do
    Repo.preload(struct, [acu_schedule_members: [loa: :loa_packages]])
  end

  test "update_acu_schedule_soa_ref_no/2 valid" do
    provider = insert(:provider)
    acu_schedule = insert(:acu_schedule, provider: provider, account_code: "C00980")
    soa_ref_no = "sampleSOAno"
    assert {:ok, _changeset} = ASC.update_acu_schedule_soa_ref_no(acu_schedule, soa_ref_no)
  end

  describe "Adds batch_id column to acu schedule" do
    test "with valid data" do
      batch = insert(:batch)
      acu_schedule = insert(:acu_schedule, account_code: "C00980")
      assert {:ok, acu_schedule} = ASC.update_acu_schedule_batch_id(acu_schedule, batch.id)
    end
  end

  #test "emailer sends email to user upon creation of acu schedule" do
  #  #TODO:
  #  # setup permission
  #  # setup role
  #  # setup user
  #  # setup user_role
  #  # setup acu_schedule
  #  # call function(emailer)
  #  a = insert(:application, name: "ProviderLink")
  #  f = insert(:provider)
  #  p = insert(:permission,
  #  name: "Manage ACU Schedules",
  #  module: "Acu_Schedules",
  #  keyword: "manage_acu_schedules",
  #  application: a
  #  )
  #  role = insert(:role, name: "Sender")
  #  role_application = insert(:role_application, role: role, application: a)
  #  role_permission = insert(:role_permission, role: role, permission: p)
  #  u = insert(:user, acu_schedule_notification: true)
  #  ur = insert(:user_role, user: u, role: role)
  #  agent = insert(:agent, user: u, provider: f, first_name: "Test", email: "test@test.com")
  #  as = insert(:acu_schedule, status: nil, acu_email_sent: false, no_of_guaranteed: 1, batch_no: 12345, account_name: "TEST ACCT", provider: f)
  #  asm = insert(:acu_schedule_member, acu_schedule: as)

  #  ASC.emailer()

  #  result = ASC.get_acu_schedule(as.id).acu_email_sent

  #  assert result == true
  #end
end
