defmodule Data.Schemas.LoaPackage do
  @moduledoc """
  """

  use Data.Schema

  schema "loa_packages" do
    field :payorlink_benefit_package_id, :binary_id, primary_key: true
    field :code, :string
    field :description, :string
    field :details, :string
    field :benefit_code, :string
    field :amount, :decimal
    field :benefit_provider_access, :string
    field :loa_benefit_acu_type, :string
    field :loa_limit_amount, :decimal

    belongs_to :loa, Data.Schemas.Loa
    has_many :loa_procedures, Data.Schemas.LoaProcedure, on_delete: :delete_all
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :payorlink_benefit_package_id,
      :loa_id,
      :code,
      :description,
      :details,
      :amount,
      :benefit_code,
      :benefit_provider_access,
      :loa_limit_amount,
      :loa_benefit_acu_type
    ])
  end
end
