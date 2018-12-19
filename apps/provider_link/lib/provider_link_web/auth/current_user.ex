defmodule Auth.CurrentUser do
  @moduledoc """
  """

  import Plug.Conn
  alias ProviderLink.Guardian, as: PG

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = PG.current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
