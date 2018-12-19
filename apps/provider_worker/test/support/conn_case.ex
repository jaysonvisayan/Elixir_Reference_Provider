defmodule ProviderWorkerWeb.ConnCase do
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
      import ProviderWorkerWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint ProviderWorkerWeb.Endpoint

      def authenticated(conn, user) do
        conn
        |> bypass_through(ProviderWorkerWeb.Router, [:browser])
        |> get("/")
        |> ProviderLink.Guardian.Plug.sign_in(user)
        |> send_resp(200, "Logged in")
      end
    end
  end


  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

end
