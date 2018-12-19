defmodule Data.Schemas.Job do
  @moduledoc false

  use Data.Schema

  schema "jobs" do
    field :is_done, :boolean # true if job is complete
    field :name, :string # job name
    field :api_name, :string #api name
    field :params, :map	 # job params

    belongs_to :user, Data.Schemas.User
    has_many :job_statuses, Data.Schemas.JobStatus, on_delete: :delete_all

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :is_done,
      :name,
      :api_name,
      :params,
      :user_id
    ])
    |> validate_required([
      :is_done,
      :name,
      :api_name,
      :params,
      :user_id
    ])
  end
end
