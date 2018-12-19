defmodule ProviderLinkWeb.Factory do
  @moduledoc """
  """

  use ExMachina.Ecto, repo: Data.Repo

  alias Data.Schemas.{
    User,
    Member,
    Card,
    Provider,
    Agent,
    Loa,
    Doctor,
    Payor,
    AcuScheduleMember,
    AcuSchedule,
    Batch,
    File,
    LoaPackage,
    Role,
    Permission,
    Application,
    RoleApplication,
    RolePermission,
    UserRole,
    Sequence,
    LoginIpAddress
  }

  def user_factory do
    %User{}
  end

  def acu_schedule_factory do
    %AcuSchedule{}
  end

 def acu_schedule_member_factory do
    %AcuScheduleMember{}
  end

  def member_factory do
    utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds

    pin_expiry =
      (utc + 5 * 60)

    pin_expiry =
      pin_expiry
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

    %Member{
      first_name: "Juan",
      middle_name: "Dela",
      last_name: "Cruz",
      birth_date: Ecto.Date.cast!("1996-02-12"),
      payorlink_member_id: "7552ebd7-035c-4d56-a58c-f193c2c9b92c",
      pin: "1234",
      pin_expires_at: Ecto.DateTime.cast!(pin_expiry)
    }
  end

  def card_factory do
    %Card{
      number: "0123456789123456",
      payorlink_member_id: "7552ebd7-035c-4d56-a58c-f193c2c9b92c"
    }
  end

  def provider_factory do
    %Provider{
      name: "Makati Medical Center",
      code: "880000000006035"
    }
  end

  def agent_factory do
    %Agent{
      user: build(:user),
      provider: build(:provider),
    }
  end

  def loa_factory do
    %Loa{}
  end

  def doctor_factory do
    %Doctor{}
  end

  def payor_factory do
    %Payor{}
  end

  def batch_factory do
    %Batch{}
  end

  def file_factory do
    %File{
      batch: build(:batch)
    }
  end

  def loa_package_factory do
    %LoaPackage{}
  end

  def application_factory do
    %Application{}
  end

  def role_factory do
    %Role{}
  end

  def permission_factory do
    %Permission{}
  end

  def role_permission_factory do
    %RolePermission{
      role: build(:role),
      permission: build(:permission)
    }
  end

  def role_application_factory do
    %RoleApplication{
      role: build(:role),
      application: build(:application)
    }
  end

  def user_role_factory do
    %UserRole{
      user: build(:user),
      role: build(:role)
    }
  end

  def sequence_factory do
    %Sequence{}
  end

  def login_ip_address_factory do
    %LoginIpAddress{
      ip_address: "1.1.1.1",
      attempts: 1
    }
  end

end
