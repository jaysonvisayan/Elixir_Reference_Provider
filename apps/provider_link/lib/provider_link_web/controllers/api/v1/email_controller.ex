defmodule ProviderLinkWeb.Api.V1.EmailController do
  use ProviderLinkWeb, :controller

  alias Data.Contexts.{
    AcuScheduleContext,
    AgentContext,
    PayorContext,
    UtilityContext
  }

  alias ProviderLink.{
    EmailSmtp,
    Mailer
  }

  def send_acu_email(conn, %{"acu_schedule_id" => as_id, "agent_id" => a_id, "inserted_at" => date, "payor_id" => p_id}) do
    send_email(
      a_id |> AgentContext.get_agent_by_id(),
      as_id |> AcuScheduleContext.get_acu_schedule(),
      date,
      p_id |> PayorContext.get_payor()
    )

    json(conn, %{valid: true})
  end

  defp send_email(agent, acu_schedule, date, payor) do
    agent
    |> EmailSmtp.send_acu_email(acu_schedule, date, payor)
    |> Mailer.deliver_now()
  end

end
