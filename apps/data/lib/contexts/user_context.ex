defmodule Data.Contexts.UserContext do
  @moduledoc """
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Ecto.Changeset
  alias Data.Repo
  alias Data.Schemas.{
    User,
    Agent,
    Job,
    CommonPassword,
    UserPassword,
    UserRole,
    Role,
    Provider
  }
  alias Data.Contexts.{
    AgentContext,
    ProviderContext,
    JobContext,
    UtilityContext,
    RoleContext
  }

  alias Comeonin.Bcrypt

  def get_user_by_username(username) do
    User
    |> Repo.get_by(username: username)
    |> Repo.preload([
      agent: [:provider],
      roles: [
        role_applications: :application,
        role_permissions: :permission
      ]
    ])
  end

  def get_user_by_email(email) do
    agent =
      Agent
      |> Repo.get_by(email: email)
    if is_nil(agent) do
      nil
    else
      User
      |> Repo.get(agent.user_id)
      |> Repo.preload([:agent])
    end
  end

  def get_user_by_mobile(mobile) do
    agent = get_agent_by_mobile(mobile)

    if is_nil(agent) do
      nil
    else
      User
      |> Repo.get(agent.user_id)
      |> Repo.preload([:agent])
    end
  end

  defp get_agent_by_mobile(mobile) do
    agent =
      Agent
      |> Repo.get_by(mobile: mobile)

    rescue
      Elixir.Ecto.MultipleResultsError ->
        nil
      _ ->
        nil
  end

  def get_verified_user_by_username(username) do
    User
    |> where([u], u.pin == "validated")
    |> Repo.get_by(username: username)
    |> Repo.preload([agent: [:provider]])
  end

  def get_user_by_id(id) do
    User
    |> Repo.get(id)
    |> Repo.preload([agent: [:provider]])
  end

  def create_user_api(params) do
    %User{}
    |> User.create_api_changeset(params)
    |> Repo.insert()
  end

  def create_user(params) do
    %User{}
    |> User.create_changeset(params)
    |> Repo.insert()
  end

  def update_user(%User{} = user, params) do
    user
    |> User.create_changeset(params)
    |> Repo.update()
  end

  def get_all_username do
    User
    |> select([u], u.username)
    |> Repo.all()
  end

  def update_user_pin(user, pin_expiration) do
    random_pin = Integer.to_string(Enum.random(100000..999999))
    utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds
    pin_expiry = (utc + pin_expiration * 60)

    pin_expiry =
      pin_expiry
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

    user
    |> User.pin_changeset(%{pin: random_pin, pin_expires_at: pin_expiry})
    |> Repo.update()
  end

  def validate_pin(user, pin) do
    if user.pin == pin do
      {:valid, user}
    else
      {:invalid}
    end
  end

  def update_pin_validated(user, params) do
    user
    |> User.pin_changeset(params)
    |> Repo.update()
  end

  def pin_expired?(user_id) do
    user = get_user_by_id(user_id)

    if user.pin_expires_at >= Ecto.DateTime.utc do
      {:pin_not_expired, user}
    else
      {:pin_expired}
    end
  end

  # def update_login_attempt(user, params) do
  #   user
  #   |> User.login_attempt_changeset(params)
  #   |> Repo.update()
  # end

  # def validate_login_attempt(user) do
  #   if user.attempt < 2 do
  #     user
  #     |> update_login_attempt(%{
  #       attempt: user.attempt + 1,
  #       status: "active"
  #     })
  #   else
  #     user
  #     |> update_login_attempt(%{
  #       attempt: user.attempt + 1,
  #       status: "locked"})
  #   end
  # end

  # def validate_user_email(params) do
  #   params["username"]
  #   |> get_user_by_username()
  #   |> registered_user_email?(params["email"])
  # end

  def validate_user_email(params) do
    user = get_user_by_email(params)
    if is_nil(user) do
      {:invalid}
    else
      {:ok, user} = update_user_pin(user, 5)
      {:valid, user}
    end
  end

  def validate_user_mobile(params) do
    user = get_user_by_mobile(params)
    if is_nil(user) do
      {:invalid}
    else
      {:ok, user} = update_user_pin(user, 5)
      {:valid, user}
    end
  end

  # def registered_user_email?(user, email) do
  #   cond do
  #     user == nil ->
  #       {:invalid_username}
  #     user.agent.email == email ->
  #       {:ok, user} = update_user_pin(user, 15)
  #       {:valid, user}
  #     user.agent.email != email ->
  #       {:invalid_email}
  #   end
  # end

  # def validate_user_mobile(params) do
  #   params["username"]
  #   |> get_user_by_username()
  #   |> registered_user_mobile?(params["mobile"] |> String.replace("-", ""))
  # end

  # def registered_user_mobile?(user, mobile) do
  #   cond do
  #     user == nil ->
  #       {:invalid_username}
  #     user.agent.mobile == mobile ->
  #       {:ok, user} = update_user_pin(user, 15)
  #       {:valid, user}
  #     user.agent.mobile != mobile ->
  #       {:invalid_mobile}
  #   end
  # end

  def validate_channel(params) do
    if is_nil(params["mobile"]) do
      validate_user_email(params["email"])
    else
      validate_user_mobile(params["mobile"])
    end
  end

  def update_user_password(id, params) do
    id
    |> get_user_by_id()
    |> update_password(params)
  end

  def get_common_passwords(password) do
    CommonPassword
    |> Repo.get_by(password: password)
  end

  def update_common_password(commonPass, params) do
    commonPass
    |> update_common_pass(params)
  end

  def create_common_password(params) do
    %CommonPassword{}
    |> CommonPassword.password_changeset(params)
    |> Repo.insert()
  end

  def update_common_pass(commonpass, params) do
    commonpass
    |> CommonPassword.password_changeset(params)
    |> Repo.update()
  end

  def update_password(user, params) do
    user
    |> User.change_password_changeset(params)
    |> Repo.update()
  end

  def get_user_by_paylink_user_id(paylink_user_id) do
    User
    |> Repo.get_by(paylink_user_id: paylink_user_id)
    |> Repo.preload([agent: :provider])
  end

  def create_batch_user(params) do
    with {:ok} <- has_key_params?(params),
         {:ok} <- empty_params?(params["params"])
    do
      params["params"]
      |> Enum.into([], fn col ->
        with {:ok, changeset} <- col |> user_migration_changeset,
             {:ok, %User{} = user} <-
               col
               |> Map.put("password_confirmation", col["password"])
               |> Map.put("pin", "validated")
               |> Map.put("is_admin", false)
               |> Map.put("status", "active")
               |> create_user,
             {:ok, %Agent{} = agent} <-
               col
               |> Map.put("provider_id", changeset.changes.provider_id)
               |> Map.put("user_id", user.id)
               |> Map.put("status", "activated")
               |> AgentContext.create_agent
        do
          user
          |> Repo.preload([agent: :provider])
          |> translate_created_user
          |> Map.put(:is_success, true)
        else
          {:error, changeset} ->
            changeset
            |> translate_errors
            |> Map.put(:is_success, false)
        end
      end)
    else
    # has_key_params? return
    {:error, :params_not_exists} ->
      {:error, :params_not_exists, "params does not exists"}
      # empty_params? return
      {:error, :params_is_empty} ->
        {:error, :params_is_empty, "params list is empty"}
    end
  end

  def translate_created_user(user) do
    %{
      "first_name": user.agent.first_name,
      "middle_name": user.agent.middle_name,
      "last_name": user.agent.last_name,
      "extension": user.agent.extension,
      "department": user.agent.department,
      "role": user.agent.role,
      "mobile": user.agent.mobile,
      "email": user.agent.email,
      "provider_code": user.agent.provider.code,
      "username": user.username,
      "paylink_user_id": user.paylink_user_id,
      "status": user.status
    }
  end

  defp has_key_params?(params) do
    if params |> Map.has_key?("params")
    do
      {:ok}
    else
      {:error, :params_not_exists}
    end
  end

  defp empty_params?(params) do
    if params |> Enum.empty?
    do
      {:error, :params_is_empty}
    else
      {:ok}
    end
  end

  defp username_unique?(changeset)  do
    with username when not is_nil(username) <- changeset |> get_field(:username),
         %User{} = user <- username |> get_user_by_username
    do
      changeset
      |> add_error(
        :username,
        "Username is already taken",
        additional: "info"
      )
    else
      nil ->
        changeset
    end
  end

  defp provider_code_exists?(changeset) do
    with provider_code when not is_nil(provider_code) <- changeset |> get_field(:provider_code),
         nil <- provider_code |> ProviderContext.get_provider_by_code
    do
      changeset
      |> add_error(
        :provider_code,
        "Provider code does not exists",
        additional: "info"
      )
    else
      nil ->
        changeset
      provider ->
        new_changes =
          changeset.changes
          |> Map.put(:provider_id, provider.id)

          changeset
          |> Map.put(:changes, new_changes)
    end
  end

  def user_migration_changeset(params) do
    types = %{
      first_name: :string,
      middle_name: :string,
      last_name: :string,
      extension: :string,
      department: :string,
      role: :string,
      mobile: :string,
      email: :string,
      provider_code: :string,
      username: :string,
      password: :string,
      paylink_user_id: :string,
      provider_id: :binary_id
    }

    changeset =
      {%{}, types}
      |> cast(
        params,
        Map.keys(types)
      )
      |> validate_required(
        [
          :first_name,
          :last_name,
          :department,
          :role,
          :mobile,
          :email,
          :provider_code,
          :username,
          :password,
          :paylink_user_id
        ],
        message: "This is a required field."
      )
      |> validate_format(
        :first_name,
        ~r/^[ña-zÑA-Z\s.-]*$/,
        message: "The first name you have entered is invalid"
      )
      |> validate_format(
        :middle_name,
        ~r/^[ña-zÑA-Z\s.-]*$/,
        message: "The middle name you have entered is invalid"
      )
      |> validate_format(
        :last_name,
        ~r/^[ña-zÑA-Z\s.-]*$/,
        message: "The last name you have entered is invalid"
      )
      |> validate_format(
        :extension,
        ~r/^[ña-zÑA-Z\s.]*$/,
        message: "The extension you have entered is invalid"
      )
      |> validate_format(
        :email,
        ~r/^[A-Za-z0-9._,-]+@[A-Za-z0-9._,-]+\.[A-Za-z]{2,4}$/,
        message: "The email you have entered is invalid"
      )
      |> validate_format(
        :mobile,
        ~r/^0[0-9]{10}$/,
        message: "The Mobile number you have entered is invalid"
      )
      |> validate_length(
        :username,
        min: 8,
        message: "Please enter at least 8 characters"
      )
      |> validate_length(
        :username,
        max: 20,
        message: "Please enter at most 20 characters"
      )
      # |> validate_format(
      #   :password,
      #   ~r/(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}/,
      #   message: "Password must be at least 8 characters and should contain alpha-numeric, special-character, atleast 1 capital letter"
      # )
      |> username_unique?
      |> provider_code_exists?

      if changeset.valid? do
        {:ok, changeset}
      else
        {:error, changeset}
      end
  end

  def translate_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def job_create_batch_user(params, user_id, api_name) do
    with {:ok} <- has_key_params?(params),
         {:ok} <- empty_params?(params["params"]),
         {:ok, %Job{} = job} <- JobContext.create_job(%{
           is_done: false,
           name: "Data.Worker.Job.UserMigrationJob",
           api_name: api_name,
           params: params,
           user_id: user_id
         })
    do
      Exq.Enqueuer.start_link

      Exq.Enqueuer
      |> Exq.Enqueuer.enqueue(
        "user_migration_job_prov",
        "ProviderWorker.Job.UserMigrationJob",
        [job.id]
      )

      {:ok, :queued, job.id}
    else
    # has_key_params? return
      {:error, :params_not_exists} ->
        {:error, :params_not_exists, "params does not exists"}
        # empty_params? return
      {:error, :params_is_empty} ->
        {:error, :params_is_empty, "params list is empty"}

        # create job return
      {:error, changeset} ->
        {:error, :insert_job_error, "Error encountered in inserting job"}
    end
  end

  def get_username_with_password(username) do
    User
    |> where([u], u.username == ^username
             and is_nil(u.hashed_password) == false)
  end

  def validate_username_taken(username) do
    User
    |> Repo.get_by(username: username)
  end

  def reset_password_providerlink(user, params) do
    if Bcrypt.checkpw(params["password"], user.hashed_password) do
      {:old_password}
    else
      user =
        user
        |> User.password_changeset(params)
        |> update_password(%{"password" => params["password"], "password_confirmation" => params["password_confirmation"]})
    end
  end

  def attempts_reset(user, params) do
    user
    |> User.attempts_reset(params)
    |> Repo.update()
  end

  def update_user_status_active(%User{} = user) do
    user
    |> User.status_changeset(%{status: "active"})
    |> Repo.update()
  end

  def validate_verification(params) do
    validate_pnumber_or_email(params)
  end

  def validate_pnumber_or_email(params) do
    %Agent{}
    |> Agent.pnumber_or_email_changeset()
    |> is_true?()
  end

  defp is_true?(changeset), do: if changeset.valid?, do: {:ok, changeset}, else: {:changeset_error, changeset}

  def is_pnum_or_email?(params) do
    cond do
      Regex.match?(~r/^[A-Za-z0-9._,-]+@[A-Za-z0-9._,-]+\.[A-Za-z]{2,4}$/, params["pnumber_or_email"]) == true ->
        params =
          params
          |> Map.put("email", params["pnumber_or_email"])
        {:ok, params}
      Regex.match?(~r/^0[0-9]{10}$/, params["pnumber_or_email"]) == true ->
        params =
          params
          |> Map.put("mobile", params["pnumber_or_email"])
        {:ok, params}
      true ->
        {:error}
    end
  end

  def create_user_password(params) do
    %UserPassword{}
    |> UserPassword.changeset(params)
    |> Repo.insert()
  end

  def get_all_passwords_by_user(user) do
    UserPassword
    |> where([up], up.user_id == ^user.id)
    |> limit(32)
    |> Repo.all()
  end

  def validate_common_password(password) do
    CommonPassword
    |> Repo.get_by(password: password)
  end

  def get_all_common_password do
    CommonPassword
    |> select([cp], cp.password)
    |> Repo.all()
  end

  def get_all_user_password(id) do
    UserPassword
    |> where([up], up.user_id == ^id)
    |> select([cp], cp.hashed_password)
    |> limit(32)
    |> Repo.all()
  end

  def insert_password_history(user, params) do
    {result, _} =
      %UserPassword{}
      |> UserPassword.password_changeset(%{
        user_id: user.id,
        password: params["password"]
      })
      |> Repo.insert()

    {result}
  end

  def change_user_password(id, params) do
    user =
      id
      |> get_user_by_id()

    params =
      params

    %User{}
    |> User.change_password_changeset(params)
    |> Repo.update()
  end

  def validate_current_password(current, user) do
    if user == current.hashed_password do
      {:valid, user}
    else
      {:invalid}
    end
  end

  def get_verified_user_by_email(email) do
    User
    |> join(:inner, [u], a in Agent, a.user_id == u.id)
    |> where([u, a], u.pin == "validated")
    |> where([u, a], a.email == ^email)
    |> Repo.one()
    |> Repo.preload([agent: [:provider]])
  end

  def get_verified_user_by_mobile(mobile) do
    User
    |> join(:inner, [u], a in Agent, a.user_id == u.id)
    |> where([u, a], u.pin == "validated")
    |> where([u, a], a.mobile == ^mobile)
    |> Repo.one()
    |> Repo.preload([agent: [:provider]])
  end

  def validate_user(params) do
    general_types = %{
      username: :string,
      hashed_password: :string,
      status: :string,
      action: :string,
      role_id: :string,
      acu_schedule_notification: :boolean,
      first_name: :string,
      middle_name: :string,
      last_name: :string,
      extension: :string,
      mobile: :string,
      email: :string,
      status: :string,
      payorlink_facility_id: :string,
      name: :string,
      code: :string,
      phone_no: :string,
      email_address: :string,
      line_1: :string,
      line_2: :string,
      city: :string,
      province: :string,
      region: :string,
      country: :string,
      postal_code: :string,
      prescription_term: :integer,
      pin: :string
    }

    changeset =
      {%{}, general_types}
      |> cast(params, Map.keys(general_types))
      |> validate_required([
        :username,
        :hashed_password,
        :status,
        :action,
        :role_id,
        :first_name,
        :last_name,
        :mobile,
        :email,
        :status,
        :payorlink_facility_id,
        :name,
        :code
        # :line_1,
        # :line_2,
        # :city,
        # :province,
        # :region,
        # :country,
        # :postal_code,
        # :prescription_term
      ])

    validate_user_level1(
      changeset,
      changeset.valid?
    )
  end

  defp validate_user_level1(changeset, result) when result == false, do: {:error, changeset}
  defp validate_user_level1(changeset, result) when result == true do
    changeset =
      changeset
      |> validate_length(:username, min: 8, max: 50)
      |> validate_inclusion(:action, ["insert", "update"])
      |> validate_inclusion(:status, ["Active", "Deactivated"])
      |> validate_user_level2(changeset.valid?)
  end

  defp validate_user_level2(changeset, result) when result == false, do: {:error, changeset}
  defp validate_user_level2(changeset, result) when result == true,
    do:
      changeset
      |> user_action(changeset.changes[:action])
      |> validate_user_role(changeset)

  defp validate_user_role(%User{} = user, changeset) do
    with {true, id} <- UtilityContext.valid_uuid?(changeset.changes[:role_id]) do
      role =
        Role
        |> where([r], r.payorlink_role_id == ^id)
        |> Repo.one()

      user_role =
        UserRole
        |> where([ur], ur.user_id == ^user.id and ur.role_id == ^role.id)
        |> Repo.all()

      with true <- Enum.empty?(user_role) do
        UserRole
        |> where([ur], ur.user_id == ^user.id)
        |> Repo.delete_all()

        %UserRole{}
        |> UserRole.changeset(
          %{
            user_id: user.id,
            role_id: role.id
          }
        )
        |> Repo.insert!()
      end

      provider_checker =
        Provider
        |> where([p], p.payorlink_facility_id == ^changeset.changes[:payorlink_facility_id])
        |> Repo.all()

      provider =
        if Enum.empty?(provider_checker) do
          %Provider{}
          |> Provider.create_changeset(changeset.changes)
          |> Repo.insert!()
        else
          provider_checker
          |> List.first()
        end

      params =
        changeset.changes
        |> Map.put_new(:user_id, user.id)
        |> Map.put_new(:role, role.name)
        |> Map.put(:provider_id, provider.id)

      if changeset.changes[:action] == "insert" do
        %Agent{}
        |> Agent.create_changeset_api(params)
        |> Repo.insert!()
      else
        Agent
        |> where([a], a.user_id == ^user.id)
        |> Repo.one()
        |> Agent.create_changeset_api(params)
        |> Repo.update!()
      end

      {:ok, user}
    else
      {:invalid_id} ->
        changeset =
          add_error(
            changeset,
            :role_id,
            "Role ID is invalid."
          )

        {:error, changeset}
    end
  end

  defp validate_user_role(user, changeset), do: user

  defp validate_role(role, changeset) do
    role = RoleContext.get_role_application_by_role_id(role_id)
    if is_nil(role) do
      changeset =
        add_error(
          changeset,
          :role,
          "Role is invalid."
        )
        {:error, changeset}
    else
      role
    end
  end

  defp user_action(changeset, action) when action == "insert" do
    params = changeset.changes
    user_count =
      User
      |> where([u], u.username == ^params[:username])
      |> select([u], count(u.id))
      |> Repo.one()

    with true <- user_count < 1 do
      %User{}
      |> User.create_api_changeset2(params)
      |> Repo.insert!()
    else
      _ ->
        changeset =
          add_error(
            changeset,
            :username,
            "Username has been taken."
          )

        {:error, changeset}
    end
  end

  defp user_action(changeset, action) when action == "update" do
    params = changeset.changes

    User
    |> where([u], u.username == ^params[:username])
    |> Repo.one()
    |> User.create_api_changeset2(params)
    |> Repo.update!()
  rescue
    _ ->
      changeset =
        add_error(
          changeset,
          :username,
          "Username not found."
        )

      {:error, changeset}
  end

  def get_user_by_id_notif(id) do
    User
    |> Repo.get(id)
    |> Repo.preload([
      :agent,
      roles: [
        role_applications: :application,
        role_permissions: :permission
      ]
    ])
  end


  # Validate username & password

  def validate_user_update_params(params) do
    data = %{}
    general_types = %{
      username: :string,
      password: :string,
      email: :string,
      status: :string
    }
    changeset =
      {data, general_types}
      |> Changeset.cast(params, Map.keys(general_types))
      |> Changeset.validate_required([
        :username,
        :password
      ])

    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

  def validate_username(changeset) do
    with user = %User{} <- get_user_by_username(changeset.changes.username) do
      {:ok, user}
    else
      _ ->
        nil
    end
  end

  def update_user_information(user, changeset) do
    if Map.has_key?(changeset.changes, :email) do
      put_update_user(user, changeset)
      update_agent_email(user, changeset)
    else
      put_update_user(user, changeset)
    end
  end

  def put_update_user(user, changeset) do
    if Map.has_key?(changeset.changes, :status) do
      user
      |> User.update_user_changeset(%{
        password: changeset.changes.password,
        status: changeset.changes.status,
      })
      |> Repo.update()
    else
      user
      |> User.update_user_changeset(%{
        password: changeset.changes.password
      })
      |> Repo.update()
    end
  end

  def update_agent_email(user, changeset) do
    Agent
    |> Repo.get_by(user_id: user.id)
    |> Agent.changeset_update_email_only(%{email: changeset.changes.email})
    |> Repo.update()
  end

  # Validate User Params

  def validate_user_params(params) do
    with true <- Map.has_key?(params, "username"),
         {:ok, username} <- validate_username_params(params["username"])
    do
      {:ok, username}
    else
      false ->
        {:username_required}
      nil ->
        {:no_value_params}
      _ ->
        {:invalid_params}
    end
  end

  defp validate_username_params(username) do
    if is_nil(username) or username == "" do
      nil
    else
      {:ok, username}
    end
  end

  # For User Role Seed
  def get_first_role(user) do
    user = user
           |> Repo.preload(:roles)

    case user.roles do
      [] -> nil
      roles ->
        {:ok, role} = Enum.fetch(user.roles, 0)
        role
    end
  end

  def insert_or_update_user_role(params) do
    user_role = get_ur_by_user_role(params)
    if is_nil(user_role) do
      create_user_roles(params)
    else
      clear_user_roles(params.user_id)
      create_user_roles(params)
    end
  end

  def get_ur_by_user_role(params) do
    UserRole
    |> Repo.get_by(user_id: params.user_id, role_id: params.role_id)
    |> Repo.preload([:user, :role])
  end

  def create_user_roles(params) do
    changeset = UserRole.changeset(%UserRole{}, params)
    Repo.insert(changeset)
  end

  def clear_user_roles(user_id) do
    UserRole
    |> where([ur], ur.user_id == ^user_id)
    |> Repo.delete_all()
  end
end

