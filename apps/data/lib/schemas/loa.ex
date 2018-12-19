defmodule Data.Schemas.Loa do
  @moduledoc """
  """
  use Data.Schema
  use Arc.Ecto.Schema

  schema "loas" do
    field :consultation_date, Ecto.DateTime
    field :coverage, :string # consult, lab
    field :status, :string # draft, pending, approved, disapproved, cancelled
    field :loa_number, :string
    field :otp, :boolean  # alias as verified column
    field :member_pays, :decimal
    field :payor_pays, :decimal
    field :total_amount, :decimal
    field :verification_type, :string
    field :issue_date, Ecto.DateTime
    field :admission_date, Ecto.DateTime
    field :discharge_date, Ecto.DateTime
    field :request_date, Ecto.DateTime
    field :acu_type, :string
    field :valid_until, Ecto.Date
    field :pin, :string
    field :pin_expires_at, Ecto.DateTime
    field :payorlink_authorization_id, :binary_id
    field :origin, :string
    field :photo, ProviderLinkWeb.ImageUploader.Type
    field :photo_type, :string
    field :payorlinkone_loe_no, :string #paylink and payorlink1.0 loe no
    field :payorlinkone_claim_no, :string #paylink and payorlink1.0 claim no
    field :payorlinkone_batch_no, :string #paylink and payorlink1.0 batch no
    field :is_peme, :boolean, default: false
    field :chief_complaint, :string
    field :chief_complaint_others, :string
    field :consultation_type, :string
    field :transaction_id, :string
    field :control_number, :string
    field :is_cart, :boolean, default: false
    field :is_batch, :boolean, default: false
    field :member_first_name, :string
    field :member_middle_name, :string
    field :member_last_name, :string
    field :member_gender, :string
    field :member_suffix, :string
    field :member_birth_date, Ecto.Date
    field :member_age, :integer
    field :member_card_no, :string
    field :payorlink_member_id, :string
    field :member_evoucher_number, :string
    field :member_evoucher_qr_code, :string
    field :member_male?, :boolean
    field :member_female?, :boolean
    field :member_status, :string
    field :member_email, :string
    field :member_mobile, :string
    field :member_type, :string
    field :member_account_code, :string
    field :member_account_name, :string
    field :member_attempts, :string
    field :member_attempt_expiry, Ecto.DateTime
    field :availment_date, Ecto.Date
    field :member_expiry_date, Ecto.Date
    field :member_goverment_issued_id, ProviderLink.FileUploader.Type
    field :facial_image, ProviderLink.FileUploader.Type

    belongs_to :member, Data.Schemas.Member
    belongs_to :card, Data.Schemas.Card
    belongs_to :provider, Data.Schemas.Provider
    belongs_to :created_by, Data.Schemas.User, foreign_key: :created_by_id
    belongs_to :updated_by, Data.Schemas.User, foreign_key: :updated_by_id
    belongs_to :payor, Data.Schemas.Payor

    has_many :loa_procedures, Data.Schemas.LoaProcedure, on_delete: :delete_all
    has_many :loa_packages, Data.Schemas.LoaPackage, on_delete: :delete_all
    has_many :loa_diagnosis, Data.Schemas.LoaDiagnosis, on_delete: :delete_all
    has_many :loa_doctor, Data.Schemas.LoaDoctor,  on_delete: :delete_all
    has_many :files, Data.Schemas.File,  on_delete: :delete_all
    has_many :batch_loas, Data.Schemas.BatchLoa
    timestamps()
  end

  def peme_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :consultation_date,
      :coverage,
      :status,
      :loa_number,
      :otp,
      :member_pays,
      :payor_pays,
      :total_amount,
      :verification_type,
      :issue_date,
      :admission_date,
      :discharge_date,
      :request_date,
      :acu_type,
      :valid_until,
      :pin,
      :pin_expires_at,
      :payorlink_authorization_id,
      :origin,
      :photo,
      :photo_type,
      :payorlinkone_loe_no,
      :payorlinkone_claim_no,
      :is_peme,
      :chief_complaint,
      :chief_complaint_others,
      :consultation_type,
      :transaction_id,
      :control_number,
      :is_cart,
      :is_batch,
      :member_first_name,
      :member_middle_name,
      :member_last_name,
      :member_gender,
      :member_suffix,
      :member_birth_date,
      :member_age,
      :member_card_no,
      :payorlink_member_id,
      :member_evoucher_number,
      :member_evoucher_qr_code,
      :member_male?,
      :member_female?,
      :member_status,
      :member_email,
      :member_mobile,
      :member_type,
      :member_account_code,
      :member_account_name,
      :created_by_id,
      :updated_by_id,
      :payor_id,
      :availment_date,
      :provider_id
    ])
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :member_first_name,
      :member_middle_name,
      :member_last_name,
      :member_gender,
      :member_suffix,
      :member_birth_date,
      :member_age,
      :member_card_no,
      :payorlink_member_id,
      :member_evoucher_number,
      :member_evoucher_qr_code,
      :member_male?,
      :member_female?,
      :member_status,
      :member_email,
      :member_mobile,
      :member_type,
      :member_account_code,
      :member_account_name,
      :consultation_date,
      :coverage,
      :status,
      # :card_id,
      :loa_number,
      :provider_id,
      :created_by_id,
      :updated_by_id,
      :verification_type,
      :issue_date,
      :valid_until,
      :is_peme,
      :control_number,
      :transaction_id
    ])
    |> validate_required([
      :member_card_no,
      :member_birth_date,
      :consultation_date,
      :coverage,
      :status,
      # :card_id,
      :provider_id,
      :created_by_id,
      :verification_type
    ])
  end

  def changeset_card(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :card_id,
      :coverage,
      :status,
      :provider_id
    ])
    |> validate_required([
      :card_id,
      :coverage,
      :status,
      :provider_id
    ])
  end

  def changeset_status(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :status,
      :loa_number
    ])
    |> validate_required([
      :status
    ])
  end

  def api_create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :member_first_name,
      :member_middle_name,
      :member_last_name,
      :member_gender,
      :member_suffix,
      :member_birth_date,
      :member_age,
      :member_card_no,
      :payorlink_member_id,
      :member_evoucher_number,
      :member_evoucher_qr_code,
      :member_male?,
      :member_female?,
      :member_status,
      :member_email,
      :member_mobile,
      :member_type,
      :member_account_code,
      :member_account_name,
      :consultation_date,
      :coverage,
      :status,
      :loa_number,
      :member_pays,
      :payor_pays,
      :total_amount,
      :created_by_id,
      :card_id,
      :provider_id,
      :issue_date,
      :valid_until,
      :payorlink_authorization_id,
      :origin,
      :request_date,
      :transaction_id,
      :control_number
    ])
    |> validate_required([
      :consultation_date,
      :coverage,
      :status,
      :member_pays,
      :payor_pays,
      :total_amount,
      :created_by_id,
      :issue_date,
      :valid_until,
      :payorlink_authorization_id,
      :origin,
      :request_date
    ])
  end

  def changeset_pin(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :pin,
      :pin_expires_at
    ])
    |> validate_required([
      :pin,
      :pin_expires_at
    ])
  end

  def changeset_otp(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :otp,
      :status
    ])
    |> validate_required([
      :otp,
      :status
    ])
  end

  def acu_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :consultation_date,
      :coverage,
      :status,
      :loa_number,
      :otp,
      :member_pays,
      :payor_pays,
      :total_amount,
      :verification_type,
      :issue_date,
      :admission_date,
      :discharge_date,
      :request_date,
      :acu_type,
      :valid_until,
      :pin,
      :pin_expires_at,
      :payorlink_authorization_id,
      :origin,
      :photo_type,
      :payorlinkone_loe_no,
      :payorlinkone_claim_no,
      :is_peme,
      :chief_complaint,
      :chief_complaint_others,
      :consultation_type,
      :transaction_id,
      :control_number,
      :is_cart,
      :is_batch,
      :member_first_name,
      :member_middle_name,
      :member_last_name,
      :member_gender,
      :member_suffix,
      :member_birth_date,
      :member_age,
      :member_card_no,
      :payorlink_member_id,
      :member_evoucher_number,
      :member_evoucher_qr_code,
      :member_male?,
      :member_female?,
      :member_status,
      :member_email,
      :member_mobile,
      :member_type,
      :member_account_code,
      :member_account_name,
      :created_by_id,
      :updated_by_id,
      :payor_id,
      :availment_date,
      :provider_id
    ])
      # |> validate_required([
      #     :status,
      #     :loa_number,
      #     :card_id,
      #     :issue_date,
      #     :discharge_date
      #    ])
  end

  def opconsult_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
        :payorlink_authorization_id,
        :coverage,
        :status,
        :loa_number,
        :payor_pays,
        :member_pays,
        :total_amount,
        :created_by_id,
        :updated_by_id,
        :card_id,
        :provider_id,
        :admission_date,
        :discharge_date,
        :request_date,
        :issue_date,
        :consultation_date,
        :origin,
        :verification_type,
        :valid_until,
        :payorlinkone_loe_no,
        :payorlinkone_claim_no,
        :photo_type,
        :chief_complaint,
        :chief_complaint_others,
        :consultation_type,
        :transaction_id,
        :control_number
      ])
  end

  def copy_loa_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :card_id,
      :coverage,
      :status,
      :inserted_at,
      :updated_at,
      :loa_number,
      :provider_id,
      :consultation_date,
      :member_pays,
      :payor_pays,
      :total_amount,
      :created_by_id,
      :updated_by_id,
      :verification_type,
      :issue_date,
      :valid_until,
      :admission_date,
      :discharge_date,
      :request_date,
      :acu_type,
      :payorlink_authorization_id,
      :origin,
      :otp,
      :pin,
      :pin_expires_at,
      :photo,
      :photo_type,
      :payorlinkone_loe_no,
      :payorlinkone_claim_no,
      :member_id,
      :is_peme,
      :consultation_type,
      :chief_complaint,
      :chief_complaint_others,
      :transaction_id,
      :control_number
    ])
  end

  def changeset_discharge_date(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :discharge_date
    ])
    |> validate_required([
      :discharge_date
    ])
  end

  def changeset_photo(struct, params \\ %{}) do
    struct
    |> cast_attachments(params, [:photo])
  end

  def changeset_cart(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :is_cart
    ])
    |> validate_required([
      :is_cart
    ])
  end

  def changeset_batch(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :is_batch
    ])
    |> validate_required([
      :is_batch
    ])
  end

  def changeset_goverment_id(struct, params \\ %{}) do
    struct
    |> cast_attachments(params, [:member_goverment_issued_id])
  end

  def changeset_facial_image(struct, params \\ %{}) do
    struct
    |> cast_attachments(params, [:facial_image])
  end
end
