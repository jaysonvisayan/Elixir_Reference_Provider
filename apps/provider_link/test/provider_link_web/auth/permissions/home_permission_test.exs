defmodule ProviderLinkWeb.Permission.Home do
  use ProviderLinkWeb.ConnCase
  # alias Innerpeace.Db.Schemas.User
  # alias Innerpeace.Db.Repo

  setup do
    conn = build_conn()

    {:ok, %{conn: conn}}
  end

  # describe "Home Permission /validate_member_by_details" do
  #   test "with manage_home should have access to validate member by details", %{conn: conn} do
  #     u = fixture(:user_permission, %{
  #       keyword: "manage_home",
  #       module: "Home"
  #     })
  #     p = insert(:provider, name: "test provider", code: "1234")
  #     insert(:agent, user: u, provider: p)
  #     insert(:loa, coverage: "ACU", provider: p, is_peme: false)
  #     insert(:payor, endpoint: "http://localhost:4000/api/v1/",
  #            name: "Maxicare",
  #            code: "Maxicar",
  #            username: "masteradmin",
  #            password: "P@ssw0rd"
  #     )

  #     full_name = "test_user"
  #     birth_date = "2011-02-02"
  #     coverage = "ACU"

  #     conn = get authenticated(conn, u), loa_path(conn, :validate_member_by_details, full_name, birth_date, coverage)
  #     raise conn
  #     assert html_response(conn, 200) =~ ""
  #   end
  # end
end
