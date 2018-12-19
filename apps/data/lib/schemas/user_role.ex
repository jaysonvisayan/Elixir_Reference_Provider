defmodule Data.Schemas.UserRole do
  use Data.Schema

  schema "user_roles" do
    belongs_to :user, Data.Schemas.User
    belongs_to :role, Data.Schemas.Role

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :role_id])
  end

end
