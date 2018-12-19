defmodule ProviderLinkWeb.Api.V1.MemberController do
  use ProviderLinkWeb, :controller

  alias Data.Contexts.{
    MemberContext
  }
  alias Guardian.Plug
  alias Data.Repo

  def replicate_member(conn, %{"card_numbers" => card_numbers}) do
    provider = conn.private.guardian_default_resource.agent.provider
    failed = []
    passed = []
    try do
      return =
        card_numbers
        |> Enum.map(fn(card_number) ->
            [passed, failed] = passed_or_failed(conn, card_number, provider)
            %{passed: passed ++ passed, failed: failed ++ failed}
          end)
      passed = Enum.concat(Enum.map(return, &(&1.passed)))
      failed = Enum.concat(Enum.map(return, &(&1.failed)))
      render(conn, "return.json", return: %{passed: Enum.uniq(passed), failed: Enum.uniq(failed)})
    rescue
      _ ->
      render(conn, "return.json", return: "Invalid parameters")
    end
  end

  def replicate_member(conn, _params) do
    render(conn, "return.json", return: "Invalid parameters")
  end

  defp passed_or_failed(conn, card_number, provider) do
    try do
      with {:ok, card, member} <- MemberContext.validate_number(conn, card_number, provider) do
        [[card_number], []]
      else
        _ ->
        [[], [card_number]]
      end
    rescue
      _ ->
        [[], [card_number]]
    end
  end
end
