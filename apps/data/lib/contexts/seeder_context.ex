defmodule Data.Contexts.SeederContext do
  @moduledoc """
  """

  alias Data.Schemas.{
    User,
    Member,
    Provider,
    Doctor,
    Payor,
    Agent,
    DoctorSpecialization,
    Specialization,
    CommonPassword,
    Permission,
    Application,
    Role
  }

  alias Data.Contexts.{
    UserContext,
    ProviderContext,
    DoctorContext,
    AgentContext,
    CardContext,
    PayorContext,
    MemberContext,
    SpecializationContext,
    RoleContext,
    PermissionContext
  }

  def insert_or_update_user(params) do
    with %User{} = user <- UserContext.get_user_by_username(params.username)
    do
      user
      |> UserContext.update_user(params)
    else
      nil ->
        UserContext.create_user(params)
    end
  end

  def insert_or_update_user_password(params) do
    with %User{} = user <- UserContext.get_user_password_by_user_id(params.user_id)
    do
      user
      |> UserContext.update_user_password(params)
    else
      nil ->
        UserContext.create_user_password(params)
    end
  end

  def insert_or_update_common_password(params) do
    commonpassword =
       UserContext.get_common_passwords(params.password)

    if is_nil(commonpassword) do
      UserContext.create_common_password(params)
    else
      commonpassword
      |> UserContext.update_common_password(params)
    end
  end

  def insert_or_update_card(params) do
    card = CardContext.get_card(params.number)
    if card != nil do
      card
      |> CardContext.update_card(params)
    else
      CardContext.insert_card(params)
    end
  end

  def insert_or_update_provider(params) do
    with %Provider{} = provider <- ProviderContext.get_provider_by_code(
      params.code)
    do
      provider
      |> ProviderContext.update_provider(params)
    else
      nil ->
        ProviderContext.create_provider(params)
    end
  end

  def insert_or_update_doctor(params) do
    with %Doctor{} = doctor <- DoctorContext.get_doctor_by_prc_number(
      params.prc_number)
    do
      doctor
      |> DoctorContext.update_doctor(params)
    else
      nil ->
        DoctorContext.create_doctor(params)
    end
  end

  def insert_or_update_doctor_specialization(params) do
    with %DoctorSpecialization{} = doctor_specialization <- DoctorContext.get_doctor_specialization_by_dtn(
      params.doctor_id, params.type, params.name)
    do
      doctor_specialization
      |> DoctorContext.update_doctor_specialization(params)
    else
      nil ->
        DoctorContext.create_doctor_specialization(params)
    end
  end

  def insert_or_update_agent(params) do
    with %Agent{} = agent <- AgentContext.get_agent_by_user_id(params.user_id)
    do
      agent
      |> AgentContext.update_agent(params)
    else
      nil ->
        AgentContext.create_agent(params)
    end
  end

  def insert_or_update_payor(params) do
    with %Payor{} = payor <- PayorContext.get_payor_by_code(
      params.code)
    do
      payor
      |> PayorContext.update_payor(params)
    else
      nil ->
        PayorContext.create_payor(params)
    end
  end

  def insert_or_update_member(params) do
    with %Member{} = member <- MemberContext.get_member_by_payorlink_member_id(
      params.payorlink_member_id)
    do
      member
      |> MemberContext.update_member(params)
    else
      nil ->
        MemberContext.insert_member(params)
    end
  end

  def insert_or_update_specialization(params) do
    specialization = SpecializationContext.get_specialization_by_name(params.name)
    if is_nil(specialization) do
      SpecializationContext.create_specialization(params)
    else
      SpecializationContext.update_specialization(specialization.id, params)
    end
  end

  def insert_or_update_permission(params) do
    permission = PermissionContext.get_permission_by_name(params.name, params.keyword)
    if is_nil(permission) do
      PermissionContext.create_permission(params)
    else
      PermissionContext.update_permission(permission.id, params)
    end
  end

  def insert_or_update_application(params) do
    application = RoleContext.get_application_by_name(params.name)
    if is_nil(application) do
      RoleContext.create_application(params)
    else
      RoleContext.update_application(application.id, params)
    end
  end

  def insert_or_update_role(params) do
    role = RoleContext.get_role_by_name(params.name)
    if is_nil(role) do
      RoleContext.create_role(params)
    else
      RoleContext.update_role(role.id, params)
    end
  end

  def insert_or_update_user_role(params) do
    ur = UserContext.get_ur_by_user_role(params)
    if is_nil(ur) do
      UserContext.create_user_roles(params)
    else
      UserContext.clear_user_roles(params.user_id)
      UserContext.create_user_roles(params)
    end
  end

  def insert_or_update_role_permission(params) do
    role_permission = RoleContext.get_role_permission_by_role_id(params.role_id, params.permission_id)
    if is_nil(role_permission) do
      RoleContext.create_role_permission(params.role_id, params.permission_id)
    else
      RoleContext.clear_role_permission_using_role_id(params.role_id, params.permission_id)
      RoleContext.create_role_permission(params.role_id, params.permission_id)
    end
  end

  def insert_or_update_role_application(params) do
    role_application = RoleContext.get_role_application_by_role_id(params.role_id, params.application_id)
    if is_nil(role_application) do
      RoleContext.create_role_application_seed(params.role_id, params.application_id)
    else
      RoleContext.clear_role_application(params.role_id, params.application_id)
      RoleContext.create_role_application_seed(params.role_id, params.application_id)
    end
  end
end
