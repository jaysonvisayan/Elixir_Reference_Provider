defmodule ProviderLinkWeb.SessionView do
  use ProviderLinkWeb, :view

  def check_expiry(expires_at) do
    utc =
      :erlang.universaltime
      |> :calendar.datetime_to_gregorian_seconds

    expiry =
      expires_at
      |> Ecto.DateTime.to_erl
      |> :calendar.datetime_to_gregorian_seconds

    expiry - utc
  end

  def get_last_mobile_no(user) do
    String.slice(user.agent.mobile, 9..10)
  end

end
