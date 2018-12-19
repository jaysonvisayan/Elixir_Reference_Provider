defmodule ProviderLinkWeb.Api.V1.ErrorView do
  use ProviderLinkWeb, :view

  def render("error.json", %{message: message}) do
    %{"message": message}
  end

  def render("changeset_error_api.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: translate_errors(changeset)}
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end


end
