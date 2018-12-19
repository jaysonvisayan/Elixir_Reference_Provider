defmodule Data.SchemaCase do
  @moduledoc """
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias Ecto.Changeset

  using do
    quote do
      alias Data.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Data.SchemaCase
      import Data.Factories
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Data.Repo)

    unless tags[:async] do
      Sandbox.mode(Data.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      changeset = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
