defmodule Data.Repo.Migrations.CreateClaims do
  use Ecto.Migration

  def change do
    create table(:claims, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :consultation_type, :string
      add :chief_complaint, :string
      add :chief_complaint_others, :string
      add :internal_remarks, :string
      add :assessed_amount, :decimal
      add :total_amount, :decimal
      add :status, :string
      add :version, :integer
      add :step, :integer
      add :admission_datetime, :utc_datetime
      add :discharge_datetime, :utc_datetime
      add :availment_type, :string
      add :number, :string
      add :reason, :string
      add :valid_until, :date
      add :otp, :string
      add :otp_expiry, :date
      add :origin, :string
      add :control_number, :string
      add :approved_datetime, :utc_datetime
      add :requested_datetime, :utc_datetime
      add :transaction_no, :string
      add :is_peme?, :boolean
      add :swipe_datetime, :utc_datetime
      add :loe_number, :string
      add :availment_date, :date
      add :is_claimed?, :boolean, default: false
      add :diagnosis, {:array, :jsonb}
      add :physician, {:array, :jsonb}
      add :procedure, {:array, :jsonb}
      add :package, {:array, :jsonb}
      add :loa_id, references(:loas, type: :binary_id)
      add :batch_no, :string
      add :migrated, :string
      add :payorlink_claim_id, :string

      #for inpatient

      add :nature_of_admission, :string
      add :point_of_admission, :string
      add :senior_discount, :decimal
      add :pwd_discount, :decimal
      add :date_issued, :date
      add :place_issued, :string
      add :or_and_dr_fee, :decimal # Operating and delivery room fee
      add :created_by_id, references(:users, type: :binary_id)
      add :updated_by_id, references(:users, type: :binary_id)

      timestamps()
    end
  end
end
