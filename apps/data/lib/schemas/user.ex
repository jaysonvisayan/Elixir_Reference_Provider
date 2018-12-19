defmodule Data.Schemas.User do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema
  alias Comeonin.Bcrypt

  schema "users" do
    field :username, :string
    field :hashed_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :avatar, :string
    field :status, :string
    field :pin, :string
    field :pin_expires_at, Ecto.DateTime
    field :attempt, :integer, default: 0
    field :is_admin, :boolean, default: false
    field :paylink_user_id, :string
    field :first_time, :boolean
    field :acu_schedule_notification, :boolean, default: false

    has_many :user_roles, Data.Schemas.UserRole, on_delete: :delete_all
    many_to_many :roles, Data.Schemas.Role, join_through: "user_roles"


    has_one :agent, Data.Schemas.Agent

    timestamps()
  end

  def auth_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :username,
      :password,
      :password_confirmation,
      :pin,
      :is_admin,
      :status,
      :paylink_user_id,
      :first_time
    ])
    |> validate_required(
      [
      :username,
      :password,
      :password_confirmation
    ],
      message: "is required"
    )
    |> validate_length(
      :username,
      min: 8,
      message: "Please enter at least 8 characters"
    )
    |> validate_length(
      :username,
      max: 20,
      message: "Please enter at most 20 characters"
    )
    |> validate_format(
      :password,
      ~r/(?=.*\d)(?=.*[a-z])/,
      message: "Password should contain apha-numeric.\n"
    )
    |> validate_format(
      :password,
      ~r/(?=.*[A-Z])/,
      message: "Password should contain atleast 1 capital letter.\n"
    )
    |> validate_format(
      :password,
      ~r/(?=.*[*_@#$&!?])/,
      message: "Password should contain special-character.\n"
    )
    |> validate_confirmation(
      :password,
      message: "Passwords do not match"
    )
    |> unique_constraint(
      :username,
      message: "Username is already taken"
    )
    |> generate_pass_hash
  end

  def create_api_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :username,
      :password,
      :password_confirmation,
      :pin,
      :is_admin,
      :status,
      :paylink_user_id
    ])
    |> validate_required(
      [
        :username,
        :password,
        :password_confirmation
      ],
      message: "is required"
    )
    |> validate_length(
      :username,
      min: 8,
      message: "Please enter at least 8 characters"
    )
    |> validate_length(
      :username,
      max: 20,
      message: "Please enter at most 20 characters"
    )
    # |> validate_format(
    #   :password,
    #   ~r/(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}/,
    #   message: "Password must be at least 8 characters and should contain alpha-numeric, special-character, atleast 1 capital letter"
    # )
    |> validate_confirmation(
      :password,
      message: "Passwords do not match"
    )
    |> unique_constraint(
      :username,
      message: "Username is already taken"
    )
    |> generate_pass_hash
  end

  def create_api_changeset2(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :username,
      :hashed_password,
      :status,
      :acu_schedule_notification,
      :pin
    ])
    |> unique_constraint(:username, message: "Username is already being used by another user!")
    |> validate_length(:username, min: 8, max: 50)
  end

  def pin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :pin,
      :pin_expires_at,
      :status
    ])
    |> validate_required([
      :pin,
    ])
  end

  # def login_attempt_changeset(struct, params \\ %{}) do
  #   struct
  #   |> cast(params, [
  #     :attempt,
  #     :status
  #   ])
  #   |> validate_required([
  #     :attempt,
  #     :status
  #   ])
  # end

  def password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :password,
      :password_confirmation,
      :attempt,
      :status,
      :first_time
    ])
    |> validate_required([
      :password,
      :password_confirmation
    ], message: "This field is a required.")
    |> validate_length(
      :password,
      min: 8,
      max: 128,
      message: "Password must be at least 8 characters and at most 128 characters\n"
    )
    |> validate_format(
      :password,
      ~r/(?=.*\d)(?=.*[a-z])/,
      message: "Password should contain apha-numeric.\n"
    )
    |> validate_format(
      :password,
      ~r/(?=.*[A-Z])/,
      message: "Password should contain atleast 1 capital letter.\n"
    )
    |> validate_format(
      :password,
      ~r/(?=.*[*_@#$&!?])/,
      message: "Password should contain special-character.\n"
    )
    |> validate_confirmation(
      :password,
      message: "Passwords do not match"
    )
    |> generate_pass_hash
  end

  def change_password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :password,
      :password_confirmation,
      :attempt,
      :first_time,
      :status
    ])
    |> validate_required([
      :password,
      :password_confirmation
    ], message: "This field is a required.")
    |> validate_length(
      :password,
      min: 8,
      max: 128,
      message: "Password must be at least 8 characters and at most 128 characters.\n",
    )
    |> validate_format(
      :password,
      ~r/(?=.*\d)(?=.*[a-z])/,
      message: "Password should contain apha-numeric.\n"
    )
    |> validate_format(
      :password,
      ~r/(?=.*[A-Z])/,
      message: "Password should contain atleast 1 capital letter.\n"
    )
    |> validate_format(
      :password,
      ~r/(?=.*[*_@#$&!?])/,
      message: "Password should contain special-character.\n"
    )
    |> validate_confirmation(
      :password,
      message: "Passwords do not match"
    )
    |> generate_pass_hash
  end

  def attempts_reset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [
      :attempt
    ])
  end

  def status_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:status])
    |> validate_required([:status])
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

  def update_user_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :password,
      :status
    ])
    |> validate_required([
      :password,
    ])
    |> generate_pass_hash
  end

  defp validate_old_password(user, changeset) do
    old_password =
      changeset
      |> Changeset.get_change(:hashed_password)

    if is_nil(old_password) do
      Brcypt.dummy_checkpw
      changeset
    else
      cond do
        # user && Bcrypt.checkpw(hashed_password, user.hashed_password) ->
        #   changeset
        user ->
          changeset
          |> Changeset.add_error(
            :old_password,
            "Invalid password",
            additional: :invalid_password)
        true ->
          Bcrypt.dummy_checkpw
          changeset
      end
    end
  end

  def register_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> generate_pass_hash()
  end
end
