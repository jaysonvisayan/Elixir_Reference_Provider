defmodule ProviderLinkWeb.AgentView do
  use ProviderLinkWeb, :view

  def filter_providers(providers) do
    list = [] ++ for provider <- providers do
      provider
    end

    list =
      list
      |> Enum.map(&{"#{&1["code"]}/#{&1["name"]}", &1["id"]})

    [{"Select provider", ""}] ++ list
  end
end
