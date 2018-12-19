defmodule ProviderLinkWeb.Api.V1.LoaView do
  use ProviderLinkWeb, :view

  alias ProviderLinkWeb.LoaView
  alias Data.Contexts.{
    UtilityContext,
  }

  def render("loa_required.json", %{loa_params: loa_params, status: status}) do
    %{
      loa: loa_params,
      status: status
    }
  end

  def render("loa_cart.json", %{loa: loa}) do
    %{
      count: Enum.count(loa)
    }
  end

  def render("single_member.json", %{member: member}) do
    %{
      number_of_dependents: member.number_of_dependents,
      principal: member.principal,
      relationship: member.relationship,
      type: String.capitalize(member.type),
      accounts: 1,
      card_no: member.member_card_no,
      last_facility: member.last_facility,
      latest_consult: member.latest_consult,
      random_facility1: member.random_facility1,
      random_facility2: member.random_facility2,
      attempts: member.attempts
    }
  end

  def render("many_member.json", %{member: member}) do
    %{
      member: member =
        render_many(
          member,
          ProviderLinkWeb.Api.V1.LoaView,
          "multiple_member.json",
          as: :member
        ),
      accounts: Enum.count(member)
    }
  end

  def render("multiple_member.json", %{member: member}) do
    %{
      name: LoaView.format_member_name_last(member),
      type: String.capitalize("#{member.type}"),
      account_name: member.account_name,
      card_no: member.member_card_no,
      birth_date: member.birth_date
    }
  end

  def format_date(date) do
    date = Ecto.Date.cast!(date)
    if date == "" || is_nil(date) do
      date
    else
      {_, formatted_date} = Timex.format(date, "%m/%d/%Y", :strftime)
      formatted_date
    end
  end

  def render("message.json", %{message: message}) do
    %{
      message: message
    }
  end

end
