defmodule ProviderWorkerWeb.PageController do
  use ProviderWorkerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
