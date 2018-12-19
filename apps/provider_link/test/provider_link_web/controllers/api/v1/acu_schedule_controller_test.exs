defmodule ProviderLinkWeb.Api.V1.AcuScheduleControllerTest do
  use ProviderLinkWeb.ConnCase
  # use ProviderLinkWeb.SchemaCase

  import ProviderLinkWeb.TestHelper
  alias Data.Contexts.{
    RoleContext,
    UserContext
  }

  alias ProviderLink.Guardian, as: GP

  setup do
    conn = build_conn()
    user =
      :user
      |> insert

    conn =
      conn
      |> sign_in(user)

    {:ok, %{conn: conn, user: user}}
  end

  test "create_schedule with valid_parameters", %{conn: conn} do
    user = GP.current_resource(conn)
    provider = insert(:provider, %{code: "provider_code"})
    params = %{
      "facility_id" => provider.id,
      "batch_no" => "12345",
      "account_code" => "C00918",
      "account_name" => "Jolibee Worldwide",
      "date_from" => Ecto.Date.utc(),
      "date_to" => Ecto.Date.utc(),
      "time_from" => Ecto.Time.utc(),
      "time_to" => Ecto.Time.utc(),
      "no_of_members" => "5",
      "no_of_guaranteed" => "5",
      "created_by" => user.id,
      "payorlink_acu_schedule_id" => Ecto.UUID.generate()
    }
    conn = post(conn, api_acu_schedule_path(conn, :create_schedule), params)
    assert json_response(conn, 200)
  end

  test "create_schedule with invalid_paramerters", %{conn: conn} do
    # user = GP.current_resource(conn)
    provider = insert(:provider, %{code: "provider_code"})
    params = %{
      "facility_id" => provider.id,
    }
    conn = post(conn, api_acu_schedule_path(conn, :create_schedule), params)
    assert json_response(conn, 400)
  end

  test "update_member_registration with valid parameters",%{conn: conn} do
    # user = GP.current_resource(conn)
    provider = insert(:provider, %{code: "provider_code"})
    as = insert(:acu_schedule, provider: provider, batch_no: 12345)
    card = insert(:card, number: "123123")
    loa =  insert(:loa, member_first_name: "asdasd", member_birth_date: Ecto.Date.utc(), member_card_no: "123123")
    insert(:member, card: card)
    insert(:acu_schedule_member, acu_schedule_id: as.id, loa_id: loa.id)
    params = %{
      "facility_id" => provider.id,
      "batch_no" => "12345",
      "card_no" => "123123",
      "member_card_no" => "123123"
    }
    conn = post(conn, api_acu_schedule_path(conn, :update_member_registration), params)
    assert json_response(conn, 200)
  end

  test "update_member_registration with invalid parameters",%{conn: conn} do
    # user = GP.current_resource(conn)
    provider = insert(:provider, %{code: "provider_code"})
    as = insert(:acu_schedule, provider: provider, batch_no: 12345)
    card = insert(:card, number: "123123")
    loa =  insert(:loa, member_first_name: "asdasd", member_birth_date: Ecto.Date.utc(), member_card_no: "123123")
    insert(:member, card: card)
    insert(:acu_schedule_member, acu_schedule_id: as.id, loa_id: loa.id, is_registered: true)
    params = %{
      "facility_id" => provider.id,
      "batch_no" => "12345",
      "card_no" => "123123",
      "member_card_no" => "123123"
    }
    conn = post(conn, api_acu_schedule_path(conn, :update_member_registration), params)
    assert json_response(conn, 400)
  end

  test "update_member_availment with valid parameters",%{conn: conn} do
    # user = GP.current_resource(conn)
    provider = insert(:provider, %{code: "provider_code"})
    as = insert(:acu_schedule, provider: provider, batch_no: 12345)
    card = insert(:card, number: "123123")
    insert(:member, card: card)
    loa =  insert(:loa, member_first_name: "asdasd", member_birth_date: Ecto.Date.utc(), member_card_no: "123123")
    insert(:acu_schedule_member, acu_schedule_id: as.id, loa_id: loa.id)
    params = %{
      "facility_id" => provider.id,
      "batch_no" => "12345",
      "card_no" => "123123",
      "member_card_no" => "123123"
    }
    conn = post(conn, api_acu_schedule_path(conn, :update_member_availment), params)
    assert json_response(conn, 200)
  end

  test "update_member_availment with invalid parameters",%{conn: conn} do
    # user = GP.current_resource(conn)
    provider = insert(:provider, %{code: "provider_code"})
    as = insert(:acu_schedule, provider: provider, batch_no: 12345)
    card = insert(:card, number: "123123")
    loa =  insert(:loa, member_first_name: "asdasd", member_birth_date: Ecto.Date.utc(), member_card_no: "123123")
    insert(:member, card: card)
    insert(:acu_schedule_member, acu_schedule_id: as.id, loa_id: loa.id, is_availed: true)
    params = %{
      "facility_id" => provider.id,
      "batch_no" => "12345",
      "card_no" => "123123",
      "member_card_no" => "123123"
    }
    conn = post(conn, api_acu_schedule_path(conn, :update_member_availment), params)
    assert json_response(conn, 400)
  end

  test "get_acu_schedules_by_provider_code with valid parameters", %{conn: conn} do
    provider = insert(:provider, %{code: "provider_code"})
    insert(:acu_schedule, provider: provider, batch_no: 12345)
    params = %{
      "provider_code" => provider.code
    }
    conn = get(conn, api_acu_schedule_path(conn, :get_acu_schedules_by_provider_code), params)
    assert json_response(conn, 200)
  end

  test "get_acu_schedules_by_provider_code with invalid parameters", %{conn: conn} do
    provider = insert(:provider, %{code: "provider_code"})
    insert(:acu_schedule, provider: provider, batch_no: 12345)
    params = %{
      "provider_code" => "error_data"
    }
    conn = get(conn, api_acu_schedule_path(conn, :get_acu_schedules_by_provider_code), params)
    assert json_response(conn, 404)
  end

  test "get_by_batch_no with valid paremeters", %{conn: conn} do
    provider = insert(:provider, %{code: "provider_code"})
    insert(:acu_schedule, provider: provider, batch_no: 12345, no_of_members: 2,
                no_of_selected_members: 2)
    params = %{
      "batch_no" => 12345
    }
    conn = get(conn, api_acu_schedule_path(conn, :get_by_batch_no), params)
    assert json_response(conn, 200)
  end

  test "get_by_batch_no with invalid paremeters", %{conn: conn} do
    provider = insert(:provider, %{code: "provider_code"})
    insert(:acu_schedule, provider: provider,
                batch_no: 12345, no_of_members: 2,
                no_of_selected_members: 2)
    params = %{
      "batch_no" => 1234
    }
    conn = get(conn, api_acu_schedule_path(conn, :get_by_batch_no), params)
    assert json_response(conn, 404)
  end

  test "get list batch with valid parameters", %{conn: conn} do
    provider = insert(:provider, %{code: "provider_code"})
    as = insert(:acu_schedule, provider: provider)
    insert(:acu_schedule_member, acu_schedule: as)
    conn = get(conn, api_acu_schedule_path(conn, :get_acu_schedules_by_provider_code), %{provider_code: "provider_code"})
    assert json_response(conn, 200)
  end

  test "get list batch with invalid parameters", %{conn: conn} do
    insert(:provider, %{code: "provider_code"})
    conn = get(conn, api_acu_schedule_path(conn, :get_acu_schedules_by_provider_code), %{provider_code: "provider_code"})
    assert json_response(conn, 404)
  end

  test "get list batch with invalid provider_code", %{conn: conn} do
    conn = get(conn, api_acu_schedule_path(conn, :get_acu_schedules_by_provider_code), %{provider_code: "provider_code"})
    assert json_response(conn, 404)
  end

  test "get download batch with valid parameters", %{conn: conn} do
    provider = insert(:provider, %{code: "provider_code"})
    as = insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 1111,
      no_of_members: 2, no_of_selected_members: 2
    )
    member = insert(:member)
    insert(:card, member: member)
    loa =  insert(:loa, member_first_name: "asdasd", member_birth_date: Ecto.Date.utc())
    insert(:loa_package, loa: loa, code: "123")
    insert(:acu_schedule_member, acu_schedule: as, member: member, loa: loa)
    conn = get(conn, api_acu_schedule_path(conn, :get_by_batch_no), %{
      batch_no: 1111
    })
    assert json_response(conn, 200)
  end

  test "get download batch with invalid provider_code", %{conn: conn} do
    provider = insert(:provider, %{code: "provider_code"})
    as = insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 1111)
    member = insert(:member)
    insert(:acu_schedule_member, acu_schedule: as, member: member)
    conn = get(conn, api_acu_schedule_path(conn, :get_by_batch_no), %{
      batch_no: 1112
    })
    assert json_response(conn, 404)
  end

  test "submit batch to forfeit member", %{conn: conn} do
    insert(:payor, %{name: "Maxicar", code: "Maxicar", endpoint: "test"})
    insert(:payor, %{name: "BiometricsAPI", code: "biometricsAPI", endpoint: "https://api.maxicare.com.ph/BiometricsAPI/v4/"})
    provider = insert(:provider, %{code: "provider_code"})
    insert(:sequence, %{number: "1000000", type: "batch_no"})
    as = insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 111, soa_reference_no: "1231231")
    member = insert(:member)
    loa = insert(:loa, payorlink_authorization_id: member.id)
    asm = insert(:acu_schedule_member, acu_schedule: as, member: member, loa: loa)
    conn = put(conn, api_acu_schedule_path(conn, :submit_batch, asm.id), %{
      batch_no: 111,
      registered: "5",
      unregistered: "5",
      direct_cost: "123",
      gross_adjustment: "123",
      total_amount: "123"
    })
    assert json_response(conn, 404)["message"] == "Error Creating Batch please attached soa first"
  end

  describe "Submit batch for acu schedule" do
    # test "with valid parameters", %{conn: conn} do
    #   insert(:payor, %{name: "Maxicar", code: "Maxicar", endpoint: "test"})
    #   insert(:sequence, %{number: "1000000", type: "batch_no"})
    #   provider = insert(:provider, %{code: "provider_code"})
    #   as = insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 111, soa_reference_no: "1231231")
    #   member = insert(:member)
    #   loa = insert(:loa)
    #   asm = insert(:acu_schedule_member, acu_schedule: as, member: member, loa: loa)
    #   params = %{
    #     batch_no: 111,
    #     registered: "5",
    #     unregistered: "5",
    #     direct_cost: "123",
    #     gross_adjustment: "123",
    #     total_amount: "123",
    #     availed_ids: [%{
    #       id: asm.id,
    #       base_64_encoded: "iVBORw0KGgoAAAANSUhEUgAAARIAAAEMCAIAAACHia6fAAAAA3NCSVQICAjb4U/gAAAAGXRFWHRTb2Z0d2FyZQBnbm9tZS1zY3JlZW5zaG907wO/PgAABVBJREFUeJzt3VGKGzsQQNH4kf1vOW8DtuGKorp75pzfELftmYtgCkmvf//+/QGK/65+A/A8soFMNpDJBjLZQCYbyGQD2d9P//B6vTbfx4gvM6jZj/PpQWdPmR2d7fzg1r7qHfVHYLWBTDaQyQYy2UAmG8hkA5lsIJMNZB/HnV9cvrPtYKB2MJ6b/S8HvnzM2QfNTm/rU9YMfhyrDWSygUw2kMkGMtlAJhvIZAPZydzmkzv/mX9n79TZpGV2CnT5eOTAnX9z3rLaQCYbyGQDmWwgkw1ksoFMNpDJBrLJceedHUwbD2aXX/7L2lmVg7vu+MRqA5lsIJMNZLKBTDaQyQYy2UD2W+Y2s0OY+lLfHQyOBp/CAasNZLKBTDaQyQYy2UAmG8hkA5lsIJscd975PMidMz7PtoJd/t4ud+f39pbVBjLZQCYbyGQDmWwgkw1ksoFMNpCdjDufuE9wdtp4sCF09hLC2c2qsx/nkyf+2nxitYFMNpDJBjLZQCYbyGQDmWwgez1uh9CZ2SM2L3+1Hb/kd+OA1QYy2UAmG8hkA5lsIJMNZLKBTDaQ3fcSwtmR4s62qtn54EOnjb9h153VBjLZQCYbyGQDmWwgkw1ksoFMNpBN7u5cO8TxYJ6144lbOL/YuR1xzeDHsdpAJhvIZAOZbCCTDWSygUw2kH3cprYzhDn7U/rlG6F2rI1N7nw53MEbWGC1gUw2kMkGMtlAJhvIZAOZbCCTDWSTp3L+pHnWuNkvZ3YUu/MGZoen17LaQCYbyGQDmWwgkw1ksoFMNpCdzG1m95zVp6w5GCacjSYu3ye3c9Xcmcv3RL5ltYFMNpDJBjLZQCYbyGQDmWwgkw1kH29Tu/Mxljtv4PIh4OyRpbOeeCrn4EGzVhvIZAOZbCCTDWSygUw2kMkGMtlAtjTufOLocPbjnD1ox84P9Cex2kAmG8hkA5lsIJMNZLKBTDaQTc5tTh5/g9nIbT/O2Tzn8onK7KGYgzvYbFODK8kGMtlAJhvIZAOZbCCTDWSygezkEsJPds5W/PKgg4v+Dp7yUGuj2MvnrZ+4hBCuJBvIZAOZbCCTDWSygUw2kMkGsslx55rZ7Xu3vQFv7T1f/moHXEIIDyMbyGQDmWwgkw1ksoFMNpCdzG0Gj11cuzJt9kGX72Db2Qp29pTfcDeb1QYy2UAmG8hkA5lsIJMNZLKBTDaQnYw77zzWvO1TvnwDO1/O5QPfn7RPzmoDmWwgkw1ksoFMNpDJBjLZQLZ0vODsqGft2rZBB3OGtdHEbUc9f+666c1qA5lsIJMNZLKBTDaQyQYy2UAmG8hel88BdxxMx9aGqoOnnH55tVlre/gOGHfCHckGMtlAJhvIZAOZbCCTDWSygezj7s7L79k78GXOdTACW5vozW6uvPzM1Nnp7T3H8VYbyGQDmWwgkw1ksoFMNpDJBrKl29RmHcwZZg9xPBhNzA6O7jxV25l3rd3N9pbVBjLZQCYbyGQDmWwgkw1ksoFMNpBNXkJ457MVZ+8AnN0KtnMH4Ky193b5/sK3rDaQyQYy2UAmG8hkA5lsIJMNZLKBbHLc+VCXb1b9YQ6mtzv7WAd/0FYbyGQDmWwgkw1ksoFMNpDJBjJzm49+2MayNTvnaF7LagOZbCCTDWSygUw2kMkGMtlAJhvIJsedD93vdflGqIVL88ZfbfZSx1mz++TestpAJhvIZAOZbCCTDWSygUw2kJ3MbR63qWjczk6stQHIwcdZe7VBjheEK8kGMtlAJhvIZAOZbCCTDWSygex1+RAKHsdqA5lsIJMNZLKBTDaQyQYy2UAmG8hkA9n/KEkeLX7LZuEAAAAASUVORK5CYII=",
    #       extension: "png",
    #       file_name: "image",
    #       type: "image"
    #     }]
    #   }
    #   File.write("batch.json", Poison.encode!(params))
    #   file =  File.ls!(Path.expand("./"))
    #           |> Enum.map(fn filename -> Path.join(Path.expand("./"), "batch.json") end)
    #           |> Enum.map(&String.to_charlist/1)
    #   {:ok, zip_file} = :zip.create("batch.zip", [List.first(file)])

    #   zip_base64 = Base.encode64(File.read!(zip_file))
    #   conn = post(conn, api_acu_schedule_path(conn, :acu_schedule_submit_batch), %{zip_base64: zip_base64})
    #   assert json_response(conn, 200)["success"] == true
    #   File.rm_rf!("batch.zip")
    #   File.rm_rf!("batch.json")
    #   File.rm_rf!("home")
    # end

    test "with invalid parameters/1", %{conn: conn} do
      insert(:payor, %{name: "Maxicar", code: "Maxicar", endpoint: "test"})
      insert(:sequence, %{number: "1000000", type: "batch_no"})
      provider = insert(:provider, %{code: "provider_code"})
      as = insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 111, soa_reference_no: "1231231")
      conn = post(conn, api_acu_schedule_path(conn, :acu_schedule_submit_batch), %{})
      assert json_response(conn, 404)["message"] == "zip_base64 is required"
    end

    test "with invalid parameters/2", %{conn: conn} do
      insert(:payor, %{name: "Maxicar", code: "Maxicar", endpoint: "test"})
      insert(:sequence, %{number: "1000000", type: "batch_no"})
      provider = insert(:provider, %{code: "provider_code"})
      as = insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 111, soa_reference_no: "1231231")
      member = insert(:member)
      loa = insert(:loa)
      asm = insert(:acu_schedule_member, acu_schedule: as, member: member, loa: loa)
      conn = post(conn, api_acu_schedule_path(conn, :acu_schedule_submit_batch), %{zip_base64: "123"})
      assert json_response(conn, 404)["message"] == "zip_base64 is invalid"
    end

    # test "with invalid parameters/4", %{conn: conn} do
    #   insert(:payor, %{name: "Maxicar", code: "Maxicar", endpoint: "test"})
    #   insert(:sequence, %{number: "1000000", type: "batch_no"})
    #   provider = insert(:provider, %{code: "provider_code"})
    #   as = insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 111, soa_reference_no: "1231231")
    #   member = insert(:member)
    #   loa = insert(:loa)
    #   asm = insert(:acu_schedule_member, acu_schedule: as, member: member, loa: loa)
    #   params = %{
    #     registered: "5",
    #     unregistered: "5",
    #     direct_cost: "123",
    #     gross_adjustment: "123",
    #     total_amount: "123",
    #     availed_ids: [%{
    #       id: asm.id,
    #       base_64_encoded: "iVBORw0KGgoAAAANSUhEUgAAARIAAAEMCAIAAACHia6fAAAAA3NCSVQICAjb4U/gAAAAGXRFWHRTb2Z0d2FyZQBnbm9tZS1zY3JlZW5zaG907wO/PgAABVBJREFUeJzt3VGKGzsQQNH4kf1vOW8DtuGKorp75pzfELftmYtgCkmvf//+/QGK/65+A/A8soFMNpDJBjLZQCYbyGQD2d9P//B6vTbfx4gvM6jZj/PpQWdPmR2d7fzg1r7qHfVHYLWBTDaQyQYy2UAmG8hkA5lsIJMNZB/HnV9cvrPtYKB2MJ6b/S8HvnzM2QfNTm/rU9YMfhyrDWSygUw2kMkGMtlAJhvIZAPZydzmkzv/mX9n79TZpGV2CnT5eOTAnX9z3rLaQCYbyGQDmWwgkw1ksoFMNpDJBrLJceedHUwbD2aXX/7L2lmVg7vu+MRqA5lsIJMNZLKBTDaQyQYy2UD2W+Y2s0OY+lLfHQyOBp/CAasNZLKBTDaQyQYy2UAmG8hkA5lsIJscd975PMidMz7PtoJd/t4ud+f39pbVBjLZQCYbyGQDmWwgkw1ksoFMNpCdjDufuE9wdtp4sCF09hLC2c2qsx/nkyf+2nxitYFMNpDJBjLZQCYbyGQDmWwgez1uh9CZ2SM2L3+1Hb/kd+OA1QYy2UAmG8hkA5lsIJMNZLKBTDaQ3fcSwtmR4s62qtn54EOnjb9h153VBjLZQCYbyGQDmWwgkw1ksoFMNpBN7u5cO8TxYJ6144lbOL/YuR1xzeDHsdpAJhvIZAOZbCCTDWSygUw2kH3cprYzhDn7U/rlG6F2rI1N7nw53MEbWGC1gUw2kMkGMtlAJhvIZAOZbCCTDWSTp3L+pHnWuNkvZ3YUu/MGZoen17LaQCYbyGQDmWwgkw1ksoFMNpCdzG1m95zVp6w5GCacjSYu3ye3c9Xcmcv3RL5ltYFMNpDJBjLZQCYbyGQDmWwgkw1kH29Tu/Mxljtv4PIh4OyRpbOeeCrn4EGzVhvIZAOZbCCTDWSygUw2kMkGMtlAtjTufOLocPbjnD1ox84P9Cex2kAmG8hkA5lsIJMNZLKBTDaQTc5tTh5/g9nIbT/O2Tzn8onK7KGYgzvYbFODK8kGMtlAJhvIZAOZbCCTDWSygezkEsJPds5W/PKgg4v+Dp7yUGuj2MvnrZ+4hBCuJBvIZAOZbCCTDWSygUw2kMkGsslx55rZ7Xu3vQFv7T1f/moHXEIIDyMbyGQDmWwgkw1ksoFMNpCdzG0Gj11cuzJt9kGX72Db2Qp29pTfcDeb1QYy2UAmG8hkA5lsIJMNZLKBTDaQnYw77zzWvO1TvnwDO1/O5QPfn7RPzmoDmWwgkw1ksoFMNpDJBjLZQLZ0vODsqGft2rZBB3OGtdHEbUc9f+666c1qA5lsIJMNZLKBTDaQyQYy2UAmG8hel88BdxxMx9aGqoOnnH55tVlre/gOGHfCHckGMtlAJhvIZAOZbCCTDWSygezj7s7L79k78GXOdTACW5vozW6uvPzM1Nnp7T3H8VYbyGQDmWwgkw1ksoFMNpDJBrKl29RmHcwZZg9xPBhNzA6O7jxV25l3rd3N9pbVBjLZQCYbyGQDmWwgkw1ksoFMNpBNXkJ457MVZ+8AnN0KtnMH4Ky193b5/sK3rDaQyQYy2UAmG8hkA5lsIJMNZLKBbHLc+VCXb1b9YQ6mtzv7WAd/0FYbyGQDmWwgkw1ksoFMNpDJBjJzm49+2MayNTvnaF7LagOZbCCTDWSygUw2kMkGMtlAJhvIJsedD93vdflGqIVL88ZfbfZSx1mz++TestpAJhvIZAOZbCCTDWSygUw2kJ3MbR63qWjczk6stQHIwcdZe7VBjheEK8kGMtlAJhvIZAOZbCCTDWSygex1+RAKHsdqA5lsIJMNZLKBTDaQyQYy2UAmG8hkA9n/KEkeLX7LZuEAAAAASUVORK5CYII=",
    #       extension: "png",
    #       file_name: "image",
    #       type: "image"
    #     }]
    #   }
    #   File.write("batch.json", Poison.encode!(params))
    #   file =  File.ls!(Path.expand("./"))
    #           |> Enum.map(fn filename -> Path.join(Path.expand("./"), "batch.json") end)
    #           |> Enum.map(&String.to_charlist/1)
    #   {:ok, zip_file} = :zip.create("batch.zip", [List.first(file)])

    #   zip_base64 = Base.encode64(File.read!(zip_file))
    #   conn = post(conn, api_acu_schedule_path(conn, :acu_schedule_submit_batch), %{zip_base64: zip_base64})
    #   assert json_response(conn, 404)["message"] == "batch_no is required"
    #   File.rm_rf!("batch.zip")
    #   File.rm_rf!("batch.json")
    #   File.rm_rf!("home")
    # end

    # test "with invalid parameters/5", %{conn: conn} do
    #   insert(:payor, %{name: "Maxicar", code: "Maxicar", endpoint: "test"})
    #   insert(:sequence, %{number: "1000000", type: "batch_no"})
    #   provider = insert(:provider, %{code: "provider_code"})
    #   as = insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 111, soa_reference_no: "1231231")
    #   member = insert(:member)
    #   loa = insert(:loa)
    #   asm = insert(:acu_schedule_member, acu_schedule: as, member: member, loa: loa)
    #   params = %{
    #     batch_no: 1111,
    #     registered: "5",
    #     unregistered: "5",
    #     direct_cost: "123",
    #     gross_adjustment: "123",
    #     total_amount: "123",
    #     availed_ids: [%{
    #       id: asm.id,
    #       base_64_encoded: "iVBORw0KGgoAAAANSUhEUgAAARIAAAEMCAIAAACHia6fAAAAA3NCSVQICAjb4U/gAAAAGXRFWHRTb2Z0d2FyZQBnbm9tZS1zY3JlZW5zaG907wO/PgAABVBJREFUeJzt3VGKGzsQQNH4kf1vOW8DtuGKorp75pzfELftmYtgCkmvf//+/QGK/65+A/A8soFMNpDJBjLZQCYbyGQD2d9P//B6vTbfx4gvM6jZj/PpQWdPmR2d7fzg1r7qHfVHYLWBTDaQyQYy2UAmG8hkA5lsIJMNZB/HnV9cvrPtYKB2MJ6b/S8HvnzM2QfNTm/rU9YMfhyrDWSygUw2kMkGMtlAJhvIZAPZydzmkzv/mX9n79TZpGV2CnT5eOTAnX9z3rLaQCYbyGQDmWwgkw1ksoFMNpDJBrLJceedHUwbD2aXX/7L2lmVg7vu+MRqA5lsIJMNZLKBTDaQyQYy2UD2W+Y2s0OY+lLfHQyOBp/CAasNZLKBTDaQyQYy2UAmG8hkA5lsIJscd975PMidMz7PtoJd/t4ud+f39pbVBjLZQCYbyGQDmWwgkw1ksoFMNpCdjDufuE9wdtp4sCF09hLC2c2qsx/nkyf+2nxitYFMNpDJBjLZQCYbyGQDmWwgez1uh9CZ2SM2L3+1Hb/kd+OA1QYy2UAmG8hkA5lsIJMNZLKBTDaQ3fcSwtmR4s62qtn54EOnjb9h153VBjLZQCYbyGQDmWwgkw1ksoFMNpBN7u5cO8TxYJ6144lbOL/YuR1xzeDHsdpAJhvIZAOZbCCTDWSygUw2kH3cprYzhDn7U/rlG6F2rI1N7nw53MEbWGC1gUw2kMkGMtlAJhvIZAOZbCCTDWSTp3L+pHnWuNkvZ3YUu/MGZoen17LaQCYbyGQDmWwgkw1ksoFMNpCdzG1m95zVp6w5GCacjSYu3ye3c9Xcmcv3RL5ltYFMNpDJBjLZQCYbyGQDmWwgkw1kH29Tu/Mxljtv4PIh4OyRpbOeeCrn4EGzVhvIZAOZbCCTDWSygUw2kMkGMtlAtjTufOLocPbjnD1ox84P9Cex2kAmG8hkA5lsIJMNZLKBTDaQTc5tTh5/g9nIbT/O2Tzn8onK7KGYgzvYbFODK8kGMtlAJhvIZAOZbCCTDWSygezkEsJPds5W/PKgg4v+Dp7yUGuj2MvnrZ+4hBCuJBvIZAOZbCCTDWSygUw2kMkGsslx55rZ7Xu3vQFv7T1f/moHXEIIDyMbyGQDmWwgkw1ksoFMNpCdzG0Gj11cuzJt9kGX72Db2Qp29pTfcDeb1QYy2UAmG8hkA5lsIJMNZLKBTDaQnYw77zzWvO1TvnwDO1/O5QPfn7RPzmoDmWwgkw1ksoFMNpDJBjLZQLZ0vODsqGft2rZBB3OGtdHEbUc9f+666c1qA5lsIJMNZLKBTDaQyQYy2UAmG8hel88BdxxMx9aGqoOnnH55tVlre/gOGHfCHckGMtlAJhvIZAOZbCCTDWSygezj7s7L79k78GXOdTACW5vozW6uvPzM1Nnp7T3H8VYbyGQDmWwgkw1ksoFMNpDJBrKl29RmHcwZZg9xPBhNzA6O7jxV25l3rd3N9pbVBjLZQCYbyGQDmWwgkw1ksoFMNpBNXkJ457MVZ+8AnN0KtnMH4Ky193b5/sK3rDaQyQYy2UAmG8hkA5lsIJMNZLKBbHLc+VCXb1b9YQ6mtzv7WAd/0FYbyGQDmWwgkw1ksoFMNpDJBjJzm49+2MayNTvnaF7LagOZbCCTDWSygUw2kMkGMtlAJhvIJsedD93vdflGqIVL88ZfbfZSx1mz++TestpAJhvIZAOZbCCTDWSygUw2kJ3MbR63qWjczk6stQHIwcdZe7VBjheEK8kGMtlAJhvIZAOZbCCTDWSygex1+RAKHsdqA5lsIJMNZLKBTDaQyQYy2UAmG8hkA9n/KEkeLX7LZuEAAAAASUVORK5CYII=",
    #       extension: "png",
    #       file_name: "image",
    #       type: "image"
    #     }]
    #   }
    #   File.write("batch.json", Poison.encode!(params))
    #   file =  File.ls!(Path.expand("./"))
    #           |> Enum.map(fn filename -> Path.join(Path.expand("./"), "batch.json") end)
    #           |> Enum.map(&String.to_charlist/1)
    #   {:ok, zip_file} = :zip.create("batch.zip", [List.first(file)])

    #   zip_base64 = Base.encode64(File.read!(zip_file))
    #   conn = post(conn, api_acu_schedule_path(conn, :acu_schedule_submit_batch), %{zip_base64: zip_base64})
    #   assert json_response(conn, 404)["message"] == "ACU Schedule not found"
    #   File.rm_rf!("batch.zip")
    #   File.rm_rf!("batch.json")
    #   File.rm_rf!("home")
    # end

    # test "with invalid parameters/6", %{conn: conn} do
    #   insert(:payor, %{name: "Maxicar", code: "Maxicar", endpoint: "test"})
    #   insert(:sequence, %{number: "1000000", type: "batch_no"})
    #   provider = insert(:provider, %{code: "provider_code"})
    #   as = insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 111)
    #   member = insert(:member)
    #   loa = insert(:loa)
    #   asm = insert(:acu_schedule_member, acu_schedule: as, member: member, loa: loa)
    #   params = %{
    #     batch_no: 111,
    #     registered: "5",
    #     unregistered: "5",
    #     direct_cost: "123",
    #     gross_adjustment: "123",
    #     total_amount: "123",
    #     availed_ids: [%{
    #       id: asm.id,
    #       base_64_encoded: "iVBORw0KGgoAAAANSUhEUgAAARIAAAEMCAIAAACHia6fAAAAA3NCSVQICAjb4U/gAAAAGXRFWHRTb2Z0d2FyZQBnbm9tZS1zY3JlZW5zaG907wO/PgAABVBJREFUeJzt3VGKGzsQQNH4kf1vOW8DtuGKorp75pzfELftmYtgCkmvf//+/QGK/65+A/A8soFMNpDJBjLZQCYbyGQD2d9P//B6vTbfx4gvM6jZj/PpQWdPmR2d7fzg1r7qHfVHYLWBTDaQyQYy2UAmG8hkA5lsIJMNZB/HnV9cvrPtYKB2MJ6b/S8HvnzM2QfNTm/rU9YMfhyrDWSygUw2kMkGMtlAJhvIZAPZydzmkzv/mX9n79TZpGV2CnT5eOTAnX9z3rLaQCYbyGQDmWwgkw1ksoFMNpDJBrLJceedHUwbD2aXX/7L2lmVg7vu+MRqA5lsIJMNZLKBTDaQyQYy2UD2W+Y2s0OY+lLfHQyOBp/CAasNZLKBTDaQyQYy2UAmG8hkA5lsIJscd975PMidMz7PtoJd/t4ud+f39pbVBjLZQCYbyGQDmWwgkw1ksoFMNpCdjDufuE9wdtp4sCF09hLC2c2qsx/nkyf+2nxitYFMNpDJBjLZQCYbyGQDmWwgez1uh9CZ2SM2L3+1Hb/kd+OA1QYy2UAmG8hkA5lsIJMNZLKBTDaQ3fcSwtmR4s62qtn54EOnjb9h153VBjLZQCYbyGQDmWwgkw1ksoFMNpBN7u5cO8TxYJ6144lbOL/YuR1xzeDHsdpAJhvIZAOZbCCTDWSygUw2kH3cprYzhDn7U/rlG6F2rI1N7nw53MEbWGC1gUw2kMkGMtlAJhvIZAOZbCCTDWSTp3L+pHnWuNkvZ3YUu/MGZoen17LaQCYbyGQDmWwgkw1ksoFMNpCdzG1m95zVp6w5GCacjSYu3ye3c9Xcmcv3RL5ltYFMNpDJBjLZQCYbyGQDmWwgkw1kH29Tu/Mxljtv4PIh4OyRpbOeeCrn4EGzVhvIZAOZbCCTDWSygUw2kMkGMtlAtjTufOLocPbjnD1ox84P9Cex2kAmG8hkA5lsIJMNZLKBTDaQTc5tTh5/g9nIbT/O2Tzn8onK7KGYgzvYbFODK8kGMtlAJhvIZAOZbCCTDWSygezkEsJPds5W/PKgg4v+Dp7yUGuj2MvnrZ+4hBCuJBvIZAOZbCCTDWSygUw2kMkGsslx55rZ7Xu3vQFv7T1f/moHXEIIDyMbyGQDmWwgkw1ksoFMNpCdzG0Gj11cuzJt9kGX72Db2Qp29pTfcDeb1QYy2UAmG8hkA5lsIJMNZLKBTDaQnYw77zzWvO1TvnwDO1/O5QPfn7RPzmoDmWwgkw1ksoFMNpDJBjLZQLZ0vODsqGft2rZBB3OGtdHEbUc9f+666c1qA5lsIJMNZLKBTDaQyQYy2UAmG8hel88BdxxMx9aGqoOnnH55tVlre/gOGHfCHckGMtlAJhvIZAOZbCCTDWSygezj7s7L79k78GXOdTACW5vozW6uvPzM1Nnp7T3H8VYbyGQDmWwgkw1ksoFMNpDJBrKl29RmHcwZZg9xPBhNzA6O7jxV25l3rd3N9pbVBjLZQCYbyGQDmWwgkw1ksoFMNpBNXkJ457MVZ+8AnN0KtnMH4Ky193b5/sK3rDaQyQYy2UAmG8hkA5lsIJMNZLKBbHLc+VCXb1b9YQ6mtzv7WAd/0FYbyGQDmWwgkw1ksoFMNpDJBjJzm49+2MayNTvnaF7LagOZbCCTDWSygUw2kMkGMtlAJhvIJsedD93vdflGqIVL88ZfbfZSx1mz++TestpAJhvIZAOZbCCTDWSygUw2kJ3MbR63qWjczk6stQHIwcdZe7VBjheEK8kGMtlAJhvIZAOZbCCTDWSygex1+RAKHsdqA5lsIJMNZLKBTDaQyQYy2UAmG8hkA9n/KEkeLX7LZuEAAAAASUVORK5CYII=",
    #       extension: "png",
    #       file_name: "image",
    #       type: "image"
    #     }]
    #   }
    #   File.write("batch.json", Poison.encode!(params))
    #   file =  File.ls!(Path.expand("./"))
    #           |> Enum.map(fn filename -> Path.join(Path.expand("./"), "batch.json") end)
    #           |> Enum.map(&String.to_charlist/1)
    #   {:ok, zip_file} = :zip.create("batch.zip", [List.first(file)])

    #   zip_base64 = Base.encode64(File.read!(zip_file))
    #   conn = post(conn, api_acu_schedule_path(conn, :acu_schedule_submit_batch), %{zip_base64: zip_base64})
    #   assert json_response(conn, 404)["message"] == "Error Creating Batch please attached soa first"
    #   File.rm_rf!("batch.zip")
    #   File.rm_rf!("batch.json")
    #   File.rm_rf!("home")
    # end
  end

  describe "Hide ACU schedule" do
    test "with valid parameters", %{conn: conn} do
      provider = insert(:provider, %{code: "provider_code"})
      insert(:acu_schedule, provider: provider, account_code: "account_code", batch_no: 111)

      conn = put(conn, api_acu_schedule_path(conn, :hide_acu_schedule), %{batch_no: "111"})
      assert json_response(conn, 200)
      assert json_response(conn, 200)["success"] == "ACU Schedule successfully hidden to mobile."
    end

    test "with invalid parameters", %{conn: conn} do
      conn = put(conn, api_acu_schedule_path(conn, :hide_acu_schedule), %{batch_no: "1113"})

      assert json_response(conn, 404)
      assert json_response(conn, 404)["message"] == "ACU Schedule not found."
    end

  end

end
