# do not use common_passwords schema
defmodule Data.Schemas.CommonPassword do
  @moduledoc """
  """
  use Data.Schema
  use Arc.Ecto.Schema

  schema "common_passwords" do
    field :password, :string
    timestamps()
  end

  def password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:password])
    |> validate_required([:password])
  end
  
end
