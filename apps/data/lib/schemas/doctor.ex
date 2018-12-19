defmodule Data.Schemas.Doctor do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "doctors" do
    field :first_name, :string
    field :middle_name, :string
    field :last_name, :string
    field :extension, :string
    field :prc_number, :string
    field :specialization, :string
    field :status, :string
    field :affiliated, :boolean, default: false
    field :code, :string
    field :payorlink_practitioner_id, :binary_id

    belongs_to :payor, Data.Schemas.Payor
    has_many :doctor_specializations, Data.Schemas.DoctorSpecialization, on_delete: :delete_all

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :first_name,
      :middle_name,
      :last_name,
      :extension,
      :prc_number,
      :specialization,
      :status,
      :affiliated,
      :code,
      :payorlink_practitioner_id
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :prc_number,
      :status,
      :affiliated,
      :code,
      :payorlink_practitioner_id
    ])
  end

end
