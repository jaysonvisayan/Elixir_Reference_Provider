defmodule ProviderLinkWeb.AcuScheduleView do
  use ProviderLinkWeb, :view

  alias Data.{
    Contexts.AcuScheduleContext
  }
  alias Decimal

  def render("success.json", %{message: message}) do
  %{
     success: message
   }
  end

  def render("image.json", %{asm: asm}) do
    link =
      case Application.get_env(:provider_link, :env) do
        :dev ->
          "localhost:4000"
        :prod ->
          "https://providerlink-ip-ist.medilink.com.ph"
        _ ->
          nil
      end

    if is_nil(asm.image) do
      %{
         message: "Member is already forfeited in ACU Schedule Web"
       }
      # image_extension = Enum.at(String.split(asm.image.file_name, "."), 1)
      # %{
      #   name: asm.image.file_name,
      #   #link: upload.image_type
      #   link: "#{link}/uploads/images/#{asm.id}/original.#{image_extension}"
      # }
    else
      image_extension = Enum.at(String.split(asm.image.file_name, "."), 1)
      %{
        name: asm.image.file_name,
        is_recognized: asm.is_recognized,
        link: "#{link}/uploads/images/#{asm.id}/original.#{image_extension}"
      }
    end
  end

  def remove_seconds(time) do
    new_time =
      time
      |> Ecto.Time.to_erl()
      |> Time.from_erl()
      |> elem(1)
      |> Time.to_string()
      |> String.split(":")
      |> List.delete_at(2)
      |> List.insert_at(1, ":")
      |> Enum.join("")
  end

  def render("error.json", %{message: message}) do
  %{
     error: message
   }
  end

  def member_full_name(nil), do: "N/A"
  def member_full_name(loa), do: check_member(loa.member_first_name, loa.member_middle_name, loa.member_last_name, loa.member_suffix)

  def check_member(first_name, nil, last_name, nil), do:
    "#{last_name}, #{first_name}"

  def check_member(first_name, middle_name, last_name, nil), do:
    "#{last_name}, #{first_name} #{middle_name}"

  def check_member(first_name, nil, last_name, suffix), do:
    "#{last_name} #{suffix}, #{first_name}"

  def check_member(first_name, middle_name, last_name, suffix), do:
    "#{last_name} #{suffix}, #{first_name} #{middle_name}"

  def member_card_no_checker(loa) do
    if is_nil(loa) do
      "N/A"
    else
      loa.member_card_no
    end
  end

  def member_card_no(nil), do: "N/A"
  def member_card_no(loa), do: "'#{loa.member_card_no}'"

  def member_gender(loa) do
    if is_nil(loa) do
      "N/A"
    else
      loa.member_gender
    end
  end

  def member_birthdate(loa) do
    if is_nil(loa) do
      "N/A"
    else
      loa.member_birth_date
    end
  end

  def member_age(loa) do
    if is_nil(loa) do
      "N/A"
    else
      loa.member_age
    end
  end

  def availed_members(acu_members) do
    Enum.count(acu_members, &(&1.status == "Encoded"))
  end

  def get_guaranteed(acu_schedule_members, no_of_guaranteed) do
    member_count = Enum.count(acu_schedule_members)
    if(member_count >= no_of_guaranteed) do
      100
    else
      {count, _} = Integer.parse("#{((member_count / no_of_guaranteed) * 100)}")
      count
    end
  end

  def get_number(acu_members) do
    total = Enum.count(acu_members)
    %{
      registered: Enum.count(Enum.filter(acu_members, &(&1.status == "Encoded"))),
      unregistered: Enum.count(Enum.reject(acu_members, &(&1.status == "Encoded"))),
      total: total
     }
  end

  def compare_amount(total, nil),  do: total
  def compare_amount(total, guaranteed) do
    Decimal.compare(Decimal.new(total), Decimal.new(guaranteed))
  end

  def get_amount_details(total_amount, nil) do
    %{
      gross_adjustment: total_amount,
      total: total_amount
    }
  end

  def get_amount_details(total_amount, guaranteed) do
    diff =
      if(total_amount > guaranteed) do
        Decimal.new(0)
      else
        Decimal.sub(guaranteed, total_amount)
      end

    %{
      gross_adjustment: diff,
      total: Decimal.add(diff, total_amount)
    }
  end

  def validate_admission_date(date_to, prescription_term) do
    date_to =
      "#{date_to} 23:59:59"
      |> Ecto.DateTime.cast!()
      |> Ecto.DateTime.to_erl()
      |> :calendar.datetime_to_gregorian_seconds

    date_to =
      date_to + (get_prescription_term(prescription_term) * 86400)
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!()

    validity =
      date_to
      |> Ecto.DateTime.compare(Ecto.DateTime.utc())

    check_validity(validity)
  end

  defp check_validity(:lt), do: true
  defp check_validity(_), do: false

  def get_loa_total_amount(loa_package, loas) do
    Enum.map(loas, fn(loa) ->
      if loa_package.loa_id == loa.id do
        loa.total_amount
      end
    end)
    |> List.first()
  end

  def member_package_code(loa_id) do
    AcuScheduleContext.get_loa_package_code(loa_id)
  end

  def member_package_amount(loa_package_id) do
    AcuScheduleContext.get_loa_package_rate(loa_package_id)
  end

  def map_facilities(provider) do
      "#{provider.code} | #{provider.name}"
  end

  def count(asm) do
    selected =
      asm
      |> Enum.filter(&(&1.status == "Encoded"))
      |> Enum.count()
  end

  def check_upload(asmuf) do
    if is_nil(asmuf) do
      "No"
    else
      "Yes"
    end
  end

  defp get_prescription_term(nil), do: 0
  defp get_prescription_term(value), do: value
end
