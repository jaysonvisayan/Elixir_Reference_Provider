defmodule Data.Schemas.AcuSchedule do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "acu_schedules" do
    field :batch_no, :integer
    field :account_code, :string
    field :account_name, :string
    field :account_address, :string
    field :date_to, Ecto.Date
    field :date_from, Ecto.Date
    field :time_from, Ecto.Time
    field :time_to, Ecto.Time
    field :no_of_members, :integer
    field :no_of_guaranteed, :integer
    field :no_of_selected_members, :integer
    field :payorlink_acu_schedule_id, :binary_id
    field :created_by, :string
    field :status, :string

    field :guaranteed_amount, :decimal
    field :estimate_total_amount, :decimal
    field :actual_total_amount, :decimal
    field :soa_reference_no, :string
    field :registered, :string
    field :unregistered, :string

    field :acu_email_sent, :boolean, default: true

    field :hidden_from_mobile, :boolean, default: false

    belongs_to :provider, Data.Schemas.Provider
    belongs_to :batch, Data.Schemas.Batch

    has_many :files, Data.Schemas.File
    has_many :acu_schedule_members, Data.Schemas.AcuScheduleMember
    has_many :acu_schedule_member_upload_files, Data.Schemas.AcuScheduleMemberUploadFile, on_delete: :delete_all

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :batch_no,
      :batch_id,
      :account_code,
      :account_name,
      :account_address,
      :date_to,
      :date_from,
      :time_to,
      :time_from,
      :no_of_members,
      :no_of_selected_members,
      :no_of_guaranteed,
      :created_by,
      :payorlink_acu_schedule_id,
      :provider_id,
      :actual_total_amount,
      :estimate_total_amount,
      :guaranteed_amount,
      :soa_reference_no,
      :batch_id,
      :acu_email_sent
    ])
    |> validate_required([
      :batch_no,
      :account_code,
      :account_name,
      :date_to,
      :date_from,
      :time_to,
      :time_from,
      :no_of_members,
      :created_by,
      :payorlink_acu_schedule_id
      ])
  end

  def changeset_soa_no(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :soa_reference_no
    ])
    |> validate_required([
      :soa_reference_no
    ])
    |> unique_constraint([
      :soa_reference_no
    ])
  end

  def changeset_status(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :status
    ])
    |> validate_required([
      :status
    ])
  end

  def changeset_amount(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :actual_total_amount,
      :estimate_total_amount,
      :registered,
      :unregistered,
      :status,
      :batch_id
    ])
  end

end
