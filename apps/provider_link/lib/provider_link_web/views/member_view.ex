defmodule ProviderLinkWeb.MemberView do
  use ProviderLinkWeb, :view
  alias ProviderLinkWeb.LoaView

  def render("card.json", %{card: card, member: member, facilities: facilities}) do
    %{
      id: card.id,
      number: card.number,
      member: render_one(
        member,
        ProviderLinkWeb.MemberView,
        "member.json",
        as: :member,
        card: card,
        facilities: facilities
      )
    }
  end

  def render("card_formatted.json", %{card: card, member: member, facilities: facilities}) do
    %{
      id: card.id,
      number: LoaView.format_card_no(card.member_card_no),
      member: render_one(member, ProviderLinkWeb.MemberView, "member.json", member: :member, card: card, facilities: nil)
    }
  end

  def render("peme_member.json", %{member: member, facilities: facilities, birth_date: birth_date}) do
    %{
      id: member.payorlink_member_id,
      age: LoaView.get_age(member.member_birth_date),
      gender: member.member_gender,
      evoucher_number: member.member_evoucher_number,
      birth_date: birth_date
    }
  end

  def render("member.json", %{member: member, facilities: facilities}) do
    %{
      id: member.member_id,
      # name: LoaView.format_name_last(member),
      # full_name: LoaView.format_name_first(member),
      # birth_date: LoaView.format_date(member.birth_date),
      birthdate: member_bdate_checker(member),
      gender: member.member_gender,
      age: LoaView.get_age(member.member_birth_date),
      number_of_dependents: 0,
      email_address: member.member_email,
      email_address2: member.member_email,
      mobile: member.member_mobile,
      mobile2: member.member_mobile,
      principal: member.member_type,
      relationship: member.member_type,
      type: (if !is_nil(member.member_type), do: String.capitalize(member.member_type)),
      facilities: facilities,
      account_code: member.member_account_code,
      account_name: member.member_account_name,
      accounts: 1,
      attempt_expires: member.member_attempt_expiry,
      attempts: member.member_attempts,
      card_number: format_card_no(member.member_card_no),
      remarks: "N/A",
      last_facility: "N/A",
      latest_consult: "N/A",
      payor: render_one(
        member.payor,
        ProviderLinkWeb.MemberView,
        "payor.json",
        as: :payor
      )
    }
  end

  def render("member_account.json", %{member: member, card: card, facilities: facilities}) do
    %{
      id: member.id,
      name: LoaView.format_name_last(member),
      birth_date: LoaView.format_date(member.birth_date),
      gender: member.gender,
      age: LoaView.get_age(member.birth_date),
      number_of_dependents: member.number_of_dependents,
      email_address: member.email_address,
      email_address2: member.email_address2,
      mobile: member.mobile,
      mobile2: member.mobile2,
      principal: member.principal,
      relationship: member.relationship,
      type: String.capitalize(member.type),
      facilities: facilities,
      account_code: member.account_code,
      account_name: member.account_name,
      accounts: 1,
      attempt_expires: member.attempt_expiry,
      card_number: card.number
    }
  end

  defp validate_middle(middle_name) do
    if is_nil(middle_name) do
      " "
    else
      middle_name
    end
  end

  def render("many_member.json", %{member: member, facilities: facilities}) do
    %{
      member: member =
        render_many(
          member,
          ProviderLinkWeb.MemberView,
          "member.json",
          as: :member,
          facilities: facilities
        ),
      accounts: Enum.count(member)
    }

  end

  def render("many_member2.json", %{card: card, member: member, facilities: facilities}) do
    %{
      member: render_many(
        member,
        ProviderLinkWeb.MemberView,
        "member2.json",
        as: :member,
        card: card,
        facilities: facilities
      )
    }
  end

  def render("none.json", %{}) do
    %{
      id: "none"
    }
  end

  def render("message.json", %{message: message}) do
    %{
      message: message
    }
  end

  def render("message2.json", %{message: message, valid: valid}) do
    %{
      valid: valid,
      message: message
    }
  end

  def render("payor.json", %{payor: payor}) do
    %{
      name: payor.name,
      code: payor.code
    }
  end

  def render("accountlink_member.json", %{member: member}) do
    %{
      id: member.id,
      first_name: member.first_name,
      middle_name: member.middle_name,
      last_name: member.last_name,
      suffix: member.extension,
      date_of_birth: member.birth_date,
      civil_status: member.civil_status,
      male: member.male?,
      female: member.female?,
      age_from: member.age_from,
      age_to: member.age_to
    }
  end

  def total_amount(loa) do
    for loa_diagnosis <- loa.loa_diagnosis do
      for loa_procedure <- loa_diagnosis.loa_procedure do
        loa_procedure.amount
      end
    end
  end

  def check_member_value(member, member_value) do
    if String.downcase(member.first_name) != "temporary" do
      member_value
    else
      ""
    end
  end

  def slice_evoucher(evoucher) do
    String.slice(evoucher,5..10)
  end

  def render("block_member.json", %{member: member}) do
    %{
      attempt_expiry: member.attempt_expiry
    }
  end

  def render("loa_member.json", %{loa: loa}) do
    %{
      id: loa.id,
      member_id: loa.payorlink_member_id,
      first_name: loa.member_first_name,
      middle_name: loa.member_middle_name,
      last_name: loa.member_last_name,
      suffix: loa.member_suffix,
      date_of_birth: loa.member_birth_date,
      male: loa.member_male?,
      female: loa.member_female?
    }
  end

  def format_card_no(card_no) do
    if is_nil(card_no) || card_no == "" do
      "N/A"
    else
      "#{String.slice(card_no, 0, 4)}-#{String.slice(card_no, 4, 4)}-#{String.slice(card_no, 8, 4)}-#{String.slice(card_no, 12, 4)}"
    end
  end

  defp member_bdate_checker(member) do
    if is_nil(member.member_birth_date), do: nil, else:
    LoaView.format_date(member.member_birth_date)
  end

  def get_file_url(nil), do: ""
  def get_file_url(file) do
    ProviderLink.FileUploader
    |> ProviderLinkWeb.LayoutView.image_url_for(file.type, file, :original)
    |> String.replace("/apps/provider_link/assets/static", "")
  end

  def get_file_url_facial(nil), do: ""
  def get_file_url_facial(file) do
    ProviderLink.FileUploader
    |> ProviderLinkWeb.LayoutView.image_url_for(file.facial_image, file, :original)
    |> String.replace("/apps/provider_link/assets/static", "")
  end
end
