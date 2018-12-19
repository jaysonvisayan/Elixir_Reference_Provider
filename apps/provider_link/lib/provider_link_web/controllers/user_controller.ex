defmodule ProviderLinkWeb.UserController do
  use ProviderLinkWeb, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2]
  alias Data.Contexts.{
    UserContext,
    AgentContext
  }
  alias Data.Schemas.User
  alias Ecto.Changeset
  alias Data.Utilities.SMS
  alias ProviderLink.{
    EmailSmtp,
    Mailer
  }

  def new(conn, %{"id" => agent_id}) do
    agent =
      agent_id
      |> AgentContext.get_agent_by_id

    changeset =
      %User{}
      |> User.create_changeset

    # usernames = UserContext.get_all_username()

    cond do
      is_nil(agent) ->
        conn
        |> put_flash(:error, "Activation ID does not exist.")
        |> redirect(to: "/")

      is_nil(agent.user) ->
        conn
        |> render(
          "new.html",
          changeset: changeset,
          agent: agent
          # usernames: Poison.encode!(usernames)
        )

      agent.status == "activated" ->
        conn
        |> put_flash(:error, "Account already activated")
        |> redirect(to: "/")

      agent.status != "activated" ->
        user =
          agent.user
          |> Map.put(:password, "dummypassword")
          |> Map.put(:password_confirmation, "dummypassword")

        conn
        |> render(
          "new.html",
          changeset: changeset,
          agent: agent,
          # usernames: Poison.encode!(usernames),
          show_verification: true,
          user: user
        )
    end
  end

  def validate_username(conn, %{"username" => username}) do
    case UserContext.validate_username_taken(username) do
      nil ->
        json conn, Poison.encode!(true)
      _ ->
        json conn, Poison.encode!(false)
    end
  end

  def send_activation_code(conn, %{"id" => agent_id, "user" => params}) do
    agent =
      agent_id
      |> AgentContext.get_agent_by_id

    # usernames = UserContext.get_all_username

    if is_nil(agent.user) do
      with {:ok, user} <- UserContext.create_user(params),
           {:ok, agent} <- AgentContext.update_agent_user(agent, %{user_id: user.id}),
           {:ok, user} <- UserContext.update_user_pin(user, 5)
      do
        user =
          user.id
          |> UserContext.get_user_by_id

        agent =
          agent_id
          |> AgentContext.get_agent_by_id

        # transform number to 639
        agent_mobile =
          user.agent.mobile
          |> SMS.transforms_number

        # send code to mobile
        %{
          text: "Your verification code is #{user.pin}",
          to: agent_mobile
        }
        |> SMS.send

        # send code to email
        user
        |> EmailSmtp.send_new_code()
        |> Mailer.deliver_now()

        changeset =
          %User{}
          |> User.create_changeset

        conn
        |> render(
          "new.html",
          changeset: changeset,
          agent: agent,
          # usernames: Poison.encode!(usernames),
          show_verification: true,
          user: %{username: params["username"],
            password: params["password"],
            password_confirmation: params["password_confirmation"]
          }
        )
      else
      {:error, %Changeset{} = changeset} ->
      conn
      |> render(
        "new.html",
        changeset: changeset,
        agent: agent
        # usernames: Poison.encode!(usernames)
      )
      end
    else

      changeset =
        %User{}
        |> User.create_changeset

      conn
      |> render(
        "new.html",
        changeset: changeset,
        agent: agent,
        # usernames: Poison.encode!(usernames),
        show_verification: true,
        user: %{
          username: params["username"],
          password: params["password"],
          password_confirmation: params["password_confirmation"]
        }
      )
    end
  end

  def create(conn, %{"id" => agent_id, "user" => params}) do
    agent = AgentContext.get_agent_by_id(agent_id)

    with {:pin_not_expired, user} <- UserContext.pin_expired?(agent.user_id),
         {:valid, user} <- UserContext.validate_pin(user,
                                                    params["security_code"]),
         {:ok, agent} <- AgentContext.update_status(agent, "activated"),
         {:ok, user} <- UserContext.update_pin_validated(
           user, %{pin: "validated", status: "active"})
    do
      conn = Auth.login(conn, user)
      user = conn.private[:guardian_default_resource]
      json conn, "valid"
    else
      {:invalid} ->
        json conn, "invalid"
      {:pin_expired} ->
        json conn, "pin_expired"
    end
  end

  def send_new_code(conn, %{"id" => agent_id}) do
    agent =
      agent_id
      |> AgentContext.get_agent_by_id

    with {:ok, user} <- UserContext.update_user_pin(agent.user, 5)
    do

      user =
        user.id
        |> UserContext.get_user_by_id

      # transform number to 639
      agent_mobile =
        user.agent.mobile
        |> SMS.transforms_number

      # send code to mobile
      %{
        text: "Your verification code is #{user.pin}",
        to: agent_mobile
      }
      |> SMS.send

      # send code to email
      user
      |> EmailSmtp.send_new_code()
      |> Mailer.deliver_now()

      return_params = %{
        duration: ProviderLinkWeb.UserView.check_expiry(user.pin_expires_at),
        sent_code: ProviderLinkWeb.UserView.check_sent_code(user.pin_expires_at),
        status: "valid"
      }

      conn
      |> json(Poison.encode!(return_params))
    end
  end

  def reset_password(conn, %{"id" => id}) do
    changeset = User.password_changeset(%User{})
    user = UserContext.get_user_by_id(id)
    if is_nil(user) do
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: "/")
    else
      conn
      |> render("reset_password.html", changeset: changeset, user: user)
    end
  end

  def update_password(conn, %{"id" => id, "user" => params}) do
    user =
      id
      |> UserContext.get_user_by_id

    params =
      params
      |> Map.put("attempt", 0)
      |> Map.put("status", "active")

    params =
      if user.first_time do
        params
        |> Map.put("first_time", false)
      else
        params
      end

    changeset =
      %User{}
      |> User.password_changeset(params)

    common_password = UserContext.get_all_common_password()

    password_history =
      user.id
      |> UserContext.get_all_user_password()
      |> Enum.uniq()
      |> List.delete(nil)

    with true <- not Enum.member?(common_password, params["password"]),
         {:not_in_history} <- Auth.check_user_history(password_history, params["password"]),
         {:ok} <- UserContext.insert_password_history(user, params),
         {:ok, user} <- UserContext.update_user_password(id, params),
         {:ok, user} <- UserContext.update_pin_validated(user, %{pin: "validated"})
    do
      user =
        user
        |> Map.put(:password, params["password"])
        |> Map.put(:password_confirmation, params["password_confirmation"])

      conn
      |> render(
        "reset_password.html",
        changeset: changeset,
        user: user,
        show_success_modal: true
      )
    else
      nil ->
        conn
        |> put_flash(:error, "Invalid user")
        |> render("reset_password.html", changeset: changeset, user: user)
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Errors encountered while updating the password")
        |> render("reset_password.html", changeset: changeset, user: user)
      {:in_history} ->
        conn
        |> put_flash(:error, "You have already used this password. Enter a new one")
        |> render(
          "reset_password.html",
          changeset: changeset,
          user: user
        )
      true ->
        conn
        |> put_flash(:error, "You have used that password before, enter new one")
        |> render("reset_password.html", changeset: changeset, user: user)
      false ->
        conn
        |> put_flash(:error, "Password is included in the common password list. Enter a new one.")
        |> render(
          "reset_password.html",
          changeset: changeset,
          user: user
        )
      _ ->
        conn
        |> put_flash(:error, "Errors encountered while updating the password")
        |> render(
          "reset_password.html",
          changeset: changeset,
          user: user
        )
    end
  end

  def change_password(conn, %{"id" => id}) do
    changeset =
      %User{}
      |> User.password_changeset()
    user =
      id
      |> UserContext.get_user_by_id()
    render(
      conn,
           "change_password.html",
           changeset: changeset,
           user: user
          )
  end

  def submit_change_password(conn, %{"id" => id, "user" => params}) do
    user =
      id
      |> UserContext.get_user_by_id

    params =
      params
      |> Map.put("attempt", 0)
      |> Map.put("status", "active")

    changeset =
      %User{}
      |> User.password_changeset()

    common_password = UserContext.get_all_common_password()
    password_history = UserContext.get_all_user_password(user.id)

    with {:password_correct} <- Auth.verify_password(user, params["current_password"]),
         true <- not Enum.member?(common_password, params["password"]),
         {:not_in_history} <- Auth.check_user_history(password_history, params["password"]),
         {:ok, user} <- UserContext.update_password(user, params),
         {:ok} <- UserContext.insert_password_history(user, params)
    do
      conn
      |> put_flash(:info, "Password change successful")
      |> render(
        "change_password.html",
        changeset: changeset,
        user: user
      )
    else
      false ->
        conn
        |> put_flash(:error, "Password is included in the common password list, enter new one.")
        |> render(
          "change_password.html",
          changeset: changeset,
          user: user
        )
      {:error_user, message} ->
        conn
        |> put_flash(:error, message)
        |> render(
          "change_password.html",
          changeset: changeset,
          user: user
        )
      {:error, changeset} ->
        conn
        |> render(
          "change_password.html",
          changeset: changeset,
          user: user
        )
      {:in_history} ->
        conn
        |> put_flash(:error, "You have used that password before, enter new one")
        |> render(
          "change_password.html",
          changeset: changeset,
          user: user
        )
      _ ->
        conn
        |> put_flash(:error, "Errors encountered while updating the password")
        |> render(
          "change_password.html",
          changeset: changeset,
          user: user
        )
    end
  end

  def insert_user_password(user, password) do
    user_passwords =
      user
      |> UserContext.get_all_passwords_by_user()

    up = Enum.map(user_passwords, fn(x) ->
      if not is_nil(x.password) do
        checkpw(password, x.password)
      end
    end)
    |> Enum.member?(true)

    if up do
      true
    else
      UserContext.create_user_password(%{user_id: user.id, password: user.hashed_password})
      false
    end
  end

end
