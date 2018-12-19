defmodule Data.Schemas.Role do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "roles" do
    field :name, :string
    field :description, :string
    field :status, :string
    field :created_by_id, :binary_id
    field :updated_by_id, :binary_id
    field :step, :integer
    field :approval_limit, :decimal
    field :pii, :boolean, default: false
    field :create_full_access, :string
    field :payorlink_role_id, :binary_id
    field :no_of_days, :integer
    field :cut_off_dates, {:array, :integer}
    field :member_permitted, :boolean, default: false

    has_many :role_permissions, Data.Schemas.RolePermission
    has_many :role_applications, Data.Schemas.RoleApplication
    has_many :user_roles, Data.Schemas.UserRole, on_delete: :delete_all
    many_to_many :users, Data.Schemas.User, join_through: "user_roles"
    many_to_many :permissions, Data.Schemas.Permission, join_through: "role_permissions"


    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :name,
      :description,
      :status,
      :created_by_id,
      :updated_by_id,
      :step,
      :approval_limit,
      :pii,
      :create_full_access,
      :payorlink_role_id,
      :no_of_days,
      :cut_off_dates,
      :member_permitted
    ])
  end

end
