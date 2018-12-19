defmodule ProviderWorker.Job.BatchRequestNotificationJob do
  @moduledoc """
    This module sends an email notification to show the progress of the request
  """

  alias Data.Contexts.JobContext
  alias ProviderWorker.{
    EmailSmtp,
    Mailer
  }

  def perform(job_id) do
    job =
      job_id
      |> JobContext.get_job_by_id()

    job_params_cnt =
      job.params["params"]
      |> Enum.count()

    job_status_done =
      job.job_statuses
      |> Enum.count()

    job_status_success =
      job.job_statuses
      |> Enum.filter(fn(job_status) ->
        job_status.is_success == true
      end)
      |> Enum.count()

    job_status_failed =
      job.job_statuses
      |> Enum.filter(fn(job_status) ->
        job_status.is_success == false
      end)
      |> Enum.count()

    job_stats = %{
      api_name: job.api_name,
      id: job.id,
      count: job_params_cnt,
      not_processed: job_params_cnt - job_status_done,
      processed: job_status_done,
      success: job_status_success,
      failed: job_status_failed
    }

    if job_params_cnt == job_status_done
    do

      job
      |> EmailSmtp.job_batch_request_result_notification(job_stats)
      |> Mailer.deliver_now()

      job
      |> JobContext.update_job(%{is_done: true})
    else

      job_stats
      |> EmailSmtp.job_batch_request_status_notification()
      |> Mailer.deliver_now()

      Exq.Enqueuer
      |> Exq.Enqueuer.enqueue_in(
        "batch_notification_job_prov", 1800,
        "ProviderWorker.Job.BatchRequestNotificationJob",
        [job_id],
        max_retries: 10
      )

    end
  end
end
