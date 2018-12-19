defmodule Data.Schemas.JobStatus do
  @moduledoc false

  use Data.Schema

  schema "job_statuses" do
    field :is_success, :boolean # true if success
    field :params, :map
    field :return, {:array, :string}

    belongs_to :job, Data.Schemas.Job

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :is_success,
      :params,
      :return,
      :job_id
    ])
    |> validate_required([
      :is_success,
      :params,
      :return,
      :job_id
    ])
  end
end
