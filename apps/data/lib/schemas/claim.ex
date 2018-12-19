defmodule Data.Schemas.Claim do
    @moduledoc false

    use Data.Schema

    schema "claims" do
      field :consultation_type, :string
      field :chief_complaint, :string
      field :chief_complaint_others, :string
      field :internal_remarks, :string
      field :assessed_amount, :decimal
      field :total_amount, :decimal
      field :status, :string
      field :version, :integer
      field :step, :integer
      field :admission_datetime, Ecto.DateTime
      field :discharge_datetime, Ecto.DateTime
      field :availment_type, :string
      field :number, :string
      field :reason, :string
      field :valid_until, Ecto.Date
      field :otp, :string
      field :otp_expiry, Ecto.DateTime
      field :origin, :string
      field :control_number, :string
      field :approved_datetime, Ecto.DateTime
      field :requested_datetime, Ecto.DateTime
      field :transaction_no, :string
      field :is_peme?, :boolean
      field :swipe_datetime, Ecto.DateTime
      field :batch_no, :string
      field :loe_number, :string
      field :availment_date, Ecto.Date
      field :is_claimed?, :boolean, default: false
      field :migrated, :string
      field :payorlink_claim_id, :string

      #for inpatient
      field :nature_of_admission, :string
      field :point_of_admission, :string
      field :senior_discount, :decimal
      field :pwd_discount, :decimal
      field :date_issued, Ecto.Date
      field :place_issued, :string
      field :or_and_dr_fee, :decimal # Operating and delivery room fee
      field :package, {:array, :map}
      field :diagnosis, {:array, :map}
      field :procedure, {:array, :map}

      #Relationships
      belongs_to :loa, Data.Schemas.Loa
      belongs_to :created_by, Data.Schemas.User, foreign_key: :created_by_id
      belongs_to :updated_by, Data.Schemas.User, foreign_key: :updated_by_id

      timestamps()
    end

    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [
        :consultation_type,
        :chief_complaint,
        :chief_complaint_others,
        :internal_remarks,
        :assessed_amount,
        :total_amount,
        :status,
        :version,
        :step,
        :admission_datetime,
        :discharge_datetime,
        :availment_type,
        :number,
        :reason,
        :valid_until,
        :otp,
        :otp_expiry,
        :origin,
        :control_number,
        :approved_datetime,
        :requested_datetime,
        :transaction_no,
        :is_peme?,
        :swipe_datetime,
        :batch_no,
        :loe_number,
        :availment_date,
        :is_claimed?,
        :migrated,
        :nature_of_admission,
        :point_of_admission,
        :senior_discount,
        :pwd_discount,
        :date_issued,
        :place_issued,
        :or_and_dr_fee,
        :loa_id,
        :payorlink_claim_id
      ])
    end

    def changeset_peme_claim(struct, params \\ %{}) do
      struct
      |> cast(params, [
        :consultation_type,
        :chief_complaint,
        :chief_complaint_others,
        :internal_remarks,
        :assessed_amount,
        :total_amount,
        :status,
        :version,
        :step,
        :admission_datetime,
        :discharge_datetime,
        :availment_type,
        :number,
        :reason,
        :valid_until,
        :otp,
        :otp_expiry,
        :origin,
        :control_number,
        :approved_datetime,
        :requested_datetime,
        :transaction_no,
        :is_peme?,
        :swipe_datetime,
        :batch_no,
        :loe_number,
        :availment_date,
        :is_claimed?,
        :migrated,
        :nature_of_admission,
        :point_of_admission,
        :senior_discount,
        :pwd_discount,
        :date_issued,
        :place_issued,
        :or_and_dr_fee,
        :loa_id,
        :payorlink_claim_id,
        :package,
        :diagnosis,
        :procedure
      ])
    end

    def changeset_migrated(struct, params \\ %{}) do
      struct
      |> cast(params, [
        :migrated
      ])
      |> validate_required([
        :migrated
      ])
    end
  end

