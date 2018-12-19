defmodule Data.Contexts.AgentContext do
  @moduledoc """

  """

  import Ecto.{Query, Changeset}, warn: false

  alias Data.Repo
  alias Data.Schemas.Agent
  alias Data.Schemas.User

  def create_agent(params) do
    %Agent{}
    |> Agent.create_changeset(params)
    |> Repo.insert()
  end

  def update_agent(agent, params) do
    agent
    |> Agent.create_changeset(params)
    |> Repo.update()
  end

  def update_agent_user(agent, params) do
    agent
    |> Agent.assoc_user_changeset(params)
    |> Repo.update()
  end

  def get_agent_by_id(id) do
    Agent
    |> Repo.get(id)
    |> Repo.preload([
      :provider,
      :user
    ])
  end

  def get_agent_by_user_id(user_id) do
    Agent
    |> Repo.get_by(user_id: user_id)
    |> Repo.preload([
      :provider,
      :user
    ])
  end

  def update_status(agent, status) do
    agent
    |> Agent.status_changeset(%{status: status})
    |> Repo.update()
  end

  def get_all_agent_mobile_number do
    Agent
    |> select([a], a.mobile)
    |> Repo.all()
  end

  def get_all_agent_email do
    Agent
    |> select([a], a.email)
    |> Repo.all()
  end

  def validate_forgot_password(params) do
    changeset = Agent.changeset_forgot_password(%Agent{}, params)
    if changeset.valid? do
      field_validate(changeset)
    else
      {:error, changeset}
    end
  end

  def get_user_by_email(username, user_email) do
    user = User
           |> join(:left, [u], a in Agent, a.user_id == u.id)
           |> where([u, a], u.username == ^username and a.email == ^user_email)
           |> select([u,a],
              %{
                username: u.username,
                first_name: a.first_name,
                last_name: a.last_name,
                verification_code: a.verification_code,
                id: a.id
               }
           )
           |> Repo.one()

    if is_nil(user) do
      {:user_not_found}
    else
      {:ok, user}
    end
  end

  def get_agent_username(username) do
    user =
      User
      |> Repo.get_by(username: username)
      |> Repo.preload(:agent)
    if is_nil(user) do
      {:not_found}
    else
      cond do
        is_nil(user.agent) ->
          {:invalid_user_agent}
        is_nil(user.status) || user.status != "active" ->
          {:inactive_user}
        user.status == "active" ->
          validate_request(user)
        true ->
          {:inactive_user}
      end
    end
  end

  def validate_request(agent) do
    if is_nil(agent) do
      {:not_verified}
    else
      {:ok, agent}
    end
  end

  def delete_verification_code(user) do
    user.agent
    |> Agent.verification_code_changeset(%{verification_code: nil})
    |> Repo.update!()
  end

  def update_verification_code_agent(%Agent{} = agent, attrs) do
    agent
    |> Agent.changeset_agent(attrs)
    |> Repo.update()
  end

  def generate_verification_code do
    code = Enum.random(1000..9999)
    code
    |> Integer.to_string()
  end

  def get_user_by_mobile(username, user_mobile) do
    user = User
           |> join(:left, [u], a in Agent, a.user_id == u.id)
           |> where([u, a], u.username == ^username and a.mobile == ^user_mobile)
           |> select([u,a],
              %{
                username: u.username,
                first_name: a.first_name,
                last_name: a.last_name,
                verification_code: a.verification_code,
                id: a.id
               }
           )
           |> Repo.one()

    if is_nil(user) do
      {:user_not_found}
    else
      {:ok, user}
    end
  end

  def update_user_expiry(%Agent{} = agent) do
    agent
    |> Agent.expiry_changeset(%{"verification_expiry" => Ecto.DateTime.from_erl(:erlang.localtime)})
    |> Repo.update()
  end

  def field_validate(changeset) do
    recovery = changeset.changes.recovery
    cond do
      recovery == "email" ->
        email_validate = validate_format(changeset, :text, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
        if email_validate.valid? do
          {:ok, email_validate}
        else
          changeset = email_validate
          {:error, changeset}
        end
      recovery == "mobile" ->
        email_validate = Agent.validate_mobile(changeset, :text)
        if email_validate.valid? do
          {:ok, email_validate}
        else
          changeset = email_validate
          {:error, changeset}
        end
      true ->
        {:recovery_not_found}
    end
  end

  def validate_request(agent) do
    if is_nil(agent.provider_id) do
      {:not_verified}
    else
      {:ok, agent}
    end
  end

  def check_pin_expiry_forgot(agent) do
    if is_nil(agent.verification_expiry) do
      false
    else
      expiry = agent.verification_expiry
      date = Ecto.DateTime.from_erl(:erlang.localtime)
      date_seconds = (date.hour * 60 * 60) + (date.min * 60) + date.sec
      expiry_seconds = (expiry.hour * 60 * 60) + (expiry.min * 60) + expiry.sec
      difference = date_seconds - expiry_seconds
      difference = abs(difference)
      if expiry.year == date.year && expiry.month == date.month && expiry.day == date.day && difference <= 300   do
        true
      else
        false
      end
    end
  end

  def validate_user_verification_code(id, pin) do
    if is_binary(pin) do
      pin = String.to_integer(pin)
    else
      pin
    end
    Agent
    |> where([u], u.id == ^id and u.verification_code == ^Integer.to_string(pin))
    |> Repo.one
  end

  def update_verification(%Agent{} = agent, attrs) do
    agent
    |> Agent.verification_changeset(attrs)
    |> Repo.update()
  end


end
