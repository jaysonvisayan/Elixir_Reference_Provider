defmodule Data.Schemas.File do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "files" do
    field :name, :string
    field :type, ProviderLink.FileUploader.Type

    belongs_to :loa, Data.Schemas.Loa
    belongs_to :batch, Data.Schemas.Batch
    belongs_to :acu_schedule, Data.Schemas.AcuSchedule
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
  end

  def changeset_loa(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :loa_id])
  end

  def changeset_batch(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :batch_id])
  end

  def changeset_acu_schedule(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :acu_schedule_id])
  end

  def changeset_file(struct, params \\ %{}) do
    struct
    |> cast_attachments(params, [:type])
  end

  def changeset_facial_image(struct, params \\ %{}) do
    struct
    |> cast_attachments(params, [:facial_image])
  end

end
