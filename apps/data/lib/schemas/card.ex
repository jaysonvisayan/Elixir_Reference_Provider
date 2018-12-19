defmodule Data.Schemas.Card do
  @moduledoc """
  """

  use Data.Schema
  use Arc.Ecto.Schema

  schema "cards" do
    field :number, :string
    field :payorlink_member_id, :string

    belongs_to :member, Data.Schemas.Member
    has_many :loa, Data.Schemas.Loa
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :payorlink_member_id,
      :member_id,
      :number
    ])
    |> validate_required([
      :number,
      :payorlink_member_id,
      :member_id
    ])
    |> unique_constraint(:number)
  end

end
