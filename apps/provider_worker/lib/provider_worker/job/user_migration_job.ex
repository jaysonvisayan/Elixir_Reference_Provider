defmodule ProviderWorker.Job.UserMigrationJob do
  @moduledoc """
    This module migrates user
  """

  alias Data.Contexts.JobContext

  def perform(job_id) do
    job =
      job_id
      |> JobContext.get_job_by_id

    Exq.Enqueuer.start_link

    job.params["params"]
    |> Enum.map(&(
      Exq.Enqueuer
      |> Exq.Enqueuer.enqueue(
        "create_user_job_prov",
        "ProviderWorker.Job.CreateUserJob",
        [&1, job_id]
      )
    ))

    Exq.Enqueuer
    |> Exq.Enqueuer.enqueue_in(
      "batch_notification_job_prov", 1800,
      "ProviderWorker.Job.BatchRequestNotificationJob",
      [job_id],
      max_retries: 10
    )

  end
end
