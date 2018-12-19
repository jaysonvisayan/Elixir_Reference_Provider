defmodule Data.Schemas.AcuScheduleMemberUploadLog do
  use Data.Schema

  schema "acu_schedule_member_upload_logs" do
    field :filename, :string
    field :card_no, :string
    field :full_name, :string
    field :gender, :string
    field :birthdate, :string
    field :age, :string
    field :package_code, :string
    field :signature, :string
    field :availed, :string
    field :remarks, :string

    belongs_to :created_by, Data.Schemas.User, foreign_key: :created_by_id
    belongs_to :acu_schedule_member_upload_file, Data.Schemas.AcuScheduleMemberUploadFile

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :filename,
      :card_no,
      :full_name,
      :gender,
      :birthdate,
      :age,
      :package_code,
      :signature,
      :availed,
      :remarks,
      :created_by_id,
      :acu_schedule_member_upload_file_id
    ])
  end

end
