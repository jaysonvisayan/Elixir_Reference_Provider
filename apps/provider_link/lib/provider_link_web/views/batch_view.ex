defmodule ProviderLinkWeb.BatchView do
  use ProviderLinkWeb, :view

  def map_doctors(doctors) do
    if Enum.empty?(doctors) do
      ["Select Practitioner": ""]
    else
      doctors
      |> Enum.map(&{"Dr. #{&1.first_name} #{&1.last_name}", &1.id})
    end
  end

  def display_created_by(batch) do
    if is_nil(batch.created_by_id) do
      "N/A"
    else
      batch.created_by.username
    end
  end

  def display_batch_type(batch) do
    cond do
      is_nil(batch.type) ->
        "N/A"
      batch.type == "practitioner" ->
        "Practitioner"
      batch.type == "hospital_bill" ->
        "Hospital Bill"
      true ->
        "Invalid Batch"
    end
  end

  def display_practitioner(batch) do
    if is_nil(batch.doctor_id) do
      "N/A"
    else
      "Dr. #{batch.doctor.first_name} #{batch.doctor.last_name}"
    end
  end

  def display_payor(batch) do
    if is_nil(batch.created_by) do
      "N/A"
    else
      batch.created_by.agent.provider.name
    end
  end

  def display_member(loa) do
    if is_nil(loa.member_first_name) do
      "Member: N/A"
    else
      "#{loa.member_first_name} #{loa.member_last_name}"
    end
  end

  def display_card(loa) do
    if is_nil(loa.member_card_no) do
      "Card No.: N/A"
    else
      "Card No. #{loa.member_card_no}"
    end
  end

  def display_actual_soa_amount(batch) do
    amounts = Enum.map(batch.batch_loas, fn(bl) ->
      bl.loa.total_amount
    end)
    if not Enum.empty?(amounts) do
    Enum.reduce(amounts, fn(amount, acc) ->
      Decimal.add(amount, acc)
    end)
    else
      Decimal.new(0)
    end
  end

end
