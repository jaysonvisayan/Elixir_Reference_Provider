defmodule ProviderLinkWeb.Api.V1.RoleView do
  use ProviderLinkWeb, :view

  def render("success.json", %{message: message}) do
  %{
     success: message
   }
  end

  def render("error.json", %{message: message}) do
  %{
     error: message
   }
  end
end
