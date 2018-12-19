defmodule Data.Schemas.UserPassword do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema
  alias Comeonin.Bcrypt
  alias Ecto.Changset

  schema "user_passwords" do
    field :hashed_password, :string
    field :password, :string, virtual: true

    belongs_to :user, Data.Schemas.User

    timestamps()
  end

  def password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :password,
      :user_id
    ])
    |> validate_required([:password, :user_id])
    |> generate_pass_hash
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :user_id,
      :password
    ])
    |> validate_required([
      :user_id,
      :password
    ])
  end


  # Private methods
  defp generate_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :hashed_password,
                   Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
