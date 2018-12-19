defmodule ProviderLinkWeb.Api.V1.BatchView do
  use ProviderLinkWeb, :view

  def render("upload.json", %{batch: batch, status: status}) do
    %{
      status: status
    }
  end

  def render("loa_cart.json", %{loa: loa}) do
    %{
      count: Enum.count(loa)
    }
  end
end
