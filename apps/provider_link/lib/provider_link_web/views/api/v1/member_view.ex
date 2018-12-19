defmodule ProviderLinkWeb.Api.V1.MemberView do
  use ProviderLinkWeb, :view

  def render("return.json", %{return: return}) do
    %{
      results: return
     }
  end
end
