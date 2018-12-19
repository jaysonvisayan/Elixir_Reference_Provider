defmodule Data.Contexts.UserContextTest do
  use Data.SchemaCase

  alias Data.Contexts.UserContext
  alias Data.Schemas.User
  alias Ecto.UUID

  test "get_user_by_username with result" do
    user = insert(:user, username: "Janna")
    result = UserContext.get_user_by_username(user.username)
    assert result.username == user.username
  end

  test "get_user_by_username without result" do
    user = "Mamer"
    result = UserContext.get_user_by_username(user)
    assert is_nil(result)
  end

  test "get_user_by_id with result" do
    user = insert(:user)
    result = UserContext.get_user_by_id(user.id)
    assert result.id == user.id
  end

  test "get_user_by_id without result" do
    {_, id} = UUID.load(UUID.bingenerate())
    result = UserContext.get_user_by_id(id)
    assert is_nil(result)
  end

  test "create_user with valid params" do
    params = %{
      username: "Janna123",
      password: "P@ssw0rd",
      password_confirmation: "P@ssw0rd"
    }

    {status, result} = UserContext.create_user(params)
    assert result.username == "Janna123"
    assert status == :ok
  end

  test "create_user with invalid params" do
    params = %{
      username: "Janna",
      password: "password"
    }

    {status, result} = UserContext.create_user(params)
    assert status == :error
    refute result.valid?
  end

  test "update_user with valid params" do
    user = insert(:user, username: "Janna123", password: "P@ssw0rd", password_confirmation: "P@ssw0rd")
    params = %{
      username: "Mamer123"
    }

    {status, result} = UserContext.update_user(user, params)
    assert status == :ok
    assert result.username == "Mamer123"
  end

  test "update_user with invalid params" do
    user = insert(:user, username: "Janna", password: "P@ssw0rd")
    params = %{
      password: "pass"
    }

    {status, result} = UserContext.update_user(user, params)
    assert status == :error
    refute result.valid?

  end

  test "get_all_username with return" do
    insert(:user, username: "test")

    result = UserContext.get_all_username

    assert length(result) == 1
  end

  test "get_all_username without return" do
    result = UserContext.get_all_username

    assert length(result) == 0
  end

  test "update_user_pin with valid user" do
    user = insert(:user, username: "Janna")

    {status, result} = UserContext.update_user_pin(user, 5)

    assert status == :ok
    assert result.username == "Janna"
  end

  test "validate_pin with valid pin" do
    provider = insert(:provider)
    user = insert(:user, pin: "1233")
    agent = insert(:agent, user: user, provider: provider)
    user = user |> Repo.preload([agent: [:provider]])

    {status, result} = UserContext.validate_pin(user, "1233")

    assert result == user
    assert status == :valid
    assert agent.id == user.agent.id
  end

  test "validate_pin with invalid pin" do
    user = insert(:user, pin: "1233")

    result = UserContext.validate_pin(user, "1223")

    assert result == {:invalid}
  end

  test "update_pin_validated with valid params" do
    user = insert(:user)
    params = %{
      pin: "validated"
    }

    {status, result} = UserContext.update_pin_validated(user, params)
    assert result.pin == "validated"
    assert status == :ok
  end

  test "update_pin_validated with invalid params" do
    user = insert(:user)

    {status, result} = UserContext.update_pin_validated(user, %{})

    refute result.valid?
    assert status == :error
  end

  test "get_verified_user_by_username with valid username" do
    user = insert(:user, username: "Janna", pin: "validated")

    result = UserContext.get_verified_user_by_username("Janna")
    assert result.username == user.username
  end

  test "get_verified_user_by_username with invalid username" do
    insert(:user, username: "Janna", pin: "validated")

    result = UserContext.get_verified_user_by_username("Janna1")
    assert is_nil(result)
  end

  test "pin_expired? with expired pin" do
    utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds
    pin_expiry = (utc - 5 * 60)

    pin_expiry =
      pin_expiry
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

    user = insert(:user, pin: "1234", pin_expires_at: pin_expiry)
    insert(:agent, user: user)

    result = UserContext.pin_expired?(user.id)

    assert result == {:pin_expired}
  end

  test "pin_expired? with valid pin" do
    utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds
    pin_expiry = (utc + 15 * 60)

    pin_expiry =
      pin_expiry
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

    user = insert(:user, pin: "1234", pin_expires_at: pin_expiry, first_time: false)
    insert(:agent, user: user)
    user =
      user
      |> Repo.preload([agent: [:provider]])

    result = UserContext.pin_expired?(user.id)

    assert result == {:pin_not_expired, user}
  end

  # test "update_login_attempt with valid params" do
  #   user = insert(:user)
  #   params = %{
  #     status: "active",
  #     attempt: "1"
  #   }

  #   {status, result} = UserContext.update_login_attempt(user, params)

  #   assert status == :ok
  #   assert result.status == "active"
  # end

  # test "update_login_attempt with invalid params" do
  #   user = insert(:user)
  #   params = %{
  #     attempt: "1"
  #   }

  #   {status, result} = UserContext.update_login_attempt(user, params)

  #   assert status == :error
  #   refute result.valid?
  # end

  # test "validate_login_attempt with active user" do
  #   user = insert(:user)
  #   {status, result} = UserContext.validate_login_attempt(user)
  #   assert result.status == "active"
  #   assert status == :ok
  # end

  # test "validate_login_attempt with locked user" do
  #   user = insert(:user, attempt: 2)
  #   {status, result} = UserContext.validate_login_attempt(user)
  #   assert result.status == "locked"
  #   assert status == :ok
  # end

  test "validate_user_email with valid params" do
    user = insert(:user, username: "jannamamer")
    insert(:agent, email: "janna_delacruz@medilink.com.ph", user: user)

    # params = %{
    #   "username" => "jannamamer",
    #   "email" => "janna_delacruz@medilink.com.ph"
    # }

    {status, result} = UserContext.validate_user_email("janna_delacruz@medilink.com.ph")
    assert result.username == user.username
    assert status == :valid
    assert result.agent.email == "janna_delacruz@medilink.com.ph"
  end

  test "validate_user_email with invalid params" do
    user = insert(:user, username: "jannamamer")
    agent = insert(:agent, email: "janna_delacruz@medilink.com.ph", user: user)

    # params = %{
      # "username" => "jannamamer",
      # "email" => "janna_delacru@medilink.com.ph"
    # }

    result = UserContext.validate_user_email("janna_delacru@medilink.com.ph")
    assert result == {:invalid}
    refute agent.email == "janna_delacru@medilink.com.ph"
  end

  # test "registered_user_email? with valid params" do
  #   user = insert(:user, username: "jannamamer")
  #   agent = insert(:agent, email: "janna_delacruz@medilink.com.ph", user: user)

  #   user =
  #     user
  #     |> Repo.preload([:agent])

  #   email = "janna_delacruz@medilink.com.ph"

  #   {status, result} = UserContext.registered_user_email?(user, email)
  #   assert result.username == user.username
  #   assert status == :valid
  #   assert result.agent.email == agent.email
  # end

  # test "registered_user_email? with invalid params" do
  #   user = insert(:user, username: "jannamamer")
  #   agent = insert(:agent, email: "janna_delacruz@medilink.com.ph", user: user)

  #   user =
  #     user
  #     |> Repo.preload([:agent])

  #   email = "janna_delacruz@medilink.com"

  #   result = UserContext.registered_user_email?(user, email)
  #   assert result == {:invalid_email}
  #   refute agent.email == email
  # end

  test "validate_user_mobile with valid params" do
    user = insert(:user, username: "jannamamer")
    agent = insert(:agent, mobile: "09156826861", user: user)

    # params = %{
      # "username" => "jannamamer",
      # "mobile" => "09156826861"
    # }

    {status, result} = UserContext.validate_user_mobile("09156826861")
    assert result.username == user.username
    assert status == :valid
    assert result.agent.mobile == agent.mobile
  end

  test "validate_user_mobile with invalid params" do
    user = insert(:user, username: "jannamamer")
    agent = insert(:agent, mobile: "09156826861", user: user)

    # params = %{
    #   "username" => "jannamamer",
    #   "mobile" => "0156826861"
    # }

    result = UserContext.validate_user_mobile("0156826861")
    assert result == {:invalid}
    refute agent.mobile == "0156826861"
  end

  # test "registered_user_mobile? with valid params" do
  #   user = insert(:user, username: "jannamamer")
  #   agent = insert(:agent, mobile: "09156826861", user: user)

  #   user =
  #     user
  #     |> Repo.preload([:agent])

  #   mobile = "09156826861"

  #   {status, result} = UserContext.registered_user_mobile?(user, mobile)
  #   assert result.username == user.username
  #   assert status == :valid
  #   assert result.agent.mobile == agent.mobile
  # end

  # test "registered_user_mobile? with invalid params" do
  #   user = insert(:user, username: "jannamamer")
  #   agent = insert(:agent, mobile: "09156826861", user: user)

  #   user =
  #     user
  #     |> Repo.preload([:agent])

  #   mobile = "0916826861"

  #   result = UserContext.registered_user_mobile?(user, mobile)
  #   assert result == {:invalid_mobile}
  #   refute agent.mobile == mobile
  # end

  test "validate_channel with email" do
    user = insert(:user, username: "jannamamer")
    agent = insert(:agent, email: "janna_delacruz@medilink.com.ph", user: user)

    params = %{
      "username" => "jannamamer",
      "email" => "janna_delacruz@medilink.com.ph",
      "channel" => "Email"
    }

    {status, result} = UserContext.validate_channel(params)
    assert result.username == user.username
    assert status == :valid
    assert result.agent.email == agent.email
  end

  test "validate_channel with sms" do
    user = insert(:user, username: "jannamamer")
    agent = insert(:agent, mobile: "09156826861", user: user)

    params = %{
      "username" => "jannamamer",
      "mobile" => "09156826861",
      "channel" => "sms"
    }

    {status, result} = UserContext.validate_channel(params)
    assert result.username == user.username
    assert status == :valid
    assert result.agent.mobile == agent.mobile
  end

  test "update_user_password with valid params" do
    user = insert(:user)
    params = %{
      password: "P@ssw0rd1",
      password_confirmation: "P@ssw0rd1",
      attempt: 0,
      status: "active"
    }
    {status, result} = UserContext.update_user_password(user.id, params)

    assert status == :ok
    assert result.id == user.id
  end

  test "update_user_password with invalid params" do
    user = insert(:user)
    params = %{
      password_confirmation: "P@ssw0rd1"
    }
    {status, result} = UserContext.update_user_password(user.id, params)

    assert status == :error
    refute result.valid?
  end

  test "update_password with valid params" do
    user = insert(:user)
    params = %{
      password: "P@ssw0rd1",
      password_confirmation: "P@ssw0rd1",
      attempt: 0,
      status: "active"
    }
    {status, result} = UserContext.update_password(user, params)

    assert status == :ok
    assert result.id == user.id
  end

  test "update_password with invalid params" do
    user = insert(:user)
    params = %{
      password_confirmation: "P@ssw0rd1"
    }
    {status, result} = UserContext.update_password(user, params)

    assert status == :error
    refute result.valid?
  end

  test "get_user_by_paylink_user_id with valid paylink_user_id" do
    user =
      :user
      |> insert(
        paylink_user_id: "1"
      )

    result = UserContext.get_user_by_paylink_user_id("1")

    assert result.id == user.id
  end

  test "get_user_by_paylink_user_id with invalid paylink_user_id" do
    result = UserContext.get_user_by_paylink_user_id("1")

    assert is_nil(result)
  end

  test "create_batch_user with not existing params" do
    params = %{}

    {status, result, message} = UserContext.create_batch_user(params)

    assert status == :error
    assert result == :params_not_exists
    assert message == "params does not exists"
  end

  test "create_batch_user with empty params" do
    params = %{
      "params" => []
    }

    {status, result, message} = UserContext.create_batch_user(params)

    assert status == :error
    assert result == :params_is_empty
    assert message == "params list is empty"
  end

  # test "create_batch_user with invalid params" do
  #   params = %{
  #     "params" => [
  #       %{
  #         "username": "test",
  #         "password": "password",
  #         "provider_code": "880000000015491",
  #         "mobile": "9156826861",
  #         "last_name": "test1",
  #         "first_name": "test1",
  #         "middle_name": "testm1",
  #         "extension": "test1",
  #         "email": "test_emaiedilink.com.ph",
  #       }
  #     ]
  #   }

  #   result = UserContext.create_batch_user(params)

  #   assert List.first(result).username == ["Please enter at least 8 characters"]
  #   assert List.first(result).password == ["Password must be at least 8 characters and should contain alpha-numeric, special-character, atleast 1 capital letter"]
  #   assert List.first(result).provider_code == ["Provider code does not exists"]
  #   assert List.first(result).role == ["This is a required field."]
  #   assert List.first(result).mobile == ["The Mobile number you have entered is invalid"]
  #   assert List.first(result).last_name == ["The last name you have entered is invalid"]
  #   assert List.first(result).first_name == ["The first name you have entered is invalid"]
  #   assert List.first(result).middle_name == ["The middle name you have entered is invalid"]
  #   assert List.first(result).extension == ["The extension you have entered is invalid"]
  #   assert List.first(result).email == ["The email you have entered is invalid"]
  #   assert List.first(result).department == ["This is a required field."]
  #   assert List.first(result).is_success == false
  # end

  test "create_batch_user with valid params" do
    :provider
    |> insert(code: "880000000015491")

    params = %{
      "params" => [
        %{
          "username" => "test1236",
          "password" => "P@ssw0rd",
          "provider_code" => "880000000015491",
          "role" => "admin",
          "mobile" => "09156826861",
          "last_name" => "test",
          "first_name" => "testf",
          "middle_name" => "testm",
          "extension" => "teste",
          "email" => "test_email@medilink.com.ph",
          "department" => "test dep",
          "paylink_user_id" => "test_paylink"
        }
      ]
    }

    result = UserContext.create_batch_user(params)

    assert List.first(result).is_success == true
    assert List.first(result).username == "test1236"
    assert List.first(result).provider_code == "880000000015491"
  end

  describe "get users" do

    test "validate_user_update_params" do

      params = %{
        "username" => "masteradmin",
        "password" => "P@ssw0rd",
        "email" => "test@gmail.com",
        "status" => "Active"
      }

      {:ok, result} = UserContext.validate_user_update_params(params)

      assert result.valid? == true

    end

    test "validate_user_update_params_without_password" do

      params = %{
        "username" => "masteradmin",
        "password" => "",
        "email" => "test@gmail.com",
        "status" => "Active"
      }

      {:error, result} = UserContext.validate_user_update_params(params)

      assert result.errors == [password: {"can't be blank", [validation: :required]}]
      assert result.valid? == false
    end

    test "validate_user_update_params_without_username" do

      params = %{
        "username" => "",
        "password" => "P@ssw0rd",
        "email" => "test@gmail.com",
        "status" => "Active"
      }

      {:error, result} =  UserContext.validate_user_update_params(params)

      assert result.errors == [username: {"can't be blank", [validation: :required]}]
      assert result.valid? == false
    end

    test "validate_user_update_params_without_email" do

      params = %{
        "username" => "masteramin",
        "password" => "P@ssw0rd",
        "email" => "",
        "status" => "Active"
      }

      {:ok, result} = UserContext.validate_user_update_params(params)
      assert result.valid? == true
    end

    test "validate_user_update_params_without_status" do

      params = %{
        "username" => "masteramin",
        "password" => "P@ssw0rd",
        "email" => "test@gmail.com",
        "status" => ""
      }

      {:ok, changeset} = UserContext.validate_user_update_params(params)
      assert changeset.errors == []
      assert changeset.valid? == true
    end

    test "validate_username" do
      insert(:user, username: "masteradmin")
      params = %{
        "username" => "masteradmin",
        "password" => "P@ssw0rd",
        "email" => "test@gmail.com",
        "status" => "Active"
      }
      assert {:ok, changeset} = UserContext.validate_user_update_params(params)
      assert {:ok, user} = UserContext.validate_username(changeset)
    end

    test "validate_username_without_username" do
      insert(:user, username: "masteradmin")
      params = %{
        "username" => "",
        "password" => "P@ssw0rd",
        "email" => "test@gmail.com",
        "status" => "Active"
      }
      {:error, changeset} = UserContext.validate_user_update_params(params)
      assert changeset.errors == [username: {"can't be blank", [validation: :required]}]
      assert changeset.valid? == false
    end

    test "update_user_information" do
      user = insert(:user)
      insert(:agent, user: user, email: "testing@gmail.com")
      params = %{
        "username" => "masteradmin",
        "password" => "P@ssw0rd",
        "email" => "test@gmail.com",
        "status" => "Active"
      }

      assert {:ok, changeset} = UserContext.validate_user_update_params(params)
      assert changeset.valid? == true
    end

    test "update_user_information_without_email" do
      user = insert(:user)
      insert(:agent, user: user, email: "")
      params = %{
        "username" => "masteradmin",
        "password" => "P@ssw0rd",
        "email" => "test@yahoo.com",
        "status" => "Active"
      }

      {:ok, changeset} = UserContext.validate_user_update_params(params)
      {:ok, agent} =  UserContext.update_user_information(user, changeset)

      assert agent.email == "test@yahoo.com"
    end
  end

  test "validate parameters with valid values" do
    params = %{
      "username" => "masteradmin"
    }

    result = UserContext.validate_user_params(params)

    assert result  == {:ok, params["username"]}
  end

  test "validate parameters with null values" do
    params = %{
      "username" => ""
    }
    result = UserContext.validate_user_params(params)

    assert result == {:no_value_params}
  end

  test "validate parameters with no key" do
    params = %{}
    result = UserContext.validate_user_params(params)

    assert result == {:username_required}
  end
end

