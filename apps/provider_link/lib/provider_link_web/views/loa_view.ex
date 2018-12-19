defmodule ProviderLinkWeb.LoaView do
  use ProviderLinkWeb, :view

  alias Decimal
  alias Timex.Duration
  alias Ecto.Date

  alias Innerpeace.ProviderLink.NumberToWord

  alias Data.Contexts.{
    LoaContext,
    MemberContext
  }

  def check_expiry(expires_at) do
    utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds
    expiry = expires_at |> Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds
    expiry - utc
  end

  def check_sent_code(sent_code) do
    if not is_nil(sent_code) do
      utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds
      sent_code = sent_code |> Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds
      expiry = (sent_code - 4 * 60)
      expiry - utc
    else
      0
    end
  end

  def filter_otp(loa) do
    case loa.verification_type do
      "card_no_cvv" ->
        "card_no_cvv"
      "member_details" ->
        "member_details"
      "e_voucher" ->
        "e_voucher"
      "qr_code" ->
        "qr_code"
      _ ->
        ""
    end
  end

  def filter_otp_by_id(loa_id) do
    loa = LoaContext.get_loa_by_id(loa_id)
    case loa.verification_type do
      "card_no_cvv" ->
        "card_no_cvv"
      "member_details" ->
        "member_details"
      "e_voucher" ->
        "e_voucher"
      "qr_code" ->
        "qr_code"
      _ ->
        ""
    end
  end

  def filter_diagnosis(diagnoses) do
    list =
      case diagnoses do
        {:diagnosis, diagnoses} ->
          list = [] ++ for diagnosis <- diagnoses do
            diagnosis
          end

          list
          |> Enum.map(&{"#{&1["code"]}/#{&1["description"]}", &1["payorlink_diagnosis_id"]})
        _ ->
          []
      end

    [{"Select diagnosis", ""}] ++ list
  end

  def filter_diagnosis_procedure(diagnoses, loa_diagnoses) do
    list = [] ++ for diagnosis <- diagnoses do
      diagnosis
    end

    list =
      list
      |> Enum.map(&{"#{&1["code"]}/#{&1["description"]}", &1["payorlink_diagnosis_id"]})

    loa_list = [] ++ for loa_diagnosis <- loa_diagnoses do
      loa_diagnosis
    end

    loa_list =
      loa_list
      |> Enum.map(&{"#{&1.diagnosis_code}/#{&1.diagnosis_description}", &1.payorlink_diagnosis_id})
    list = list -- loa_list

    [{"Select diagnosis", ""}] ++ list
  end

  def filter_procedure(procedures) do
    list = [] ++ for procedure <- procedures do
      procedure
    end

    list =
      list
      |> Enum.map(&{"#{&1.payor_code}  /  #{&1.payor_description}", &1.id})

    [{"Select procedure", ""}] ++ list
  end

  def filter_doctors(doctors) do
    list = [] ++ for doctor <- doctors do
      doctor
    end

    list =
      list
      |> Enum.map(&{"#{&1["prc_number"]} | #{&1["first_name"]} #{&1["last_name"]} | #{&1["specialization_name"]}", &1["payorlink_practitioner_specialization_id"]})

    [{"Select doctor", ""}] ++ list
  end

  def get_age(birthdate) do
    if is_nil(birthdate) or validate_yyyymmdd_format(to_string(birthdate)) == false do
      "N/A"
    else
      year_of_birthdate = to_string(birthdate)
      year_today =  Ecto.Date.utc
      year_today = to_string(year_today)
      datediff1 = Timex.parse!(year_of_birthdate, "%Y-%m-%d", :strftime)
      datediff2 = Timex.parse!(year_today, "%Y-%m-%d", :strftime)
      Timex.diff(datediff2, datediff1, :years)

    end
  end

  def validate_yyyymmdd_format(string) do
    Regex.match?(~r/^(19|20)[0-9]{2}-((02-(0[1-9]|[1-2][0-9]))|((01|03|05|07|08|10|12)-(0[1-9]|[1-2][0-9]|3[0-1]))|((04|06|09|11)-(0[1-9]|[1-2][0-9]|30)))$/, string)
  end


  def format_date(date) do
    if date == "" || is_nil(date) do
      date
    else
      {_, formatted_date} = Timex.format(date, "%m/%d/%Y", :strftime)
      formatted_date
    end
  end

  def format_date_print(date) do
    if date == "" || is_nil(date) do
      ""
    else
      {_, formatted_date} = Timex.format(date, "{D}-{Mshort}-{YYYY}")
      formatted_date
    end
  end

  def format_datetime(datetime) do
    if datetime == "" || is_nil(datetime) do
      datetime
    else
      {{yy, mm, dd},{h, m, s}} = Ecto.DateTime.to_erl(datetime)
      mm = if mm > 9 do
        mm
      else
        "0#{mm}"
      end
      dd = if dd > 9 do
        dd
      else
        "0#{dd}"
      end
      m = if m > 9 do
        m
      else
        "0#{m}"
      end
      s = if s > 9 do
        s
      else
        "0#{s}"
      end
      if h > 12 do
        h = if h-12 > 9 do
          "#{yy}/#{mm}/#{dd} #{h-12}:#{m}:#{s} PM"
        else
          "#{yy}/#{mm}/#{dd} 0#{h-12}:#{m}:#{s} PM"
        end
      else
        h = if h > 9 do
          h
        else
          "0#{h}"
        end
        "#{yy}/#{mm}/#{dd} #{h}:#{m}:#{s} AM"
      end
    end
  end

  def format_card_no(card_no) do
    if is_nil(card_no) || card_no == "" do
      "N/A"
    else
      "#{String.slice(card_no, 0, 4)}-#{String.slice(card_no, 4, 4)}-#{String.slice(card_no, 8, 4)}-#{String.slice(card_no, 12, 4)}"
    end
  end

  def format_name_last(loa) do
    cond do
      is_nil(loa.member_first_name) ->
        "N/A"
      not is_nil(loa.member_suffix) ->
        "#{loa.member_last_name}, #{loa.member_first_name} #{loa.member_middle_name}, #{loa.member_suffix}"
      true ->
        "#{loa.member_last_name}, #{loa.member_first_name} #{loa.member_middle_name}"
    end
  end

  def format_member_name_last(member) do
    if member.extension == "" do
      "#{member.last_name}, #{member.first_name} #{member.middle_name}"
    else
      "#{member.last_name}, #{member.first_name} #{member.middle_name}, #{member.extension}"
    end
  end

  def format_name_first(loa) do
    cond do
      is_nil(loa.member_first_name) ->
        "Member: N/A"
      not is_nil(loa.member_suffix) ->
        "#{loa.member_first_name} #{loa.member_middle_name} #{loa.member_last_name}, #{loa.member_suffix}"
      true ->
        "#{loa.member_first_name} #{loa.member_middle_name} #{loa.member_last_name}"
    end
  end

  def format_name_first_doctor(loa) do
    cond do
      is_nil(loa.first_name) ->
        "Member: N/A"
      not is_nil(loa.extension) ->
        "#{loa.first_name} #{loa.middle_name} #{loa.last_name}, #{loa.extension}"
      true ->
        "#{loa.first_name} #{loa.middle_name} #{loa.last_name}"
    end
  end

  def format_member_name_first(member) do
    if member.extension != "" do
      "#{member.first_name} #{member.middle_name} #{member.last_name}, #{member.extension}"
    else
      "#{member.first_name} #{member.middle_name} #{member.last_name}"
    end
  end

  def filter_loa_procedures(loa_procedures, procedures) do
    loa_procedures = for loa_procedure <- loa_procedures, into: [] do
      %{
        procedure_code: loa_procedure.procedure_code,
        procedure_description: loa_procedure.procedure_description
      }
    end
    procedures = for procedure <- procedures, into: [] do
      %{
        procedure_code: procedure.code,
        procedure_description: procedure.description
      }
    end
    procedures -- loa_procedures
    |> Enum.sort_by(&(&1.code))
  end

  def total_amount(loa) do
    for loa_diagnosis <- loa.loa_diagnosis do
      for loa_procedure <- loa_diagnosis.loa_procedure do
        loa_procedure.amount
      end
    end
  end

  def render("loa.json", %{loa: loa}) do
    if loa.is_peme do
      %{
        id: loa.id,
        transaction_id: loa.transaction_id,
        inserted_at: loa.inserted_at |> DateTime.to_date(),
        payor: "",
        issue_date: (if is_nil(
          loa.issue_date), do: "",
          else: format_datetime(loa.issue_date)),
          payor: "",
          coverage: loa.coverage,
          status: if is_nil(loa.status) do loa.status else String.downcase(loa.status) end,
          loa_number: if is_nil(loa.loa_number) do "" else loa.loa_number end,
          otp: loa.otp,
          total_amount: if is_nil(loa.total_amount) do "" else loa.total_amount |> Decimal.round(2) end,
          verification_type: loa.verification_type,
          is_cart: loa.is_cart,
          is_batch: loa.is_batch,
          member: render_one(
            loa,
            ProviderLinkWeb.MemberView,
            "peme_member.json",
            member: :member,
            card: loa.member_card_no,
            facilities: nil,
            birth_date: loa.member_birth_date
          )
      }
          else
          %{
            id: loa.id,
            transaction_id: loa.transaction_id,
            inserted_at: loa.inserted_at |> DateTime.to_date(),
            payor: "",
            issue_date: (if is_nil(
              loa.issue_date), do: "",
              else: format_datetime(loa.issue_date)),
              coverage: loa.coverage,
              payor: "",
              status: if is_nil(loa.status) do loa.status else String.downcase(loa.status) end,
              loa_number: if is_nil(loa.loa_number) do "" else loa.loa_number end,
              otp: loa.otp,
              total_amount: (if is_nil(loa.total_amount) do "" else loa.total_amount |> Decimal.round(2) end),
              verification_type: loa.verification_type,
              card: render(
                ProviderLinkWeb.MemberView,
                "card_formatted.json",
                %{
                  card: loa,
                  member: loa,
                  facilities: nil
                }
              )
          }
    end
  end

  def render("search_loas.json", %{loas: loas}) do
    %{
      loas: render_many(loas, ProviderLinkWeb.LoaView, "search_loa.json", as: :loa)
    }
  end

  def render("search_loa.json", %{loa: loa}) do
      %{
        id: loa.id,
        transaction_id: loa.transaction_id,
        inserted_at: loa.inserted_at |> DateTime.to_date(),
        loa_number: if is_nil(loa.loa_number) do "" else loa.loa_number end,
        total_amount: if is_nil(loa.total_amount) do "" else loa.total_amount |> Decimal.round(2) end
      }
  end

  def render("loa_pin.json", %{loa: loa}) do
    utc =
      :erlang.universaltime
      |> :calendar.datetime_to_gregorian_seconds

    expires_at =
      loa.pin_expires_at
      |> Ecto.DateTime.to_erl
      |> :calendar.datetime_to_gregorian_seconds

    expires_at = expires_at - utc

    sent_code =
      loa.pin_expires_at
      |> Ecto.DateTime.to_erl
      |> :calendar.datetime_to_gregorian_seconds

    expiry = (sent_code - 4 * 60)
    sent_code = expiry - utc

    %{
      pin: loa.pin,
      pin_expires_at: expires_at,
      sent_code: sent_code
    }
  end

  def render("loas.json", %{loas: loas}) do
    %{
      loas: render_many(loas, ProviderLinkWeb.LoaView, "loa.json", as: :loa)
    }
  end

  def age(nil), do: "N/A"
  def age(%Ecto.Date{day: d, month: m, year: y}, as_of \\ :now) do
    do_age({y, m, d}, as_of)
  end

  def do_age(birthday, :now) do
    {today, _time} = :calendar.now_to_datetime(:erlang.now)
    calc_diff(birthday, today)
  end

  def do_age(birthday, date), do: calc_diff(birthday, date)

  def calc_diff({y1, m1, d1}, {y2, m2, d2}) when m2 > m1 or (m2 == m1 and d2 >= d1) do
    y2 - y1
  end

  def calc_diff({y1, _, _}, {y2, _, _}), do: (y2 - y1) - 1

  def amount(nil), do: 0
  def amount(amount), do: amount

  def to_date(nil), do: ""
  def to_date(date) do
    Ecto.DateTime.to_date(date)
  end

  def format_birthdate(date) do
    if is_nil(date) do
      "N/A"
    else
      date = to_string(date)
      date =
        date
        |> String.split("-")
      year = Enum.at(date, 0)
      month = Enum.at(date, 1)
      day = Enum.at(date, 2)

      month =
        cond do
          month == "01" ->
            "January"
          month == "02" ->
            "February"
          month == "03" ->
            "March"
          month == "04" ->
            "April"
          true ->
            months2(month)
        end

      "#{month} #{day}, #{year}"
    end
  end

  def format_birthdate2(date) do
    {:ok, date} = date
    date = to_string(date)
    date =
      date
      |> String.split("-")
    year = Enum.at(date, 0)
    month = Enum.at(date, 1)
    day = Enum.at(date, 2)

    month =
      cond do
        month == "01" ->
          "January"
        month == "02" ->
          "February"
        month == "03" ->
          "March"
        month == "04" ->
          "April"
        true ->
          months2(month)
      end

    "#{month} #{day}, #{year}"
  end

  defp months2(month) do
    case month do
      "05" ->
        "May"
      "06" ->
        "June"
      "07" ->
        "July"
      "08" ->
        "August"
      "09" ->
        "September"
      "10" ->
        "October"
      "11" ->
        "November"
      "12" ->
        "December"
    end
  end

  def is_excutive_inpatient?(acu_type) do
    if is_nil(acu_type) do
    else
      type =
        acu_type
        |> String.split("-")
        |> Enum.into([], &(String.trim(&1)))
        |> Enum.join(" ")
        |> String.downcase()
        type == "executive inpatient"
    end
  end

  def render("message.json", %{valid: valid, message: message}) do
    %{
      valid: valid,
      message: message
    }
  end

  def render("message.json", %{message: message}) do
    %{
      message: message
    }
  end

  def p_display_complete_address(facility) do
    "#{facility.line_1}, #{facility.line_2}, #{facility.city},
    #{facility.province}, #{facility.region}, #{facility.country}"
  end

  def member_full_name(member) do
    if is_nil(member.extension) do
      if is_nil(member.middle_name) do
        "#{member.last_name}, #{member.first_name}"
      else
        "#{member.last_name}, #{member.first_name} #{member.middle_name}"
      end
    else
      if is_nil(member.middle_name) do
        "#{member.last_name} #{member.extension}, #{member.first_name}"
      else
        "#{member.last_name} #{member.extension}, #{member.first_name} #{member.middle_name}"
      end
    end
  end

  def member_full_name(_, nil, _, _), do: "Invalid Member Name"
  def member_full_name(_, _, _, nil), do: "Invalid Member Name"
  def member_full_name(nil, first_name, nil, last_name), do: "#{last_name}, #{first_name}"
  def member_full_name(nil, first_name, middle_name, last_name), do: "#{last_name}, #{first_name} #{middle_name}"
  def member_full_name(suffix, first_name, nil, last_name), do: "#{last_name} #{suffix}, #{first_name}"
  def member_full_name(suffix, first_name, middle_name, last_name), do: "#{last_name} {#suffix}, #{first_name} #{middle_name}"

  def display_card_number(card_number) do
    first = String.slice(card_number, 0..3)
    second = String.slice(card_number, 4..7)
    third = String.slice(card_number, 8..11)
    fourth = String.slice(card_number, 12..15)
    "#{first}-#{second}-#{third}-#{fourth}"

  end

  def consult_valid_until(date) do
    if not is_nil(date) do
      date = Date.cast!(date)
      date = to_string(date)
      date =
        date
        |> String.split("-")
        year = Enum.at(date, 0)
        month = Enum.at(date, 1)
        day = Enum.at(date, 2)
        month = case month do
          "01" ->
            "Jan"
          "02" ->
            "Feb"
          "03" ->
            "Mar"
          "04" ->
            "Apr"
          "05" ->
            "May"
          _ ->
            consult_valid_until1(month)
        end

        "#{day}-#{month}-#{year}"
    end
  end

  def consult_valid_until1(month) do
    case month do
      "06" ->
        "Jun"
      "07" ->
        "Jul"
      "08" ->
        "Aug"
      "09" ->
        "Sep"
      "10" ->
        "Oct"
      "11" ->
        "Nov"
      "12" ->
        "Dec"
    end
  end

  def convert_to_word(number) do
    if not is_nil(number) do
      number = Decimal.to_string(number)
      if number =~ "." do
        number =
          number
          |> String.split(".")

          first_num =
            number
            |> Enum.at(0)
            |> Decimal.new()
            |> Decimal.to_integer()
            |> NumberToWord.say()
            second_num =
              number
              |> Enum.at(1)
              |> Decimal.new()
              |> Decimal.to_integer()
              if second_num == 0 do
                String.capitalize("#{first_num} pesos only")
              else
                second_num = NumberToWord.say(second_num)
                String.capitalize("#{first_num} pesos and #{second_num} centavos only")
              end

      else

        integer = Decimal.to_integer(Decimal.new(number))
        if integer == 0 do
          "Zero pesos only"
        else
          number = integer |> NumberToWord.say()
          String.capitalize("#{number} pesos only")
        end
      end
    end
  end

  def display_complaint_and_diagnosis(loa) do
    diagnosis = for loa_diagnosis <- loa.loa_diagnosis do
      loa_diagnosis
    end
    if is_nil(diagnosis) || diagnosis == [] do
      ""
    else
      diagnosis =
        diagnosis
        |> List.first()
        "CHIEF COMPLAINT: #{loa.chief_complaint} / DIAGNOSIS: #{diagnosis.diagnosis_code} ( #{diagnosis.diagnosis_description} )"
    end
  end

  def add_member_payor_pays(member_pays, payor_pays) do
    member_pays = if is_nil(member_pays) || member_pays == "" do
      Decimal.new(0)
    else
      member_pays
    end
    payor_pays = if is_nil(payor_pays) || payor_pays == "" do
      Decimal.new(0)
    else
      payor_pays
    end
    Decimal.add(member_pays, payor_pays)
  end

  def check_validity(valid_until) do
    today = Date.utc()
    validity = Date.compare(valid_until, today)

    cond do
      validity == :gt ->
        true
      validity == :eq ->
        true
      true ->
        false
    end
  end

  def get_card_by_member_id(member_id) do
    if is_nil(member_id) do
      ""
    else
      MemberContext.get_card_by_member_id(member_id).number
    end
  end

  def loa_cart_consult_checker(loa_carts) do
    loa_ids =
      Enum.map(loa_carts, fn(loa_cart) ->
        loa_cart.id
      end)
    LoaContext.loa_batch_op_consult_checker(loa_ids)
  end

  # PEME
  def peme_format_member_name(loa) do
    if loa.member_suffix == "" or is_nil(loa.member_suffix) do
      "#{loa.member_last_name}, #{loa.member_first_name} #{loa.member_middle_name}"
    else
      "#{loa.member_last_name}, #{loa.member_first_name} #{loa.member_middle_name}, #{loa.member_suffix}"
    end
  end

  def peme_local_date do
    peme_local_date =
    ((:erlang.universaltime |> :calendar.datetime_to_gregorian_seconds))
    peme_local_date =
      peme_local_date
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!
  end

  def member_full_name_details(loa) do
    if Enum.all?([loa.member_first_name, loa.member_middle_name, loa.member_last_name], fn(x) -> x == nil end) do
      ""
    else
      "#{loa.member_first_name} #{loa.member_middle_name} #{loa.member_last_name}"
    end
  end

  def loa_payor(loa) do
    if is_nil(loa.payor), do: "", else: loa.payor.name
  end

  def loa_cart_payor(loas) do
    payors = Enum.map(loas, fn(l) ->
      if is_nil(l.payor) do
        ""
      else
        l.payor.name
      end
    end)
    |> Enum.uniq()
    |> Enum.join(", ")
  end

  def loa_cart_count(loas) do
    Enum.count(loas)
  end

  def loa_cart_amount(loas) do
    amounts = Enum.map(loas, fn(l) ->
      l.total_amount
    end)
    if not Enum.empty?(amounts) do
      amounts = Enum.reduce(amounts, fn(amount, acc) ->
        Decimal.add(amount, acc)
      end)
      Enum.join(["P", amounts], "")
    else
      Decimal.new(0)
    end
  end

  def loa_cart_coverage(loas) do
    coverages = Enum.map(loas, fn(l) ->
      l.coverage
    end)
    |> Enum.uniq()
    |> Enum.join(", ")
  end

  def get_total_amount(loas) do
    0
  end

  def get_loa_procedure_count(loa_package, loa_procedures) do
    procedures = Enum.map(loa_procedures, fn(lp) ->
      if lp.package_id == loa_package.id do
        Enum.join([lp.procedure_code, lp.procedure_description], "|")
      end
    end)

    procedures
    |> Enum.uniq()
    |> List.delete(nil)
    |> Enum.count
  end

  def get_loa_procedures_from_loa_package(loa_package, loa_procedures) do
    procedures = Enum.map(loa_procedures, fn(lp) ->
      if lp.package_id == loa_package.id do
        Enum.join([lp.procedure_code, lp.procedure_description], "|")
      end
    end)

    procedures =
      procedures
      |> Enum.uniq()
      |> List.delete(nil)

    Enum.join(procedures, "||")
  end

  def loa_pays(lp) do
    member_pays =
      if Decimal.to_float(Decimal.new(lp.loa_limit_amount)) == Decimal.to_float(Decimal.new(0)) do
        Decimal.new(0)
      else
        if Decimal.to_float(Decimal.new(lp.loa_limit_amount)) >
        Decimal.to_float(Decimal.new(lp.amount))
        do
          Decimal.new(0)
        else
          Decimal.sub(Decimal.new(lp.amount), Decimal.new(lp.loa_limit_amount))
        end
      end

    payor_pays =
      if Decimal.to_float(Decimal.new(lp.loa_limit_amount)) == Decimal.to_float(Decimal.new(0)) do
        Decimal.new(lp.amount)
      else
        if Decimal.to_float(Decimal.new(lp.loa_limit_amount)) >
        Decimal.to_float(Decimal.new(lp.amount))
        do
          Decimal.new(lp.amount)
        else
          Decimal.new(lp.loa_limit_amount)
        end
      end

    %{
      payor_pays: payor_pays,
      member_pays: member_pays,
      total_amount: lp.amount
    }
  end

  def format_new_date(date) when not is_nil(date) do
  date =
    date
    |> Ecto.Date.to_string()
    |> String.split("-")

    year = Enum.at(date, 0)
    month = Enum.at(date, 1)
    day = Enum.at(date, 2)

    month =
      case month do
        "01" ->
          "Jan"
        "02" ->
          "Feb"
        "03" ->
          "Mar"
        "04" ->
          "Apr"
        "05" ->
          "May"
        "06" ->
          "Jun"
        "07" ->
          "Jul"
        "08" ->
          "Aug"
        "09" ->
          "Sep"
        "10" ->
          "Oct"
        "11" ->
          "Nov"
        "12" ->
          "Dec"
      end

    "#{day}-#{month}-#{year}"
  end
  def format_new_date(date), do: ""

end
