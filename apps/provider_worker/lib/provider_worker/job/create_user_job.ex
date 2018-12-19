defmodule ProviderWorker.Job.CreateUserJob do
  @moduledoc """
    This module creates user
  """

  alias Data.Schemas.{
    User,
    Agent
  }
  alias Data.Contexts.{
    AgentContext,
    UserContext,
    JobContext
  }

  def perform(params, job_id) do
    with {:ok, changeset} <- params |> UserContext.user_migration_changeset,
         {:ok, %User{} = user} <-
           params
           |> Map.put("password_confirmation", params["password"])
           |> Map.put("pin", "validated")
           |> Map.put("is_admin", false)
           |> Map.put("status", "active")
           |> UserContext.create_user_api,
         {:ok, %Agent{} = agent} <-
           params
           |> Map.put("provider_id", changeset.changes.provider_id)
           |> Map.put("user_id", user.id)
           |> Map.put("status", "activated")
           |> AgentContext.create_agent
    do
      return =
        user.id
        |> UserContext.get_user_by_id
        |> UserContext.translate_created_user

      job_status_params = %{
        is_success: true,
        params: params,
        return: transform_success(return),
        job_id: job_id
      }

      job_status_params
      |> JobContext.create_job_status

    else
      {:error, changeset} ->

        return =
          changeset
          |> UserContext.translate_errors

        job_status_params = %{
          is_success: false,
          params: params,
          return: transform_errors(return),
          job_id: job_id
        }

        job_status_params
        |> JobContext.create_job_status
    end
  end

  defp transform_errors(details) do
    details
    |> Enum.into([], fn({x, y}) -> "#{x}: #{List.first(y)}" end)
  end

  defp transform_success(details) do
    details
    |> Enum.into([], fn({x, y}) -> "#{x}: #{y}" end)
  end
end
