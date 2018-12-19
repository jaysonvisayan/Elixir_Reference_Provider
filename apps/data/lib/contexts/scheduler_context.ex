defmodule Data.Contexts.SchedulerContext do
  import Ecto.{Query, Changeset}, warn: false

  alias Data.Repo
  alias Data.Schemas.SchedulerLog

  def insert_logs(params) do
    %SchedulerLog{}
    |> SchedulerLog.changeset(params)
    |> Repo.insert()
  end

end
