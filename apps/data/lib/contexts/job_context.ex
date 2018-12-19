defmodule Data.Contexts.JobContext do
  @moduledoc false

  import Ecto.Query

  alias Data.Repo
  alias Data.Schemas.{
    Job,
    JobStatus
  }

  def create_job(params) do
    %Job{}
    |> Job.changeset(params)
    |> Repo.insert
  end

  def get_job_by_id(job_id) do
    Job
    |> Repo.get(job_id)
    |> Repo.preload([
      :user,
      :job_statuses
    ])
  end

  def update_job(%Job{} = job, params) do
    job
    |> Job.changeset(params)
    |> Repo.update()
  end

  def create_job_status(params) do
    %JobStatus{}
    |> JobStatus.changeset(params)
    |> Repo.insert
  end

  def get_job_statuses_by_id(job_status_id) do
    %JobStatus{}
    |> Repo.get(job_status_id)
  end
end
