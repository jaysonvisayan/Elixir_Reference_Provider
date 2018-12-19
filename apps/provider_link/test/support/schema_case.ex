defmodule ProviderLinkWeb.SchemaCase do
  @moduledoc """
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias Data.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import ProviderLinkWeb.SchemaCase
      import ProviderLinkWeb.Factory
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Data.Repo)

    unless tags[:async] do
      Sandbox.mode(Data.Repo, {:shared, self()})
    end

    :ok
  end
end
