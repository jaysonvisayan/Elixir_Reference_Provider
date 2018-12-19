defmodule ProviderLinkWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import ProviderLinkWeb.Router.Helpers
      use ProviderLinkWeb.SchemaCase
      alias Data.Contexts.{
        UserContext,
        RoleContext
      }

      # The default endpoint for testing
      @endpoint ProviderLinkWeb.Endpoint

      def authenticated(conn, user) do
        role = UserContext.get_first_role(user)
        permissions = RoleContext.get_permissions(role)
        random = Ecto.UUID.generate
        secure_random = "#{user.id}+#{random}"

        conn
        |> bypass_through(ProviderLinkWeb.Router, [:browser])
        |> get("/")
        |> add_random_cookie(random)
        |> ProviderLink.Guardian.Plug.sign_in(secure_random, pem: permissions)
        |> send_resp(200, "Logged in")
        |> recycle()
      end

      defp add_random_cookie(conn, random) do
        random
        |> encrypt256
        |> store_cookie(conn)
      end

      defp encrypt256(value) do
        :sha256
        |> :crypto.hash(value)
        |> Base.encode16()
      end

      defp store_cookie(value, conn) do
        conn
        |> put_resp_cookie("nova", value, [
            secure: false,
            http_only: true,
            domain: conn.host
           ])
      end

      # def authenticated_test(conn, user) do
      #   role = UserContext.get_first_role(user)
      #   permissions = RoleContext.get_permissions(role)

      #   conn
      #   |> bypass_through(ProviderLinkWeb.Router, [:auth_api])
      #   |> get("/api")
      #   |> ProviderLink.Guardian.Plug.sign_in(user, pem: permissions)
      #   |> send_resp(200, "Logged in")
      # end

      def fixture(:user_permission, permission) do
        a = insert(:application, name: "ProviderLink")
        p = insert(:permission, keyword: permission.keyword, application: a, module: permission.module)
        r = insert(:role, name: "trial role")
        rp = insert(:role_permission, role: r, permission: p)
        u = insert(:user, username: "blahblah")
        insert(:user_role, role: r, user: u)
        u
      end
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

end
