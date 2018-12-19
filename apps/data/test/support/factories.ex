defmodule Data.Factories do
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
    LoaDiagnosis,
    LoaPackage,
    LoaProcedure,
    AcuSchedule,
    AcuScheduleMember,
    AcuScheduleMemberUploadFile,
    AcuSchedulePackage,
    Payor,
    Batch,
    BatchLoa,
    Role,
    Permission,
    UserRole,
    RolePermission,
    RoleApplication,
    Application
  }

  def user_factory do
    %User{}
  end

  def member_factory do
    %Member{}
  end

  def card_factory do
    %Card{}
  end

  def provider_factory do
    %Provider{
      name: "Makati Medical Center",
      code: "880000000006035"
    }
  end

  def agent_factory do
    %Agent{}
  end

  def loa_factory do
    %Loa{}
  end

  def doctor_factory do
    %Doctor{}
  end

  def loa_diagnosis_factory do
    %LoaDiagnosis{
      loa: build(:loa)
    }
  end

  def loa_procedure_factory do
    %LoaProcedure{
      loa_diagnosis: build(:loa_diagnosis)
    }
  end

  def payor_factory do
    %Payor{}
  end

  def acu_schedule_factory do
    %AcuSchedule{}
  end

  def acu_schedule_member_factory do
    %AcuScheduleMember{
      acu_schedule: build(:acu_schedule)
    }
  end

  def acu_schedule_package_factory do
    %AcuSchedulePackage{
      acu_schedule: build(:acu_schedule)
    }
  end

  def loa_package_factory do
    %LoaPackage{}
  end

  def batch_factory do
    %Batch{}
  end

  def batch_loa_factory do
    %BatchLoa{}
  end

  def acu_schedule_member_upload_file_factory do
    %AcuScheduleMemberUploadFile{}
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

  def application_factory do
    %Application{}
  end
end
