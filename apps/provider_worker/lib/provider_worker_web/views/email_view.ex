defmodule ProviderWorkerWeb.EmailView do
  use ProviderWorkerWeb, :view

  def display_username(struct) do
    if struct |> Map.has_key?("username") do
      struct["username"]
    end
  end
end
