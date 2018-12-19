defmodule ProviderLinkWeb.Api.V1.AcuScheduleView do
  use ProviderLinkWeb, :view
  alias Data.Contexts.UtilityContext
  alias ProviderLinkWeb.{
    LayoutView,
    LoaView
  }

  def render("acu_schedules.json", %{acu_schedules: acu_schedules}) do
    render_many(acu_schedules, ProviderLinkWeb.Api.V1.AcuScheduleView, "acu_schedule.json", as: :acu_schedule)
  end

  def render("acu_schedule.json", %{acu_schedule: acu_schedule}) do
    %{
      id: acu_schedule.id,
      batch_no: acu_schedule.batch_no,
      account_code: acu_schedule.account_code,
      account_name: acu_schedule.account_name,
      account_address: acu_schedule.account_address,
      no_of_guaranteed: acu_schedule.no_of_guaranteed,
      guaranteed_amount: acu_schedule.guaranteed_amount,
      date_from: to_mm_dd_yyyy(acu_schedule.date_from),
      date_to: to_mm_dd_yyyy(acu_schedule.date_to),
      created_by: acu_schedule.created_by,
      status: acu_schedule.status,
      registered: acu_schedule.registered,
      unregistered: acu_schedule.unregistered,
      direct_cost: acu_schedule.soa_amount,
      gross_adjustment: acu_schedule.estimate_total_amount,
      total_amount: acu_schedule.actual_total_amount,
      soa_reference_no: acu_schedule.soa_reference_no,
      members: render_many(acu_schedule.acu_schedule_members, ProviderLinkWeb.Api.V1.AcuScheduleView, "member.json", as: :member)
    }
  end

  def render("member.json", %{member: acu_schedule_member}) do
    %{
      id: acu_schedule_member.id,
      first_name: acu_schedule_member.loa.member_first_name,
      middle_name: acu_schedule_member.loa.member_middle_name,
      last_name: acu_schedule_member.loa.member_last_name,
      extension: acu_schedule_member.loa.member_suffix,
      # civil_status: acu_schedule_member.loa.member_civil_stVatus,
      # relationship: acu_schedule_member.loa.member_relationship,
      civil_status: "N/A",
      relationship: "N/A",
      email_address: acu_schedule_member.loa.member_email,
      mobile: acu_schedule_member.loa.member_mobile,
      gender: acu_schedule_member.loa.member_gender,
      type: acu_schedule_member.loa.member_type,
      birth_date: acu_schedule_member.loa.member_birth_date,
      account_code: acu_schedule_member.acu_schedule.account_code,
      account_name: acu_schedule_member.acu_schedule.account_name,
      is_availed: acu_schedule_member.is_availed,
      is_registered: acu_schedule_member.is_registered,
      batch_status: acu_schedule_member.status,
      package_rate: acu_schedule_member.loa.total_amount,
      loa_status: get_loa_status(acu_schedule_member.loa),
      package_code: get_package(acu_schedule_member.loa).package_code,
      package_name: get_package(acu_schedule_member.loa).package_name,
      provider_code: acu_schedule_member.acu_schedule.provider.code,
      card_no: acu_schedule_member.loa.member_card_no,
      age: UtilityContext.age(acu_schedule_member.loa.member_birth_date),
      is_recognized: acu_schedule_member.is_recognized
    }
  end

  defp get_package(nil) do
    %{
      package_code: nil,
      package_name: nil
     }
  end

  defp get_loa_status(nil), do: nil
  defp get_loa_status(loa), do: loa.status

  defp get_package(loa) do
    %{
      package_code: List.first(loa.loa_packages).code,
      package_name: List.first(loa.loa_packages).description
     }
  end

  defp to_mm_dd_yyyy(date) do
    if is_nil(date) do
      date
    else
    {year, month, date} =
      date
      |> Ecto.Date.to_string()
      |> String.split("-")
      |> List.to_tuple()
    "#{month}-#{date}-#{year}"
    end
  end

  def render("acu_schedules_by_providers.json", %{acu_schedules: acu_schedules}) do
    render_many(acu_schedules, ProviderLinkWeb.Api.V1.AcuScheduleView, "acu_schedule_by_provider.json", as: :acu_schedule)
  end

  def render("acu_schedule_by_provider.json", %{acu_schedule: acu_schedule}) do
    %{
      id: acu_schedule.id,
      created_date: acu_schedule.inserted_at |> Ecto.DateTime.cast!() |> LoaView.format_datetime(),
      batch_no: acu_schedule.batch_no,
      account_code: acu_schedule.account_code,
      account_name: acu_schedule.account_name,
      account_address: acu_schedule.account_address,
      date_from: to_mm_dd_yyyy(acu_schedule.date_from),
      date_to: to_mm_dd_yyyy(acu_schedule.date_to),
      status: acu_schedule.status,
      total_of_individuals: acu_schedule.member_count
    }
  end

  def render("view_soas.json", %{soas: soas}) do
    render_many(soas, ProviderLinkWeb.Api.V1.AcuScheduleView, "soa.json", as: :soa)
  end

  def render("soa.json", %{soa: soa}) do
    %{
      base_64_encoded: soa.base_64_encoded,
      extension: soa.extension,
      name: soa.name
    }
  end

  defp is_recognized(is_recognized) do
    if is_nil(is_recognized) do
      false
    else
      is_recognized
    end
  end

  def render("acu_schedule_progress.json", %{acu_schedule: acu_schedule}) do
    for asm <- acu_schedule.acu_schedule_members do
      if is_nil(asm.image) do
        %{
          id: asm.id,
          name: "",
          is_recognized: "",
          link: ""
        }
      else
        image =
          ProviderLinkWeb.ImageUploader
          |> LayoutView.image_url_for(asm.image, asm, :original)
          |> String.replace("/apps/provider_link/assets/static", "")
          %{
            id: asm.id,
            name: asm.image.file_name,
            is_recognized: asm.is_recognized,
            link: image
          }
      end
    end
  end

end
