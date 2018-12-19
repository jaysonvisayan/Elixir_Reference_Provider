defmodule Data.Schemas.AcuScheduleMember do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "acu_schedule_members" do
    field :is_registered, :boolean
    field :is_availed, :boolean
    field :is_recognized, :boolean
    field :status, :string
    field :loa_status, :string
    field :image, ProviderLinkWeb.ImageUploader.Type
    field :file_name, :string
    field :submit_log, :string
    belongs_to :acu_schedule, Data.Schemas.AcuSchedule
    belongs_to :member, Data.Schemas.Member
    belongs_to :acu_schedule_package, Data.Schemas.AcuSchedulePackage
    belongs_to :loa, Data.Schemas.Loa
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :is_availed,
      :is_registered,
      # :member_id,
      :acu_schedule_id,
      :acu_schedule_package_id,
      :status,
      :loa_status,
      :loa_id,
      :file_name
    ])
  end

  def changeset_image(struct, params \\ %{}) do
    struct
    |> cast_attachments(params, [:image])
  end
end
