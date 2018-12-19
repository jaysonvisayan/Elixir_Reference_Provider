defmodule Data.Schemas.LoginIpAddress do
  use Data.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [usec: false]
  schema "login_ip_addresses" do
    field :ip_address, :string
    field :attempts, :integer

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :ip_address,
      :attempts
    ])
    |> validate_required([
      :ip_address,
      :attempts
    ])
  end

end
