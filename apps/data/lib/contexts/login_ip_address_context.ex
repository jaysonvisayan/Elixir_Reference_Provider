defmodule Data.Contexts.LoginIpAddressContext do
  @moduledoc """
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Data.Repo
  alias Data.Schemas.LoginIpAddress

  def get_ip_address(ip_address) do
    LoginIpAddress
    |> Repo.get_by(ip_address: ip_address)
  end

  def create_ip_address(ip_address) do
    params =
    %{
      ip_address: ip_address,
      attempts: 0
    }
    %LoginIpAddress{}
    |> LoginIpAddress.changeset(params)
    |> Repo.insert()
  end

  def update_ip_address(ip, params) do
    ip
    |> LoginIpAddress.changeset(params)
    |> Repo.update()
  end

  def add_attempt(ip_address) do
    ip_address
    |> update_ip_address(%{attempts: ip_address.attempts + 1})
  end

  def remove_attempt(ip) do
    ip
    |> Ecto.Changeset.change(%{attempts: 0})
    |> Repo.update()
  end

end
