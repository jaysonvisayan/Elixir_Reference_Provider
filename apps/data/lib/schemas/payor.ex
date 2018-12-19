defmodule Data.Schemas.Payor do
  @moduledoc """
  """

  use Data.Schema
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  schema "payors" do
    field :name, :string
    field :code, :string
    field :endpoint, :string
    field :username, :string
    field :password, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :name,
      :code,
      :endpoint,
      :username,
      :password
    ])
    |> validate_required([
      :name,
      :code,
      :endpoint,
      :username,
      :password
    ])
  end

end
