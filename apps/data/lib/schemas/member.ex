# do not use member schema
defmodule Data.Schemas.Member do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "members" do
    field :payorlink_member_id, :string
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :extension, :string
    field :birth_date, Ecto.Date
    field :gender, :string
    field :pin, :string
    field :pin_expires_at, Ecto.DateTime
    field :mobile, :string
    field :number_of_dependents, :string
    field :principal, :string
    field :relationship, :string
    field :email_address, :string
    field :email_address2, :string
    field :mobile2, :string
    field :type, :string
    field :account_code, :string
    field :account_name, :string
    field :attempt_expiry, Ecto.DateTime
    field :evoucher_number, :string
    field :evoucher_qr_code, :string
    field :remarks, :string
    field :effective_date, Ecto.Date
    field :expiry_date, Ecto.Date
    field :civil_status, :string
    field :male?, :boolean
    field :female?, :boolean
    field :age_from, :integer
    field :age_to, :integer
    field :status, :string
    field :attempts, :integer, default: 0
    field :last_facility, :string
    field :latest_consult, :string

    belongs_to :payor, Data.Schemas.Payor
    has_one :card, Data.Schemas.Card
    has_many :loa, Data.Schemas.Loa
    has_one :acu_schedule_members, Data.Schemas.AcuScheduleMember

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :payorlink_member_id,
      :first_name,
      :middle_name,
      :last_name,
      :extension,
      :birth_date,
      :gender,
      :pin,
      :pin_expires_at,
      :mobile,
      :number_of_dependents,
      :principal,
      :relationship,
      :email_address,
      :email_address2,
      :mobile2,
      :type,
      :payor_id,
      :account_code,
      :account_name,
      :attempt_expiry,
      :evoucher_number,
      :evoucher_qr_code,
      :effective_date,
      :expiry_date,
      :status,
      :attempts,
      :last_facility
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :birth_date,
      :gender,
      :payorlink_member_id
    ])
  end

  def changeset_mobile(struct, params \\ %{}) do
    struct
    |> cast(params, [:mobile])
    |> validate_required([:mobile])
  end

  def changeset_remarks(struct, params \\ %{}) do
    struct
    |> cast(params, [:remarks])
    |> validate_required([:remarks])
  end

  def changeset_accountlink(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :first_name,
      :middle_name,
      :last_name,
      :extension,
      :birth_date,
      :civil_status,
      :gender,
      :male?,
      :female?,
      :age_from,
      :age_to,
      :evoucher_number,
      :payorlink_member_id,
      :status,
      :payor_id,
      :email_address,
      :mobile,
      :type,
      :account_code,
      :account_name,
      :effective_date,
      :expiry_date
      ])
    |> validate_required([
      :first_name,
      :last_name,
      :birth_date,
      :civil_status,
      :male?,
      :female?,
      :age_from,
      :age_to,
      :evoucher_number,
      :payorlink_member_id
      ])
  end

  def changeset_attempt_expiry(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :attempt_expiry
    ])
  end

end
# do not use member schema
