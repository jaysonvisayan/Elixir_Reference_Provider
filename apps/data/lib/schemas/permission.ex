defmodule Data.Schemas.Permission do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "permissions" do
    field :name, :string
    field :payorlink_application_id, :binary_id
    field :payorlink_permission_id, :binary_id
    field :status, :string
    field :description, :string
    field :module, :string
    field :keyword, :string

    # belongs_to :payor, Data.Schemas.Payor
    belongs_to :application, Data.Schemas.Application
    has_many :role_permissions, Data.Schemas.RolePermission

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :application_id,
      :name,
      :description,
      :status,
      :module,
      :keyword,
      :payorlink_application_id,
      :payorlink_permission_id
    ])
  end

end
