defmodule Data.Schemas.Provider do
  @moduledoc """
  """

  use Data.Schema

  schema "providers" do
    field :payorlink_facility_id, :binary_id
    field :name, :string
    field :code, :string
    field :phone_no, :string
    field :email_address, :string
    field :line_1, :string
    field :line_2, :string
    field :city, :string
    field :province, :string
    field :region, :string
    field :country, :string
    field :postal_code, :string
    field :type, :string
    field :prescription_term, :integer

    has_many :agents, Data.Schemas.Agent

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :name,
      :code,
      :payorlink_facility_id,
      :phone_no,
      :email_address,
      :line_1,
      :line_2,
      :city,
      :province,
      :region,
      :country,
      :postal_code,
      :prescription_term,
      :type
    ])
    |> validate_required([
      :name,
      :code,
      :payorlink_facility_id,
    ])
  end
end
