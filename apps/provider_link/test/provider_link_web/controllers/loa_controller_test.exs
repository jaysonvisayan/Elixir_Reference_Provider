defmodule ProviderLinkWeb.LoaControllerTest do
  use ProviderLinkWeb.ConnCase
  # use ProviderLinkWeb.SchemaCase
  # import ProviderLinkWeb.TestHelper

  # alias ProviderLinkWeb.MemberView

  setup do
    conn = build_conn()
    user = fixture(:user_permission, %{keyword: "manage_loas", module: "LOAs"})
    conn = authenticated(conn, user)
    # user = insert(:user)
    # conn = sign_in(conn, user)
    {:ok, %{conn: conn}}
  end

  # test "lab renders request loa lab form", %{conn: conn} do
  #   payor = insert(:payor,
  #                  code: "Maxicar",
  #                  name: "Maxicare",
  #                  endpoint: "https://payorlink-ip-staging.medilink.com.ph/api/v1/",
  #                  username: "masteradmin",
  #                  password: "P@ssw0rd")
  #   member = insert(:member, payor: payor)
  #   card = insert(:card, member: member)
  #   provider = insert(:provider)
  #   loa = insert(:loa, card: card, provider: provider)
  #   conn =
  #     conn
  #     |> get("/loas/#{loa.id}/request/lab")
  #       assert html_response(conn, 200) =~ "Lab LOA Request"
  # end

  # test "lab do not render request loa lab form when member is not authenticated", %{conn: conn} do
  #   payor = insert(:payor,
  #                  code: "Maxicar",
  #                  name: "Maxicare",
  #                  endpoint: "https://payorlink-ip-staging.medilink.com.ph/api/v1/",
  #                  username: "masteradmin",
  #                  password: "P@ssw0rd")
  #   member = insert(:member, payor: payor)
  #   card = insert(:card, member: member)
  #   provider = insert(:provider, name: "Makati")
  #   loa = insert(:loa, card: card, provider: provider)
  #   conn =
  #     conn
  #     |> get("/loas/#{loa.id}/request/lab")
  #       assert html_response(conn, 200) =~ "404"
  # end

  test "update_lab insert updates loa with coverage loa and return loa when params are valid", %{conn: conn} do
    member = insert(:member)
    card = insert(:card, member: member)
    loa = insert(:loa, card: card)
    doctor = insert(:doctor)
    provider =
      :provider
      |> insert

    user =
      :user
      |> insert

    params =
      %{
        "card_id": card.id,
        "doctor_id": doctor.id,
        "coverage": "lab",
        "consultation_date": Ecto.DateTime.cast!("2017-12-30 12:12:12"),
        "provider_id": provider.id,
        "created_by_id": user.id,
        "verification_type": "member_details",
        "member_card_no": "232323",
        "member_birth_date": Ecto.Date.cast!("1995-11-18")
      }
    conn =
      conn
      |> post("/loas/#{loa.id}/update/lab", %{"lab": params})
    assert redirected_to(conn) == loa_path(conn, :index)
  end

  test "update_lab insert updates loa with coverage lab and return error when params are invalid", %{conn: conn} do
    member = insert(:member)
    card = insert(:card, member: member)
    loa = insert(:loa, card: card)
    doctor = insert(:doctor)
    params =
      %{
        "card_id": card.id,
        "doctor_id": doctor.id,
        "coverage": "lab",
      }

    conn =
      conn
      |> post("/loas/#{loa.id}/update/lab", %{"lab": params})

    assert html_response(conn, 302) =~ loa_path(conn, :lab, loa.id)
  end

  test "test verified_loa_peme not yet within admission_date", %{conn: conn} do
    member = insert(:member)
    card = insert(:card, member: member)
    loa = insert(:loa, card: card)

    loa_params =
      %{
        "admission_date": "2019-10-18 00:00:00"
      }
    conn = post conn, loa_path(conn, :verified_loa_peme, loa, loa: loa_params)
    assert conn.private[:phoenix_flash]["error"] =~ "Please verify within schedule PEME date."
    assert redirected_to(conn) == loa_path(conn, :show_peme, loa)
  end

  # test "update_diagnosis inserts loa with coverage loa and return loa when params are valid", %{conn: conn} do
  #   payor = insert(:payor,
  #                  code: "Maxicar",
  #                  name: "Maxicare",
  #                  endpoint: "https://payorlink-ip-staging.medilink.com.ph/api/v1/",
  #                  username: "masteradmin",
  #                  password: "P@ssw0rd")
  #   member = insert(:member)
  #   card = insert(:card, member: member)
  #   loa = insert(:loa, card: card)
  #   params =
  #     %{
  #       "loa": %{
  #       "loa_id": loa.id,
  #       "diagnosis_id": "0b88365a-71fa-420b-952c-5b2e6ce31628",
  #       "payor_code": payor.code
  #         },
  #       "procedure": [%{"procedure_code": "3571eff5-2f2a-42b8-a674-aabef40081a0"}],
  #       }
  #   conn =
  #     conn
  #     |> post("/loas/#{loa.id}/update/diagnosis", params)
  #   assert redirected_to(conn) == loa_path(conn, :lab, loa.id)
  # end

  # test "update_diagnosis does not inserts loa with coverage loa when params are invalid", %{conn: conn} do
  #   payor = insert(:payor,
  #                  code: "Maxicar",
  #                  name: "Maxicare",
  #                  endpoint: "https://payorlink-ip-staging.medilink.com.ph/api/v1/",
  #                  username: "masteradmin",
  #                  password: "P@ssw0rd")

  #   member = insert(:member, payor: payor)
  #   card = insert(:card, member: member)
  #   loa = insert(:loa, card: card)
  #   params =
  #     %{
  #       "loa": %{
  #         "loa_id": loa.id,
  #         "diagnosis_id": "0b88365a-71fa-420b-952c-5b2e6ce31628",
  #         "payor_code": payor.code
  #       },
  #       "procedure": [%{"procedure_id": "3571eff5-2f2a-42b8-a674-aabef40081a0"}]
  #       }
  #   conn =
  #     conn
  #     |> post("/loas/#{loa.id}/update/diagnosis", params)
  #       assert html_response(conn, 302) =~ loa_path(conn, :lab, loa.id)
  # end

  # TO BE REFACTORED
  # test "cancel_lab cancels loa returns success when params are invalid", %{conn: conn} do
  #   card = insert(:card)
  #   loa = insert(:loa, card: card, consultation_date: Ecto.DateTime.utc)
  #   conn =
  #     conn
  #     |> get("/loas/#{loa.id}/cancel")
  #   assert json_response(conn, 200) == render_json("message.json", message: "success")
  # end

  # test "cancel_lab cancels loa returns fail when params are invalid", %{conn: conn} do
  #   card = insert(:card)
  #   loa = insert(:loa, card: card, consultation_date: Ecto.DateTime.cast!("1990-01-01 12:12:12"))
  #   conn =
  #     conn
  #     |> get("/loas/#{loa.id}/cancel")
  #   assert json_response(conn, 200) == render_json("message.json", message: "fail")
  # end

  # test "cancel_lab cancels loa returns error when params are invalid", %{conn: conn} do
  #   card = insert(:card)
  #   loa = insert(:loa, card: card, consultation_date: Ecto.DateTime.cast!("1990-01-01 12:12:12"))
  #   conn =
  #     conn
  #     |> get("/loas/#{loa.id}/cancel")
  #   assert json_response(conn, 200) == render_json("message.json", message: "fail")
  # end

  # defp render_json(template, assigns) do
  #   assigns = Map.new(assigns)

  #   template
  #   |> MemberView.render(assigns)
  #   |> Poison.encode!
  #   |> Poison.decode!
  # end

  # test "POST add_to_cart valid", %{conn: conn} do
  #   loa_1 = insert(:loa)
  #   loa_2 = insert(:loa)
  #   conn = post conn, loa_path(conn, :add_to_cart), loa_ids: "#{loa_1.id},#{loa_2.id}"

  #   assert html_response(conn, 302) =~ loa_path(conn, :index)
  #   assert conn.private[:phoenix_flash]["info"] =~ "LOA successfully added to cart"
  # end

  # test "POST add_to_cart invalid", %{conn: conn} do
  #   loa_1 = insert(:loa)
  #   loa_2 = insert(:loa)
  #   conn = post conn, loa_path(conn, :add_to_cart), loa_ids: [loa_1.id, loa_2.id]

  #   assert html_response(conn, 302) =~ loa_path(conn, :index)
  #   assert conn.private[:phoenix_flash]["error"] =~ "Error adding items to cart"
  # end

  # test "add_to_cart adds selected loa to cart for batching", %{conn: conn} do
  #   member = insert(:member,
  #                   gender: "Male",
  #                   birth_date: Ecto.Date.cast!("2001-12-25"),
  #   )
  #   card = insert(:card,
  #                 number: "#{Enum.random(1_000_000_000_000_000..9_999_999_999_999_999)}",
  #                 member: member
  #   )
  #   loa = insert(:loa,
  #                status: "Approved",
  #                loa_number: "#{Enum.random(10000..99999)}",
  #                member: member,
  #                card: card,
  #                total_amount: Decimal.new(1000),
  #                id: Ecto.UUID.generate(),
  #   )
  #   loa = Repo.preload(loa, [card: :member])
  #   params = %{
  #     "id": loa.id
  #   }
  #   conn = get conn, loa_path(conn, :add_to_cart, params)
  #   assert html_response(conn, 302) =~ loa_path(conn, :index)
  #   assert get_flash(conn, :info) == "LOA added to cart"
  # end

  # test "add_to_batch adds cart loa to batch", %{conn: conn} do
  #   member = insert(:member,
  #                   gender: "Male",
  #                   birth_date: Ecto.Date.cast!("2001-12-25"),
  #   )
  #   card = insert(:card,
  #                 number: "#{Enum.random(1_000_000_000_000_000..9_999_999_999_999_999)}",
  #                 member: member
  #   )
  #   loa = insert(:loa,
  #                status: "Approved",
  #                loa_number: "#{Enum.random(10000..99999)}",
  #                member: member,
  #                card: card,
  #                total_amount: Decimal.new(1000),
  #                id: Ecto.UUID.generate(),
  #                is_cart: true
  #   )
  #   loa = Repo.preload(loa, [card: :member])
  #   params = %{
  #     "id": loa.id
  #   }
  #   params = Poison.encode!(params)
  #   conn = get conn, loa_path(conn, :add_to_batch, params)
  #   assert get_flash(conn, :info) == "LOA added to batch"
  #   assert html_response(conn, 302) =~ loa_path(conn, :index)
  # end

  # test "removes loa to cart", %{conn: conn} do
  #   member = insert(:member,
  #                   gender: "Male",
  #                   birth_date: Ecto.Date.cast!("2001-12-25"),
  #   )
  #   card = insert(:card,
  #                 number: "#{Enum.random(1_000_000_000_000_000..9_999_999_999_999_999)}",
  #                 member: member
  #   )
  #   loa = insert(:loa,
  #                status: "Approved",
  #                loa_number: "#{Enum.random(10000..99999)}",
  #                member: member,
  #                card: card,
  #                total_amount: Decimal.new(1000),
  #                id: Ecto.UUID.generate(),
  #                is_cart: true
  #   )
  #   loa = Repo.preload(loa, [card: :member])
  #   params = %{
  #     "id": loa.id
  #   }
  #   params = Poison.encode!(params)
  #   conn = get conn, loa_path(conn, :remove_to_cart, loa.id)
  #   assert get_flash(conn, :info) == "LOA removed to cart!"
  #   assert html_response(conn, 302) =~ loa_path(conn, :index)
  # end
end
