defmodule Data.Schemas.Application do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "applications" do
    field :name, :string
    field :payorlink_application_id, :binary_id

    # belongs_to :payor, Data.Schemas.Payor
    # has_many :doctor_specializations, Data.Schemas.DoctorSpecialization, on_delete: :delete_all

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :name,
      :payorlink_application_id
    ])
  end

end
