defmodule ProviderLinkWeb.PageController do
  use ProviderLinkWeb, :controller

  alias Data.Schemas.Card
  alias Data.Contexts.MemberContext

  def index(conn, _params) do
    pem = conn.private.guardian_default_claims["pem"]["home"]
    changeset = MemberContext.card_changeset(%Card{})
    render(conn, "index.html", changeset: changeset, permission: pem)
  end

end
