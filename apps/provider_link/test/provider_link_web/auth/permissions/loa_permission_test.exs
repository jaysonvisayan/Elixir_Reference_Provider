defmodule ProviderLinkWeb.Permission.Loa do
  use ProviderLinkWeb.ConnCase
  # alias Innerpeace.Db.Schemas.User
  # alias Innerpeace.Db.Repo

  setup do
    conn = build_conn()

    {:ok, %{conn: conn}}
  end

  describe "LOA Permission /loas" do
    test "with manage_loas should have access to index", %{conn: conn} do
      u = fixture(:user_permission, %{
        keyword: "manage_loas",
        module: "LOAs"
      })
      p = insert(:provider, name: "test provider")
      insert(:agent, user: u, provider: p)
      insert(:loa, coverage: "ACU", provider: p, is_peme: false)

      conn = get authenticated(conn, u), loa_path(conn, :index)
      assert html_response(conn, 200) =~ "LOA"
    end

    test "with access_loas should have access to index", %{conn: conn} do
      u = fixture(:user_permission, %{
        keyword: "access_loas",
        module: "LOAs"
      })
      p = insert(:provider, name: "test provider")
      insert(:agent, user: u, provider: p)
      insert(:loa, coverage: "ACU", provider: p, is_peme: false)

      conn = get authenticated(conn, u), loa_path(conn, :index)
      assert html_response(conn, 200) =~ "LOA"
    end

    # test "without access", %{conn: conn} do
    #   u = fixture(:user_permission, %{
    #     keyword: "",
    #     module: ""
    #   })

    #   conn = get authenticated(conn, u), loa_path(conn, :index)

    #   assert redirected_to(conn, 302) == "/"
    # end
  end


  # describe "Account Permission /accounts/:id/edit" do
  #   test "with manage_accounts should have access to index", %{conn: conn} do
  #     u = fixture(:user_permission, %{
  #       keyword: "manage_accounts",
  #       module: "Accounts"
  #     })
  #     ag = insert(:account_group)
  #     ac = insert(:account, account_group: ag)

  #     conn = get authenticated(conn, u), account_path(conn, :edit, ac, %{step: 1})
  #     assert html_response(conn, 200) =~ "Account"
  #   end

  #   test "with access_accounts should be redirected", %{conn: conn} do
  #     u = fixture(:user_permission, %{
  #       keyword: "access_accounts",
  #       module: "Accounts"
  #     })

  #     ag = insert(:account_group)
  #     ac = insert(:account, account_group: ag)

  #     conn = get authenticated(conn, u), account_path(conn, :edit, ac, %{step: 1})
  #     assert redirected_to(conn, 302) == "/"
  #   end
  # end

  # describe "Account Permission /accounts/:id" do
  #   test "with manage_accounts should have access show", %{conn: conn} do
  #     u = fixture(:user_permission, %{
  #       keyword: "manage_accounts",
  #       module: "Accounts"
  #     })
  #     i = insert(:industry, code: "health")
  #     ag = insert(:account_group, industry: i)
  #     ac = insert(:account, account_group: ag, status: "active")
  #     p = insert(:product, code: "PRD-123")
  #     insert(:account_product, account: ac, product: p)
  #     insert(:account_group_address,
  #                  account_group: ag,
  #                  line_1: "asd",
  #                  line_2: "123",
  #                  city: "1",
  #                  province: "12",
  #                  country: "hehe",
  #                  region: "123",
  #                  postal_code: "11",
  #                  type: "test",
  #                  is_check: true)

  #     conn = get authenticated(conn, u), account_path(conn, :show, ac)
  #     assert html_response(conn, 200) =~ "Account"
  #   end

  #   test "with access_accounts should have access show", %{conn: conn} do
  #     u = fixture(:user_permission, %{
  #       keyword: "access_accounts",
  #       module: "Accounts"
  #     })
  #     i = insert(:industry, code: "health")
  #     ag = insert(:account_group, industry: i)
  #     ac = insert(:account, account_group: ag, status: "active")
  #     p = insert(:product, code: "PRD-123")
  #     insert(:account_product, account: ac, product: p)
  #     insert(:account_group_address,
  #                  account_group: ag,
  #                  line_1: "asd",
  #                  line_2: "123",
  #                  city: "1",
  #                  province: "12",
  #                  country: "hehe",
  #                  region: "123",
  #                  postal_code: "11",
  #                  type: "test",
  #                  is_check: true)

  #     conn = get authenticated(conn, u), account_path(conn, :show, ac)
  #     assert html_response(conn, 200) =~ "Account"
  #   end
  # end

end
