defmodule Data.Schemas.Batch do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "batches" do
    field :number, :string
    field :soa_reference_no, :string
    field :soa_amount, :decimal
    field :edited_soa_amount, :decimal, default: 0
    field :status, :string
    field :type, :string

    belongs_to :doctor, Data.Schemas.Doctor
    belongs_to :created_by, Data.Schemas.User
    has_many :batch_loas, Data.Schemas.BatchLoa
    has_many :files, Data.Schemas.File

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
        :doctor_id,
        :created_by_id,
        :number,
        :soa_reference_no,
        :soa_amount,
        :edited_soa_amount,
        :status,
        :type
      ])
    |> validate_required([
        :created_by_id,
        :number,
        :soa_reference_no,
        :soa_amount,
        :edited_soa_amount,
        :status,
        :type
      ])
    |> validate_length(
      :soa_reference_no, max: 30
    )
  end
end
