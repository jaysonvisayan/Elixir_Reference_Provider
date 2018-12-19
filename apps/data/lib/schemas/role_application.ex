defmodule Data.Schemas.RoleApplication do
  @moduledoc """
  """
  use Data.Schema

  schema "role_applications" do
    belongs_to :role, Data.Schemas.Role
    belongs_to :application, Data.Schemas.Application
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :role_id,
      :application_id
    ])
    |> assoc_constraint(:role)
    |> assoc_constraint(:application)
  end
end
