defmodule ProviderLinkWeb.LayoutView do
  use ProviderLinkWeb, :view

  def version do
    Application.spec(:provider_link, :vsn)
  end
  
  def image_url_for(uploader, path, resource, version \\ :original) do
    sanitize_url uploader.url({path, resource}, version)
  end

  defp sanitize_url("apps/provider_link/assets/static" <> url), do: url
  defp sanitize_url(url), do: url  |> String.replace("/apps/provider_link/assets/static", "")

  def file_url_for(uploader, path, resource) do
    sanitize_url uploader.url({path, resource}, version)
  end
end
