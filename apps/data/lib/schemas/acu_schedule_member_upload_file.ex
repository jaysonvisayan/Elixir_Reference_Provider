defmodule Data.Schemas.AcuScheduleMemberUploadFile do
  @moduledoc false

  use Data.Schema

  schema "acu_schedule_member_upload_files" do
    field :filename, :string
    field :remarks, :string

    belongs_to :acu_schedule, Data.Schemas.AcuSchedule
    belongs_to :created_by, Data.Schemas.User, foreign_key: :created_by_id
    has_many :acu_schedule_member_upload_logs, Data.Schemas.AcuScheduleMemberUploadLog, on_delete: :delete_all

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :acu_schedule_id,
      :filename,
      :remarks,
      :created_by_id
    ])
    |> validate_required([
      :acu_schedule_id,
      :filename,
      :remarks,
      :created_by_id
    ])
  end

end
