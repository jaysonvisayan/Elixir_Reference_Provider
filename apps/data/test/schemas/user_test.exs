defmodule Data.Schemas.UserTest do
  use Data.SchemaCase

  alias Data.Schemas.User

  test "auth_changeset with result" do
    params = %{
      username: "masteradmin",
      password: "P@ssw0rd"
    }

    changeset = User.auth_changeset(%User{}, params)
    assert changeset.valid?
  end

  test "auth_changeset with invalid params" do
    params = %{
      username: "masteradmin",
    }

    changeset = User.auth_changeset(%User{}, params)
    refute changeset.valid?
  end

  test "create_changeset with valid params" do
    params = %{
      username: "masteradmin",
      password: "P@ssw0rd",
      password_confirmation: "P@ssw0rd"
    }

    result = User.create_changeset(%User{}, params)
    assert result.valid?
  end

  test "create_changeset with invalid params" do
    params = %{
      username: "masteradmin",
      password: "password"
    }

    result = User.create_changeset(%User{}, params)
    refute result.valid?
  end

  test "pin_changeset with valid params" do
    params = %{
      pin: "1234",
      pin_expires_at: Ecto.DateTime.utc
    }

    result = User.pin_changeset(%User{}, params)
    assert result.valid?
  end

  test "pin_changeset with invalid params" do
    params = %{
      pin_expires_at: Ecto.DateTime.utc
    }

    result = User.pin_changeset(%User{}, params)
    refute result.valid?
  end

  # test "login_attempt_changeset with valid params" do
  #   params = %{
  #     attempt: 2,
  #     status: "active"
  #   }
  #   result = User.login_attempt_changeset(%User{}, params)
  #   assert result.valid?
  # end

  # test "login_attempt_changeset with invalid params" do
  #   params = %{
  #     attempt: 2,
  #   }
  #   result = User.login_attempt_changeset(%User{}, params)
  #   refute result.valid?
  # end

  test "password_changeset with valid params" do
    params = %{
      password: "P@ssw0rd",
      password_confirmation: "P@ssw0rd",
      attempt: 0,
      status: "active"
    }
    result = User.password_changeset(%User{}, params)
    assert result.valid?
  end

  test "password_changeset with invalid params" do
    params = %{
      password_confirmation: "P@ssw0rd"
    }
    result = User.password_changeset(%User{}, params)
    refute result.valid?
  end
end
