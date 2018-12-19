defmodule ProviderLinkWeb.UserView do
  use ProviderLinkWeb, :view

  def masked_mobile(mobile) do
    Enum.join(["09", "*****", String.slice(mobile, 7..10)], "")
  end

  def check_expiry(expires_at) do
    if not is_nil(expires_at) do
      utc =
        :erlang.universaltime
        |> :calendar.datetime_to_gregorian_seconds

      expiry =
        expires_at
        |> Ecto.DateTime.to_erl
        |> :calendar.datetime_to_gregorian_seconds

      expiry - utc
    else
      0
    end
  end

  def check_sent_code(sent_code) do
    if not is_nil(sent_code) do
      utc =
        :erlang.universaltime
        |> :calendar.datetime_to_gregorian_seconds

        sent_code =
          sent_code
          |> Ecto.DateTime.to_erl
          |> :calendar.datetime_to_gregorian_seconds

      expiry = (sent_code - 4 * 60)
      expiry - utc
    else
      0
    end
  end

  def join_name(user) do
    if not is_nil(user.agent) do
      Enum.join([user.agent.first_name, user.agent.middle_name, user.agent.last_name, user.agent.extension], " ") 
    else
      ""
    end
  end

end
