defmodule Data.Schemas.Agent do
  @moduledoc """
  """

  use Data.Schema

  schema "agents" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :extension, :string
    field :department, :string
    field :role, :string
    field :mobile, :string
    field :email, :string
    field :status, :string # activated
    field :recovery, :string, virtual: true
    field :text, :string, virtual: true
    field :verification, :boolean
    field :verification_code, :string
    field :verification_expiry, Ecto.DateTime

    belongs_to :user, Data.Schemas.User
    belongs_to :provider, Data.Schemas.Provider

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :first_name,
      :middle_name,
      :last_name,
      :extension,
      :department,
      :role,
      :mobile,
      :email,
      :status,
      :provider_id,
      :user_id
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :department,
      :role,
      :mobile,
      :email,
      :provider_id
    ], message: "This is required.")
    |> validate_format(:first_name,
                       ~r/^[ña-zÑA-Z\s.-]*$/,
                       message: "The first name you have entered is invalid")
    |> validate_format(:middle_name,
                       ~r/^[ña-zÑA-Z\s.-]*$/,
                       message: "The middle name you have entered is invalid")
    |> validate_format(:last_name,
                       ~r/^[ña-zÑA-Z\s.-]*$/,
                       message: "The last name you have entered is invalid")
    |> validate_format(:extension,
                       ~r/^[ña-zÑA-Z\s.]*$/,
                       message: "The extension you have entered is invalid")
    |> validate_format(:email,
                       ~r/^[A-Za-z0-9._,-]+@[A-Za-z0-9._,-]+\.[A-Za-z]{2,4}$/,
                       message: "The email you have entered is invalid")
    |> validate_format(:mobile, ~r/^0[0-9]{10}$/, message: "The Mobile number you have entered is invalid")
  end

  def create_changeset_api(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :first_name,
      :middle_name,
      :last_name,
      :extension,
      :role,
      :mobile,
      :email,
      :status,
      :user_id,
      :provider_id
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :role,
      :mobile,
      :email,
      :status,
      :provider_id
    ])
  end

  def assoc_user_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :user_id
    ])
    |> validate_required([
      :user_id
    ])
  end

  def status_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :status
    ])
    |> validate_required([
      :status
    ])
  end

  def changeset_forgot_password(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :recovery,
      # :username,
      :text
    ])
    |> validate_required([
      :recovery,
      # :username,
      :text
    ])
  end

 def changeset_agent(struct, params \\ %{}) do
    struct
    |> cast(params, [
     :first_name,
      :middle_name,
      :last_name,
      :extension,
      :department,
      :role,
      :mobile,
      :email,
      :status,
      :provider_id,
      :user_id,
      :verification_code,
      :verification_expiry
    ])
    # |> validate_required([
    #   :member_id,
    #   :username
      # :email
    # ])
    # |> unique_constraint(:username, message: "Username is already being used by another user!")
    |> unique_constraint(:email, message: "Email is already being used by another user!")
    |> unique_constraint(:mobile, message: "Mobile Number is already being used by another user!")
    |> validate_mobile(:mobile)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    # |> validate_email(:email
    # |> validate_length(:username, min: 5, max: 50)
    |> validate_length(:email, max: 50)
    |> put_change(:password_token, Ecto.UUID.generate())
    |> put_change(:verification, false)
  end

  def expiry_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:verification_expiry])
    |> validate_required([:verification_expiry])
  end

  def validate_mobile(changeset, field) do
    mobile = get_field(changeset, field)
    if mobile != nil && String.length(mobile) != 11 do
      add_error(changeset, field, "must be 11 digits")
    else
      changeset
    end
  end

  def verification_code_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :verification_code
    ])
  end

  def verification_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:verification])
    |> validate_required([:verification])
  end

   def pnumber_or_email_changeset(struct, params \\ %{}) do
   struct
   |> cast(params, [
      :mobile,
      :email
    ])
    |> unique_constraint(:email, message: "Email is already being used by another user!")
    |> unique_constraint(:mobile, message: "Mobile Number is already being used by another user!")
    |> validate_format(:email,  ~r/^[A-Za-z0-9._,-]+@[A-Za-z0-9._,-]+\.[A-Za-z]{2,4}$/, message: "The email you have entered is invalid")
    |> validate_format(:mobile, ~r/^0[0-9]{10}$/, message: "The Mobile number you have entered is invalid")
   end

   def changeset_update_email_only(struct, params \\ %{}) do
     struct
     |> cast(params, [
       :email,
     ])
     |> unique_constraint(:email, message: "Email is already being used by another user!")
     |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
     |> validate_length(:email, max: 50)
     |> validate_required([
      :email,
    ])

   end

end
