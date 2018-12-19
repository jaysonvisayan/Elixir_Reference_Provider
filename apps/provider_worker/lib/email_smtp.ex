defmodule ProviderWorker.EmailSmtp do
  @moduledoc """
  """

  use Bamboo.Phoenix, view: ProviderWorkerWeb.EmailView
  import ProviderWorkerWeb.Router.Helpers
  alias ProviderWorkerWeb.Endpoint

  def base_email do
    new_email()
    |> from("noreply@innerpeace.dev")
    |> put_header("Reply-To", "noreply@innerpeace.dev")
    |> put_html_layout({ProviderWorkerWeb.LayoutView, "email.html"})
  end

  def job_batch_request_status_notification(job_stats) do
    base_email()
    |> to("janna_delacruz@medilink.com.ph")
    |> subject("Job Batch Request Status")
    |> render("job_batch_request_status_notification.html", job_stats: job_stats)
  end

  def job_batch_request_result_notification(job, job_stats) do
    base_email()
    |> to("janna_delacruz@medilink.com.ph")
    |> subject("Job Batch Request Result")
    |> render("job_batch_request_result_notification.html", job: job, job_stats: job_stats)
  end
end
