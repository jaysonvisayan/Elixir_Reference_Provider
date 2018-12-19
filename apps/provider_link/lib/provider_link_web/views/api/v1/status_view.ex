defmodule ProviderLinkWeb.Api.V1.StatusView do
  use ProviderLinkWeb, :view

  def render("index.json", %{version: version}) do
    %{
      status: "ok",
      version: version
    }
  end

  def render("success.json", %{}) do
    %{
        success: true
    }
  end

  def render("success2.json", %{claim: claim}) do
    %{
        success: true,
        no_of_claims: claim
    }
  end
end
