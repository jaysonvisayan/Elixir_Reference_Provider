defmodule Data.Contexts.AcuScheduleContext do
  @moduledoc """
  """

  @module_name "Data.Contexts.AcuScheduleContext"

  import Ecto.{Query, Changeset}, warn: false
  alias Data.Repo
  alias Data.Parsers.{
    ProviderLinkParser,
    AcuScheduleParser
  }
  alias Data.Schemas.{
    AcuSchedule,
    AcuScheduleMember,
    AcuScheduleMemberUploadFile,
    AcuScheduleMemberUploadLog,
    AcuSchedulePackage,
    Member,
    LoaPackage,
    Loa,
    Claim,
    Batch,
    Payor,
    User
  }
  alias Data.Schemas.File, as: Fl
  alias Data.Contexts.{
    ProviderContext,
    UtilityContext,
    LoaContext,
    SchedulerContext,
    UserContext
  }
  alias Ecto.Changeset

  alias Elixlsx.Sheet
  alias Elixlsx.Workbook
  alias Decimal
  alias ProviderLink.{
    EmailSmtp,
    Mailer
  }

  # def list_acu_schedules do
  #   AcuSchedule
  #   |> Repo.all()
  # end

  def get_acu_schedule(id) do
    AcuSchedule
    |> Repo.get(id)
    |> Repo.preload([
      :provider,
      acu_schedule_members: {from(asm in AcuScheduleMember, order_by: [asc: :status]), [
        [
          loa: :loa_packages
        ],
        [
          member: :card
        ]
      ]}
    ])
  end

  def get_acu_schedule_by_payorlink_id(id) do
    AcuSchedule
    |> Repo.get_by(payorlink_acu_schedule_id: id)
    |> Repo.preload([
      acu_schedule_members: [[loa: :loa_packages], [member: :card]]
    ])
  end

  def get_acu_schedule_by_payorlink_id_2(id) do
    AcuSchedule
    |> Repo.get_by(payorlink_acu_schedule_id: id)
  end

  def insert_schedule(params) do
    provider = get_provider(params["facility_id"])
    if not is_nil(provider) do
      params = Map.put(params, "provider_id", provider.id)
      update_prescription_term(provider, params["prescription_term"])
    end

    params = Map.put(params, "acu_email_sent", false)

    %AcuSchedule{}
    |> AcuSchedule.changeset(params)
    |> Repo.insert()
  end

  defp update_prescription_term(provider, prescription_term) do
    provider
    |> Ecto.Changeset.change(%{
        prescription_term: prescription_term
      })
    |> Repo.update()
  end

  defp get_provider(facility_id) do
      ProviderContext.get_provider_by_payorlink_facility_id(facility_id)
    rescue
      _ ->
        nil
  end

  # Unused function
  def insert_or_update_schedule_package(params) do
    acu_schedule = get_acu_schedule_by_payorlink_id(params["id"])
    package = params["package"]
    asp = get_acu_package_by_pbp_id(params["benefit_package_id"])

    asp_params = %{
      payorlink_benefit_package_id: params["benefit_package_id"],
      code: package["code"],
      name: package["name"],
      description: package["description"],
      acu_schedule_id: acu_schedule.id
    }
    if is_nil(asp) do
      insert_schedule_package(asp_params)
    else
      update_schedule_package(asp, asp_params)
    end
  end

  def get_acu_package_by_pbp_id(id) do
    AcuSchedulePackage
    |> Repo.get_by(payorlink_benefit_package_id: id)
  end

  def insert_schedule_package(params) do
    %AcuSchedulePackage{}
    |> AcuSchedulePackage.changeset(params)
    |> Repo.insert()
  end

  def update_schedule_package(asp, params) do
    asp
    |> AcuSchedulePackage.changeset(params)
    |> Repo.update()
  end

  def insert_acu_member(params, acu_sched_id) do
    params = %{
      "acu_schedule_id" => acu_sched_id,
      "member_id" => params["member_id"]
    }
    insert_schedule_member(params)
  end

  def insert_acu_member(params) do
    # member = get_member_by_payorlink_id(params["member_id"])
    acu_schedule = get_as_payorlink(params["id"])
    # if not is_nil(member) and not is_nil(acu_schedule) do
    if not is_nil(acu_schedule) do
      params = %{
        "acu_schedule_id" => acu_schedule.id,
        "member_id" => params["member_id"]
      }
      insert_schedule_member(params)
    end
  end

  defp get_as_payorlink(id) do
      get_acu_schedule_by_payorlink_id(id)
    rescue
       _ ->
        nil
  end

  def insert_schedule_member(params) do
    %AcuScheduleMember{}
    |> AcuScheduleMember.changeset(params)
    |> Repo.insert()
  end

  def get_member_by_payorlink_id(p_id) do
    Repo.get_by(Member, payorlink_member_id: p_id)
  end

  # Unused function
  def get_acu_package_by_payorlink_id(p_id) do
    Repo.get_by(AcuSchedulePackage, payorlink_benefit_package_id: p_id)
  end

  def get_acu_schedule_member(id) do
    AcuScheduleMember
    |> Repo.get(id)
    |> Repo.preload([
      [loa: :loa_packages], [member: :card]
    ])
  end

  def update_encode_status(acu_schedule_member_ids) do
    AcuScheduleMember
    |> where([asm], asm.id in ^acu_schedule_member_ids)
    |> Repo.update_all(set: [status: "Encoded"])
    AcuScheduleMember
    |> where([asm], asm.id not in ^acu_schedule_member_ids)
    |> Repo.update_all(set: [status: nil])
  end

  def update_asm_loa_status(asm, param) do
    asm
    |> AcuScheduleMember.changeset(param)
    |> Repo.update()
  end

  def update_acu_schedule_status(acu_schedule, param) do
    acu_schedule
    |> AcuSchedule.changeset_status(param)
    |> Repo.update()
  end

  def update_acu_schedule_batch_id(acu_schedule, batch_id) do
    Repo.update(Ecto.Changeset.change acu_schedule, batch_id: batch_id)
  end

  def update_acu_schedule_est_total(acu_schedule, nil) do
    Repo.update(Ecto.Changeset.change acu_schedule, estimate_total_amount: Decimal.new(0))
  end

  def update_acu_schedule_est_total(acu_schedule, param) do
    Repo.update(Ecto.Changeset.change acu_schedule, estimate_total_amount: Decimal.new(param))
  end

  def update_acu_schedule_act_total(acu_schedule, guaranteed, actual) do
    Repo.update(Ecto.Changeset.change acu_schedule, actual_total_amount: actual)
  end
  # def update_acu_schedule_act_total(acu_schedule, guaranteed, actual), do: {:ok, acu_schedule}

  def update_acu_schedule_soa_no(acu_schedule, param) do
     changeset =
        acu_schedule
        |> Map.put(:soa_reference_no, param)
        |> validate_soa_ref_no

        if changeset do
          Repo.update(Ecto.Changeset.change acu_schedule, soa_reference_no: param)
        else
          {:error_soa, "SOA already in use"}
        end
    #  Repo.update(Ecto.Changeset.change changeset)s
  end

  defp validate_soa_ref_no(acu_schedule) do
    with true <- Map.has_key?(acu_schedule, :soa_reference_no) do
      soa_ref_no = acu_schedule.soa_reference_no

      if is_nil(check_soa_ref_no(soa_ref_no)) do
        true
      else
       false
      end
    else
      _ ->
        acu_schedule
    end

  end

  defp check_soa_ref_no(soa_ref_no) do
     AcuSchedule
     |> where([as], as.soa_reference_no ==^soa_ref_no)
    #  |> select([as], %{soa_no: as.soa_reference_no})
     |> Repo.one()
  end

  def get_acu_schedules(provider_id, account_code) do
    AcuSchedule
    |> where([as], as.provider_id == ^provider_id and as.account_code == ^account_code)
    |> Repo.all()
    |> Repo.preload([acu_schedule_members: :member])
  end

  def update_member_registration(acu_schedule_member) do
    acu_schedule_member
    |> AcuScheduleMember.changeset(%{is_registered: true})
    |> Repo.update()
  end

  def update_member_availment(acu_schedule_member) do
    acu_schedule_member
    |> AcuScheduleMember.changeset(%{is_availed: true})
    |> Repo.update()
  end

  def get_all_acu_schedule_by_provider(provider_id) do
    AcuSchedule
    |> where([as], as.provider_id == ^provider_id)
    |> order_by([as], desc: as.inserted_at)
    |> Repo.all()
    |> Repo.preload(:provider, [acu_schedule_members: [:acu_schedule_package, member: :card]])
  end

  def load_acu(id) do
    AcuSchedule
    |> Repo.get(id)
    |> Repo.preload([
      :provider,
      acu_schedule_members: [
        member: [
          loa: :loa_packages
        ],
        loa: [
          :loa_packages
        ]
      ]
    ])
  end

  def get_member_by_schedule_id(acu_schedule_id) do
    AcuScheduleMember
    |> where([asm], asm.acu_schedule_id == ^acu_schedule_id)
    |> Repo.all()
    |> Repo.preload([
      :loa,
      member: :card
    ])
  end

  def get_member_by_schedule_id2(acu_schedule_id) do
    Loa
    |> join(:inner, [l], asm in AcuScheduleMember, asm.loa_id == l.id)
    |> where([l, asm], asm.acu_schedule_id == ^acu_schedule_id)
    # |> where([l, asm], is_nil(asm.status))
    |> order_by([l, asm], asc: l.member_last_name)
    |> Repo.all()
  end

  def get_package_acu_schedule(acu_schedule) do
    acu_schedule.acu_schedule_members
    |> Enum.into([], fn(asm) ->
      if is_nil(asm.loa) do
        nil
      else
        loa_packages(asm.loa.loa_packages)
      end
    end)
    |> Enum.reject(&(is_nil(&1)))
    |> List.flatten()
    |> Enum.uniq()
  end

  defp loa_packages(data) do
    Enum.into(data, [], fn(lp) ->
      %{
        code: lp.code,
        description: lp.description,
        details: lp.details
      }
    end)
  end

  def get_acu_package_by_member_id(member_id) do
    Loa
    |> where([lm], lm.payorlink_member_id == ^member_id)
    |> Repo.all()
    |> Repo.preload(:loa_packages)
  end

  defp from_ecto_to_date(date) do
    date
    |> Ecto.Date.to_erl()
    |> Date.from_erl()
    |> elem(1)
  end

  defp remove_seconds(time) do
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

  def get_date_range(d1, d2, t1, t2) do
    d1 = from_ecto_to_date(d1)
    d2 = from_ecto_to_date(d2)
    t1 = remove_seconds(t1)
    t2 = remove_seconds(t2)

    date_diff = Date.diff(d2, d1)
    if date_diff != 0 do
      get_dates_for_acu([d1], d2, t1, t2, [])
    else
      day = Timex.weekday(d1)
      weekday = Timex.day_name(day)
      month = get_month_name(d1)
      year = get_year(d1)
      list = [["#{weekday}, #{month} #{year}; #{t1}-#{t2}"]]
    end
  end

  def get_dates_for_acu(date_list, date_to, t1, t2, days) do
    last_date =
      date_list
      |> List.last()

    first_date =
      date_list
      |> List.first()

    case Date.compare(date_to, last_date) do
      :eq ->
        day1 = Timex.weekday(first_date)
        weekday1 = Timex.day_name(day1)
        month1 = get_month_name(first_date)
        year1 = get_year(first_date)
        f_day = [["#{weekday1}, #{month1} #{year1}; #{t1}-#{t2}"]]
        list = f_day ++ days
      :gt ->
        new_date = Date.add(last_date, 1)
        day = Timex.weekday(new_date)
        weekday = Timex.day_name(day)
        list = date_list ++ [new_date]

        month = get_month_name(new_date)
        year = get_year(new_date)

        list2 = days ++ [["#{weekday}, #{month} #{year}; #{t1}-#{t2}"]]
        get_dates_for_acu(list, date_to, t1, t2, list2)
      _ ->
        day1 = Timex.weekday(first_date)
        weekday1 = Timex.day_name(day1)
        month1 = get_month_name(first_date)
        year1 = get_year(first_date)
        f_day = [["#{weekday1}, #{month1} #{year1}; #{t1}-#{t2}"]]
        list = f_day ++ days
    end
  end

  defp get_month_name(new_date) do
    month =
      new_date
      |> Date.to_string()
      |> String.split("-")
      |> List.delete_at(0)
      |> List.delete_at(1)
      |> Enum.join("")
      |> String.split("")

    if Enum.at(month, 0) == "0" do
      month =  List.delete_at(month, 0)
    end

    month
    |> Enum.join("")
    |> String.to_integer()
    |> Timex.month_name
  end

  defp get_year(new_date) do
    new_date
    |> Timex.format!("{0M}-{D}-{YYYY}")
    |> String.split("-")
    |> List.delete_at(0)
    |> Enum.join(", ")
  end

  defp border_design do
    left = [style: :thin, color: "#000000"]
    right = [style: :thin, color: "#000000"]
    top = [style: :thin, color: "#000000"]
    bottom = [style: :thin, color: "#000000"]

    [left: left, right: right, top: top, bottom: bottom]
  end

  defp current_time(date_now) do
    date_now
    |> DateTime.to_time()
    |> Time.to_erl()
    |> Ecto.Time.from_erl()
  end

  defp export_packages(package) do
    package
    |> Enum.map(fn(package) ->
      [
       [package.code, border: border_design, align_vertical: :center, size: 10, font: "Liberation Sans"],
       [package.description, border: border_design, align_vertical: :center, size: 10, font: "Liberation Sans"],
       [package.details, border: border_design, size: 10, font: "Liberation Sans"]
     ]
   end)
 end

 defp export_date_schedule(id, date_ranges) do
  record = load_acu(id)
   for {value, index} <- Enum.with_index(date_ranges) do
     if index == 0 do
       Enum.concat(value, ["", "#{record.no_of_guaranteed}"])
     else
       Enum.concat(value, ["", ""])
     end
   end
 end

  def export_member([] , nil), do: []
  def export_member([] , status), do: []
  def export_member(members,nil) do
    members
    |> Enum.map(fn(loa) ->
      if not is_nil(loa) do
        md =
          if not is_nil(loa.member_middle_name) do
            m =
              loa.member_middle_name
              |> String.split("", trim: true)
              |> List.first()
              |> String.upcase()

              "#{m}."
          else
            ""
          end

          member_loa =  export_member_loa(loa.payorlink_member_id)

          member_package =
            if is_nil(member_loa) do
              %{
                code: "N/a"
              }
            else
              member_loa.loa_packages
              |> List.first()
            end

            member_name =
              if Enum.all?([loa.member_last_name, loa.member_first_name], fn(x) -> x == nil end) do
                nil
              else
                "#{loa.member_last_name}, #{loa.member_first_name}"
              end

              member_birth_date =
                if is_nil(loa.member_birth_date) do
                  nil
                else
                  Timex.format!(loa.member_birth_date, "{0M}-{D}-{YYYY}")
                end

                member_age =
                  if is_nil(loa.member_birth_date) do
                    nil
                  else
                    Integer.to_string(get_age(loa.member_birth_date))
                  end

                  [
                    [loa.member_card_no, border: border_design],
                    [Enum.join([member_name, md], " "),
                     border: border_design],
                    [loa.member_gender, border: border_design],
                    [member_birth_date, border: border_design],
                    [member_age, border: border_design],
                    [member_package.code, border: border_design],
                    ["", border: border_design]
                  ]
      else
      nil
      end
    end)
    |> Enum.reject(&(is_nil(&1)))
  end

  def export_member(members,status) do
    members
    |> Enum.map(fn(loa) ->
      if not is_nil(loa) do
          md =
              if not is_nil(loa.member_middle_name) do
                m =
                loa.member_middle_name
                  |> String.split("", trim: true)
                  |> List.first()
                  |> String.upcase()

                  "#{m}."
              else
                ""
              end

              member_loa =  export_member_loa(loa.payorlink_member_id)

              member_package =
                if is_nil(member_loa) do
                  %{
                    code: "N/a"
                  }
                else
                  member_loa.loa_packages
                  |> List.first()
                end

              member_name =
                  if Enum.all?([loa.member_last_name, loa.member_first_name], fn(x) -> x == nil end) do
                    nil
                  else
                    "#{loa.member_last_name}, #{loa.member_first_name}"
                  end

              member_birth_date =
                  if is_nil(loa.member_birth_date) do
                    nil
                  else
                    Timex.format!(loa.member_birth_date, "{0M}-{D}-{YYYY}")
                  end

              member_age =
                  if is_nil(loa.member_birth_date) do
                     nil
                  else
                      Integer.to_string(get_age(loa.member_birth_date))
                  end

              member_package_amount =
                if is_nil(loa.total_amount) do
                    " "
                 else
                    Decimal.to_string(loa.total_amount)
                 end

              [
                [loa.member_card_no, border: border_design],
                [Enum.join([member_name, md], " "),
                  border: border_design],
                [loa.member_gender, border: border_design],
                [member_birth_date, border: border_design],
                [member_age, border: border_design],
                [member_package.code, border: border_design],
                [member_package.description, border: border_design],
                [member_package_amount, border: border_design],
                ["", border: border_design],
                [loa.status, border: border_design]
              ]
        else
          nil
        end
    end)
    |> Enum.reject(&(is_nil(&1)))
  end

 def export_member_loa(nil), do: nil
 def export_member_loa(id) do
   id
   |> get_acu_package_by_member_id()
   |> List.first()
 end

 defp export_loc(id) do
   record = load_acu(id)
   loc =
     Enum.join([
       record.provider.line_1,
       record.provider.line_2,
       record.provider.city
     ], " ")

   loc2 =
     Enum.join([
       record.provider.province,
       record.provider.region,
       record.provider.postal_code,
       record.provider.country
     ], " ")

   location =
     %{
       loc: loc,
       loc2: loc2
     }
 end

 def sheet1(id, datetime) do
    record = load_acu(id)
    date_now = DateTime.utc_now()
    account_address = if is_nil(record.account_address), do: "", else: record.account_address
    time_from = if is_nil(record.time_from), do: current_time(date_now), else: record.time_from
    time_to = if is_nil(record.time_to), do: current_time(date_now), else: record.time_to
    date_ranges = get_date_range(record.date_from, record.date_to, time_from, time_to)
    package = get_package_acu_schedule(record)
    location = export_loc(id)

    sheet1 =
     %Sheet{
       name: "Batch Details",
       rows: [
         [["Batch No.", bold: true, size: 10, font: "Liberation Sans"]],
         [Integer.to_string(record.batch_no)],
         [],
         [
           ["Facility Code/Name", bold: true, size: 10, font: "Liberation Sans"],
           "",
           ["Facility Address", bold: true, size: 10, font: "Liberation Sans"]
         ],
         ["#{record.provider.code} / #{record.provider.name}", "", "#{location.loc}"],
         ["", "", "#{location.loc2}"],
         [],
         [
           ["Account Code/Name", bold: true, size: 10, font: "Liberation Sans"],
           "",
           ["Account Address", bold: true, size: 10, font: "Liberation Sans"]
         ],
         ["#{record.account_code} / #{record.account_name}", "", "#{account_address}"],
         []]
         ++ [[
           ["ACU Date(From/To;Duration/Time)", bold: true, size: 10, font: "Liberation Sans"],
           "",
           ["No. of guaranteed heads", bold: true, size: 10, font: "Liberation Sans"]
         ],
         ] ++ export_date_schedule(id, date_ranges) ++ [[]] ++ [[
           ["Schedule Created By", bold: true, size: 10, font: "Liberation Sans"],
           "",
           ["Date and Time of Masterlist Generation", bold: true, size: 10, font: "Liberation Sans"]
         ],
          ["#{record.created_by}", "", datetime],
          [],
          ["Legend:"],
          [
          ["Package Code", border: border_design, bold: true, size: 10, font: "Liberation Sans"],
          ["Package Name", border: border_design, bold: true, size: 10, font: "Liberation Sans"],
          ["Package Details", border: border_design, bold: true, size: 10, font: "Liberation Sans"]]
         ] ++ export_packages(package),
         merge_cells: [
           {"A5", "B5"},
           {"C5", "G5"},
           {"C8", "G8"},
           {"C9", "G9"},
           {"A4", "B4"},
           {"A10", "B10"}
         ]
     }
     |> Sheet.set_col_width("C", 24.0)
     |> Sheet.set_col_width("A", 14.0)
     |> Sheet.set_col_width("B", 12.0)
 end

 def acu_schedule_export(id, datetime) do
   record = load_acu(id)
   status = record.status
   date_now = DateTime.utc_now()
   filename = "#{record.batch_no}-#{record.account_code}-#{DateTime.to_date(date_now)}GenInfo.xlsx"
   workbook = %Workbook{sheets: [sheet1(id, datetime)]}
   workbook =
     workbook
     |> Elixlsx.write_to_memory(filename)
 end

  def get_age(date) do
    year_of_date = to_string(date)
    year_today =  Date.utc_today
    year_today = to_string(year_today)
    datediff1 = Timex.parse!(year_of_date, "%Y-%m-%d", :strftime)
    datediff2 = Timex.parse!(year_today, "%Y-%m-%d", :strftime)
    diff_in_years = Timex.diff(datediff2, datediff1, :years)
    diff_in_years
  end

  def update_payorlink_loa_status(conn, acu_schedule, params) do
    url = "loa/batch/acu_schedule/update_otp_status"
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        with {:ok, response} <- UtilityContext.connect_to_api_put_with_token(token, url, params,  "Maxicar") do
          update_acu_schedule_status(acu_schedule, %{status: "Submitted"})
        else
          {:error, response} ->
            {:error, response}
          _ ->
          {:unable_to_login}
        end
      _ ->
        {:unable_to_login}
    end
  end

  def update_payorlink_loa_status_v2(conn, acu_schedule, params) do
    url = "loa/batch/acu_schedule/update_otp_status_v2"
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        with {:ok, response} <- UtilityContext.connect_to_api_put_with_token(token, url, params,  "Maxicar") do
          update_acu_schedule_status(acu_schedule, %{status: "Submitted"})
        else
          {:error, response} ->
            {:error, response}
          _ ->
          {:unable_to_login}
        end
      _ ->
        {:unable_to_login}
    end
  end

  def update_payorlink_loa_status_and_create_claims(conn, acu_schedule, params) do
    url = "acu_schedule/batch/update_loa_status_and_create_claim"
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        with {:ok, response} <- UtilityContext.connect_to_api_put_with_token(token, url, params,  "Maxicar") do
          update_acu_schedule_status(acu_schedule, %{status: "Submitted"})
        else
          {:error, response} ->
            {:error, response}
          _ ->
          {:unable_to_login}
        end
      _ ->
        {:unable_to_login}
    end
  end

  def get_all_acu_schedule_by_provider_id(provider_id) do
    AcuSchedule
    |> join(:left, [as], asm in AcuScheduleMember, asm.acu_schedule_id == as.id)
    |> where([as, asm], as.provider_id == ^provider_id and as.hidden_from_mobile == false)
    |> select([as, asm], %{
        id: as.id,
        inserted_at: as.inserted_at,
        batch_no: as.batch_no,
        account_code: as.account_code,
        account_name: as.account_name,
        account_address: as.account_address,
        date_from: as.date_from,
        date_to: as.date_to,
        status: as.status,
        member_count: count(asm.id)
      })
    |> order_by([as, asm], desc: as.inserted_at)
    |> group_by([as, asm], as.id)
    |> Repo.all()
  end

  def get_all_acu_schedule_by_account_code(account_code, provider_id) do
    AcuSchedule
    |> where([as], as.provider_id == ^provider_id and as.account_code == ^account_code)
    |> Repo.all()
    |> Repo.preload([
      [acu_schedule_members: [acu_schedule: :provider, loa: :loa_packages, member: :card]]
    ])
  end

  def get_schedule_by_batch_no(batch_no) do
    as =  AcuSchedule
          |> where([as], as.batch_no == ^batch_no)
          |> Repo.all()
    # as = Repo.get_by(AcuSchedule, batch_no: batch_no)

    if Enum.empty?(as) do
      {:error, nil}
    else
      if Enum.count(as) > 1 do
        {:error, nil}
      else
        as = as
             |> List.first()
             |> Repo.preload([
               [acu_schedule_members: [acu_schedule: :provider, loa: :loa_packages, member: :card]]
             ])

        asm_loas = Enum.map(as.acu_schedule_members, fn(asm) ->
          asm.loa
        end)
        if Enum.all?(asm_loas) do
          as
        else
          {:error, nil}
        end
      end
    end
    # if is_nil(as) do
    #   {:error, nil}
    # else
    #   Repo.preload(as, [
    #     [acu_schedule_members: [acu_schedule: :provider, loa: :loa_packages, member: :card]]
    #   ])
    # end
  end

  def get_schedule_by_batch_no2(batch_no) do
    as =  AcuSchedule
          |> where([as], as.batch_no == ^batch_no)
          |> where([as], as.status != "Stale" or is_nil(as.status))
          |> Repo.all()

    if Enum.empty?(as) do
      {:error, nil}
    else
      if Enum.count(as) > 1 do
        {:error, nil}
      else
        as = as
             |> List.first()
             |> Repo.preload([
               [acu_schedule_members: [acu_schedule: :provider, loa: :loa_packages, member: :card]]
             ])

        direct_cost = if is_nil(as.soa_reference_no) do
                ""
        else
               get_soa_amount_by_soa_ref_no(as.soa_reference_no)
        end

         as =
            as
            |> Map.put(:soa_amount, direct_cost)

        asm_loas = Enum.map(as.acu_schedule_members, fn(asm) ->
          asm.loa
        end)
        if Enum.all?(asm_loas) do
          as
        else
          {:error, nil}
        end
      end
    end
  end

  def get_schedule_by_batch_no3(batch_no) do
    with [as] <- get_acu_sched_not_stale_by_batch_no(batch_no),
         as <- preload_acu_sched_details(as),
         {:ok, direct_cost} <- get_direct_cost(as.soa_reference_no),
         false <- check_loa_as_members(as.acu_schedule_members)
    do
      Map.put(as, :soa_amount, direct_cost)
    else
      _ ->
        {:error, nil}
    end
  end

  defp check_loa_as_members(acu_sched_member) do
    acu_sched_member
    |> Enum.any?(&(is_nil(&1.loa)))
  end

  defp get_acu_sched_not_stale_by_batch_no(batch_no) do
    AcuSchedule
    |> where([as], as.batch_no == ^batch_no)
    |> where([as], as.status != "Stale" or is_nil(as.status))
    |> Repo.all()
  end

  defp preload_acu_sched_details(as) do
    as
    |> Repo.preload([
      [acu_schedule_members: [acu_schedule: :provider, loa: :loa_packages, member: :card]]
    ])
  end

  defp get_direct_cost(nil), do: {:ok , ""}
  defp get_direct_cost(soa_reference_no) do
    get_soa_amount_by_soa_ref_no(soa_reference_no)
  end

  defp get_soa_amount_by_soa_ref_no(nil), do: {:ok, ""}
  defp get_soa_amount_by_soa_ref_no(soa_ref_no) do
    soa_amnt =
      Batch
      |> where([b], b.soa_reference_no == ^soa_ref_no)
      |> select([b], %{id: b.id, soa_amount: b.soa_amount})
      |> Repo.all()
    if Enum.count(soa_amnt) > 1 do
      {:error, nil}
    else
      if soa_amnt != [], do: {:ok, List.first(soa_amnt).soa_amount}, else: {:ok, ""}
    end
  end

  def update_availed_acu_schedule(conn, as, asm, params, is_recognized) do
    image = params.image
    asm = Repo.preload(asm, :loa)
    # if as.status == "Submitted" do
    #   if asm.loa.status == "Approved" do
    #     if image["base_64_encoded"] == "" or is_nil(image["base_64_encoded"]) do
    #       send_to_api(conn, as, asm, image, params)
    #       Repo.update(Changeset.change asm, status: "Encoded", is_recognized: is_recognized, is_registered: true, is_availed: true)
    #     else
    #       send_to_api(conn, as, asm, image, params)
    #       ProviderLinkParser.upload_image(asm, image)
    #       Repo.update(Changeset.change asm, status: "Encoded", is_recognized: is_recognized, is_registered: true, is_availed: true)
    #     end
    #   else
    #     {:ok, asm}
    #   end
    # else
      if image["base_64_encoded"] == "" or is_nil(image["base_64_encoded"]) do
        send_to_api(conn, as, asm, image, params)
        Repo.update(Changeset.change asm, status: "Encoded", is_recognized: is_recognized, is_registered: true, is_availed: true)
      else
        send_to_api(conn, as, asm, image, params)
        Repo.update(Changeset.change asm, status: "Encoded", is_recognized: is_recognized, is_registered: true, is_availed: true)
        ProviderLinkParser.upload_image(asm, image)
        asm = get_acu_schedule_member(asm.id)
        {:ok, asm}
      end
    # end
  end

  def update_forfeited_acu_schedule(conn, as, asm, image, is_recognized) do
    asm = Repo.preload(asm, :loa)
    if as.status == "Submitted" do
      if asm.loa.status == "Pending" do
        params = %{
          verified_ids: [],
          forfeited_ids: [asm.loa.payorlink_authorization_id]
        }
        Repo.update(Changeset.change asm, is_recognized: is_recognized, is_registered: true, is_availed: true)
        update_payorlink_loa_status(conn, as, params)
      end
    else
      if image["base_64_encoded"] == "" or is_nil(image["base_64_encoded"]) do
        params = %{
          member_id: asm.loa.payorlink_member_id,
          verified_ids: [],
          forfeited_ids: [asm.loa.payorlink_authorization_id]
        }
        update_payorlink_loa_status(conn, as, params)
        Repo.update(Changeset.change asm, is_recognized: is_recognized, is_registered: true, is_availed: true)
      else
        photo_file = %{
          "file_name" => image["file_name"],
          "base_64_encoded" => image["base_64_encoded"],
          "content_type" => "#{image["type"]}/#{image["extension"]}",
          "extension" => image["extension"]
        }

        params = %{
          member_id: asm.loa.payorlink_member_id,
          verified_ids: [],
          forfeited_ids: [asm.loa.payorlink_authorization_id],
          photo_file: photo_file
        }
        update_payorlink_loa_status(conn, as, params)
        Repo.update(Changeset.change asm, is_recognized: is_recognized, is_registered: true, is_availed: true)
      end
    end
  end

  def send_to_api(conn, as, asm, image, params) do
    if image["base_64_encoded"] == "" or is_nil(image["base_64_encoded"]) do
      params = Map.merge(params, %{
        member_id: asm.loa.payorlink_member_id,
        verified_ids: [asm.loa.payorlink_authorization_id],
        forfeited_ids: []
      })

      update_payorlink_loa_status_v2(conn, as, params)
    else
      photo_file = %{
        "file_name" => image["file_name"],
        "base_64_encoded" => image["base_64_encoded"],
        "content_type" => "#{image["type"]}/#{image["extension"]}",
        "extension" => image["extension"]
      }

      params = Map.merge(params, %{
        member_id: asm.loa.payorlink_member_id,
        verified_ids: [asm.loa.payorlink_authorization_id],
        forfeited_ids: [],
        file: photo_file
      })

      update_payorlink_loa_status_v2(conn, as, params)
    end
  end

  def get_acu_schedule_by_batch_no(batch_no) do
    batch_no = String.to_integer("#{batch_no}")
    AcuSchedule
    |> Repo.get_by(batch_no: batch_no)
    |> Repo.preload([
      [acu_schedule_members: [loa: :loa_packages]]
    ])

    rescue
    ArgumentError ->
      {:batch_no_invalid_type}
  end

  def attach_soa(params) do
    with acu_schedule = %AcuSchedule{} <- get_acu_schedule_by_batch_no(params["batch_no"]),
         {:ok, "uploads"} <- validate_uploads(params["uploads"]),
         {:ok, "soa_ref_no"} <- validate_update_soa_ref_no(params["soa_reference_no"])
    do
      update_acu_schedule_soa_ref_no(acu_schedule, params["soa_reference_no"])
      ProviderLinkParser.upload_a_file_acu_schedule(acu_schedule.id, params["uploads"])
      acu_schedule = get_acu_schedule_by_batch_no(params["batch_no"])
      {:ok, acu_schedule}
    else
      {:batch_no_invalid_type} ->
        {:batch_no_invalid_type}
      {:error, "nil_srn"} ->
         {:error_nil_srn}
      {:error, "soa_ref_no"} ->
         {:error_soa_ref_no}
      {:error_upload_params} ->
        {:error_upload_params}
      {:error_base_64} ->
        {:error_base_64}
      {:error, changeset} ->
        {:error, changeset}
      nil ->
        {:acu_schedule_not_found}
      _ ->
        {:server_error}
    end
  end

  def update_acu_schedule_soa_ref_no(acu_schedule, soa_ref_no) do
    Repo.update(Changeset.change acu_schedule, soa_reference_no: soa_ref_no)
  end


  def validate_update_soa_ref_no(soa_ref_no) when is_nil(soa_ref_no) or soa_ref_no == "",
  do: {:error, "nil_srn"}
  def validate_update_soa_ref_no(soa_ref_no) do
    as =
      AcuSchedule
      |> where([a], a.soa_reference_no == ^soa_ref_no)
      |> Repo.all()
      |> Enum.count()

    batch =
      Batch
      |> where([b], b.soa_reference_no == ^soa_ref_no)
      |> Repo.all()
      |> Enum.count()

    if as > 0 or batch > 0, do: {:error, "soa_ref_no"}, else: {:ok, "soa_ref_no"}
  end

  def validate_uploads(datas) do
    if datas == [] or is_nil(datas) do
      {:error_upload_params}
    else
      data = for data <- datas do
        with {:ok, "upload"} <- validate_upload(data),
             {:ok, data} <- Base.decode64(data["base_64_encoded"])
        do
          "ok"
        else
          {:error, "upload"} ->
            "error_upload"
          :error ->
            "error_base_64"
        end
      end
      cond do
        Enum.member?(data, "error_upload") ->
          {:error_upload_params}
        Enum.member?(data, "error_base_64") ->
          {:error_base_64}
        true ->
          {:ok, "uploads"}
      end
    end
  end

  def validate_upload(params) do
    types = %{
      base_64_encoded: :string,
      extension: :string,
      name: :string
    }

    changeset =
      {%{}, types}
      |> Ecto.Changeset.cast(params, Map.keys(types))
      |> Ecto.Changeset.validate_required([
        :base_64_encoded,
        :extension,
        :name
      ], message: "is required")

    if changeset.valid? do
      {:ok, "upload"}
    else
      {:error, "upload"}
    end
  end

  def get_acu_schedule_member_by_acu_schedule_id(acu_schedule_id) do
    AcuScheduleMember
    |> Repo.get_by(acu_schedule_id: acu_schedule_id)
    |> Repo.preload([
      [loa: :loa_packages], [member: :card]
    ])
  end

  def get_acu_schedule_member_by_loa_id(loa_id) do
    AcuScheduleMember
    |> Repo.get_by(loa_id: loa_id)
    |> Repo.preload([
      [loa: :loa_packages], [member: :card]
    ])
  end

  def create_acu_schedule_file(params) do
    {:ok, file} = %Fl{}
    |> Fl.changeset_acu_schedule(params)
    |> Repo.insert()

    file
    |> Fl.changeset_file(params)
    |> Repo.update()
  end

  def get_file_by_acu_schedule(acu_schedule_id) do
    Fl
    |> where([f], f.acu_schedule_id == ^acu_schedule_id)
    |> Repo.all()
  end

  def get_file_count_by_acu_schedule(acu_schedule_id) do
    count = Fl
    |> where([f], f.acu_schedule_id == ^acu_schedule_id)
    |> Repo.all()
    |> Enum.count()

    if count > 0 do
      true
    else
      false
    end
  end

  def view_soa(params) do
    with acu_schedule = %AcuSchedule{} <- get_acu_schedule_by_batch_no(params["batch_no"]),
        true <- get_file_count_by_acu_schedule(acu_schedule.id)
    do
      files = get_file_by_acu_schedule(acu_schedule.id)
      ProviderLinkParser.view_files(files, acu_schedule)
    else
      {:error, changeset} ->
        {:error, changeset}
      {:error, message} ->
        {:error, message}
      nil ->
        {:acu_schedule_not_found}
      false ->
        {:no_files_found}
      _ ->
        {:error}
    end
  end

  def acu_schedule_date_checker(acu_schedule) do
    acu_date = Ecto.Date.compare(acu_schedule.date_to, utc_now())
    case acu_date do
      :lt ->
        {:valid_date}
      :gt ->
        {:error_date}
      :eq ->
        {:valid_date}
    end
  end

  defp utc_now do
    "Asia/Singapore"
    |> Timex.now()
    |> Timex.to_date()
    |> Ecto.Date.cast!()
  end

  def update_schedule_status(schedule, status) do
    schedule
    |> Changeset.change(%{status: status})
    |> Repo.update()
  end

  def update_selected_members(acu_schedule, selected_members, nil) do
    Repo.update(Changeset.change acu_schedule, no_of_selected_members: selected_members)
  end

  def update_selected_members(acu_schedule, selected_members, number), do: {:ok, acu_schedule}

  def total_amount(acu_schedule_id) do
    Loa
    |> join(:inner, [l], asm in AcuScheduleMember, l.id == asm.loa_id)
    |> join(:inner, [l, asm], as in AcuSchedule, asm.acu_schedule_id == as.id)
    |> where([l, asm, as], as.id == ^acu_schedule_id and asm.status == "Encoded")
    |> select([l, asm, as], l.total_amount)
    |> Repo.all()
  end

  def compute_total([]), do: Decimal.new(0)
  def compute_total(amounts), do: Enum.reduce(amounts, fn(x, acc) -> Decimal.add(x, acc) end)

  def verify_facial_biometrics(conn,  asm, image) do
    case UtilityContext.request_to_api_post(conn, "biometricsAPI", "Face/DetectFace",
        %{"ImageBase64String": image["base_64_encoded"],
          "MinimumRatio": Decimal.new(0.1),
          "MaximumRatio": Decimal.new(1.1),
        })
    do
      {:ok, response} ->
        case response.body do
          "\"Internal server error\"" ->
            {:internal}
          _ ->
            biometrics_return(conn, asm, response.body, image["base_64_encoded"])
        end
      {:error_connecting_api} ->
        {:error}
      {:unable_to_login} ->
        {:unable_to_login}
      {:biometrics_does_not_exists} ->
        {:biometrics_does_not_exists}
    end
  end

  defp biometrics_return(conn, asm, response_body, base64_image) do
    decoded = Poison.decode!(response_body)
    if decoded["error"]["message"] == "Member not found!" do
      false
    else
      if decoded["IsValid"] do
        add_image_to_rekognize(conn, asm, response_body, base64_image)
        true
      else
        false
      end
    end
  end

  def add_image_to_rekognize(conn, asm, response_body, image) do
    case UtilityContext.request_to_api_post(conn, "rekognizeAPI", "persons/add",
        %{
          "image": image,
          "person_id": asm.loa.payorlink_member_id,
          "first_name": asm.loa.member_first_name,
          "last_name": asm.loa.member_last_name
        })
    do
      {:ok, response} ->
        case response.body do
          "\"Internal server error\"" ->
            {:internal}
          _ ->
            rekognize_return(conn, response.body)
        end
      {:error_connecting_api} ->
        {:error}
      {:unable_to_login} ->
        {:unable_to_login}
      {:rekognize_does_not_exists} ->
        {:rekognize_does_not_exists}
    end
  end

  defp rekognize_return(conn, response_body) do
    decoded = Poison.decode!(response_body)
    if decoded["error"]["message"] == "Error" do
      false
    else
      decoded["success"]
    end
  end

  def add_image_to_rekognize(conn, asm, response_body, nil), do: false

  def create_claim(nil, params), do: false

  def create_claim(user, params) do
    claims = Enum.map(params["claims"], fn(x) ->
      approved_datetime = if is_nil(x["approved_datetime"]), do: nil, else: Ecto.DateTime.cast!(x["approved_datetime"])
      valid_until = if is_nil(x["valid_until"]), do: nil, else: Ecto.Date.cast!(x["valid_until"])
      discharge_datetime = if is_nil(x["discharge_datetime"]), do: nil, else: Ecto.DateTime.cast!(x["discharge_datetime"])
      admission_datetime = if is_nil(x["admission_datetime"]), do: nil, else: Ecto.DateTime.cast!(x["admission_datetime"])

      loa = LoaContext.get_loa_by_payorlink_id(x["loa_id"])
      %{
        loa_id: loa.id,
        number: x["number"],
        is_claimed?: x["is_claimed?"],
        approved_datetime: approved_datetime,
        step: x["step"],
        valid_until: valid_until,
        migrated: x["migrated"],
        origin: x["origin"],
        admission_datetime: admission_datetime,
        discharge_datetime: discharge_datetime,
        status: x["status"],
        version: x["version"],
        transaction_no: x["transaction_no"],
        batch_no: x["batch_no"],
        payorlink_claim_id: x["payorlink_claim_id"],
        created_by_id: user.id,
        updated_by_id: user.id,
        inserted_at: Ecto.DateTime.utc(),
        updated_at: Ecto.DateTime.utc(),
        package: x["package"],
        diagnosis: x["diagnosis"],
        procedure: x["procedure"]
      }
    end)

    claims_count =
      claims
      |> Enum.count()

    if claims_count >= 2000 do
     lists =
      claims
      |> partition_list(1999, [])

      Enum.map(lists, fn(x) ->
        Claim
        |> Repo.insert_all(x)
      end)
    else
      Claim
      |> Repo.insert_all(claims)
    end
  end

  defp partition_list([], limit, result), do: result
  defp partition_list(list, limit, result) do

    temp = Enum.slice(list, 0..limit)
    result = result ++ [temp]
    temp_result = list -- temp

    partition_list(temp_result, limit, result)
  end

  defp validate_file_name(id, filename) do
    cond do
      String.ends_with?(filename, ["csv"]) == false ->
        {:invalid, "Only .csv file format must be accepted."}
      Enum.count(String.split(filename, "-")) != 5 ->
        {:invalid, "The filename of the document you selected is invalid."}
      true ->
        validate_file_name_format(id, filename)
    end
  end

  defp validate_file_name_format(id, filename) do
    [a, b, c, d, e] = String.split(filename, "-")
    as = get_acu_schedule_upload(id)
    cond do
      a != "#{as.batch_no}" ->
        {:invalid, "The filename of the document you selected is invalid."}
      b != "#{as.account_code}" ->
        {:invalid, "The filename of the document you selected is invalid."}
      true ->
        {:valid}
    end
  end

  def upload_member(params, user_id) do
    with {:valid} <- validate_file_name(params["id"], params["file"].filename) do
      data =
        params["file"].path
        |> File.stream!()
        |> CSV.decode(headers: true)

        keys = [
          "Card Number", "Availed ACU? (Y or N)"
        ]
        with {:ok, map} <- Enum.at(data, 0),
             {:equal} <- column_checker(keys, map)
        do
          AcuScheduleParser.parse_data(
            data,
            params["file"].filename,
            params["id"],
            user_id
          )
        else
          nil ->
            {:not_found}
          {:not_equal} ->
            {:not_equal}
          {:not_equal, columns} ->
            {:not_equal, columns}
           _ ->
            {:invalid, "File content is invalid."}
        end
    else
      {:invalid, message} ->
        {:invalid, message}
      _ ->
        {:invalid, "The filename of the document you selected is invalid."}
    end
  end

  defp column_checker(keys, map) do
    cond do
      is_nil(map["Card Number"]) and is_nil(map["Availed ACU? (Y or N)"]) ->
        {:not_equal, "Card Number and Availed ACU? (Y or N)"}
      is_nil(map["Card Number"]) ->
        {:not_equal, "Card Number"}
      is_nil(map["Availed ACU? (Y or N)"]) ->
        {:not_equal, "Availed ACU? (Y or N)"}
      true ->
        {:equal}
    end
  end

  def update_encode_card_nos(acu_schedule_id, card_nos) do
    acu_schedule_member_ids =
      Enum.map(card_nos, fn(card_no) ->
        Loa
        |> join(:inner, [l], asm in AcuScheduleMember, asm.loa_id == l.id and asm.acu_schedule_id == ^acu_schedule_id)
        |> where([l, asm], l.member_card_no == ^card_no and fragment("lower(?)", l.status) == "approved")
        |> select([l, asm], asm.id)
        |> Repo.one()
      end)

    update_encode_status_upload(acu_schedule_id, acu_schedule_member_ids)
  end

  defp update_encode_status_upload(acu_schedule_id, acu_schedule_member_ids) do
  {encoded, _} =
    AcuScheduleMember
    |> where([asm], asm.id in ^acu_schedule_member_ids and asm.acu_schedule_id == ^acu_schedule_id)
    |> Repo.update_all(set: [status: "Encoded"])

    AcuScheduleMember
    |> where([asm], asm.id not in ^acu_schedule_member_ids and asm.acu_schedule_id == ^acu_schedule_id)
    |> Repo.update_all(set: [status: nil])

  all =
    AcuScheduleMember
    |> where([asm], asm.acu_schedule_id == ^acu_schedule_id)
    |> select([asm], count(asm.id))
    |> Repo.one()

    {:ok, encoded, all}

  end

  def create_asm_upload_file(attrs) do
    %AcuScheduleMemberUploadFile{}
    |> AcuScheduleMemberUploadFile.changeset(attrs)
    |> Repo.insert()
  end

  def create_asm_upload_log(attrs) do
    %AcuScheduleMemberUploadLog{}
    |> AcuScheduleMemberUploadLog.changeset(attrs)
    |> Repo.insert()
  end

  def get_asm_upload_files(acu_schedule_id) do
    AcuScheduleMemberUploadFile
    |> join(:inner, [asmuf], asmul in AcuScheduleMemberUploadLog,
            asmul.acu_schedule_member_upload_file_id == asmuf.id)
    |> where([asmuf, asmul], asmuf.acu_schedule_id == ^acu_schedule_id)
    |> order_by([asmuf, asmul], desc: asmul.inserted_at)
    |> Repo.all()
  end

  def get_asm_batch_file(asm_upload_file_id) do
    member =
      AcuScheduleMemberUploadFile
      |> join(:inner, [asmuf], asmul in AcuScheduleMemberUploadLog,
            asmul.acu_schedule_member_upload_file_id == asmuf.id)
      |> where([asmuf, asmul], asmuf.id == ^asm_upload_file_id)
      |> order_by([asmuf, asmul], desc: asmul.inserted_at)

    member
    |> select([asmuf, asmul], [
      asmul.card_no,
      asmul.full_name,
      asmul.gender,
      asmul.birthdate,
      asmul.age,
      asmul.package_code,
      asmul.signature,
      asmul.availed,
      asmul.remarks
    ])
    |> Repo.all()
  end

  def get_loa_by_as_card_no(acu_schedule_id, card_no) do
    Loa
    |> join(:inner, [l], asm in AcuScheduleMember, asm.loa_id == l.id and asm.acu_schedule_id == ^acu_schedule_id)
    |> where([l, asm], l.member_card_no == ^card_no)
    |> Repo.one()
  end

  def get_acu_schedule_upload(id) do
    AcuSchedule
    |> where([as], as.id == ^id)
    |> select([as], %{batch_no: as.batch_no, account_code: as.account_code})
    |> Repo.one()
  end

  def emailer do
    url_host =  Repo.get_by(Payor, name: "Providerlink")
    api_address = Repo.get_by(Payor, name: "Maxicare")

    acu_schedules =
      AcuSchedule
      |> where([as], is_nil(as.status) or as.status == "")
      |> where([as], as.acu_email_sent != true)
      |> order_by([as], desc: as.inserted_at)
      |> Repo.all()
      |> Repo.preload([:acu_schedule_members, [provider: :agents]])
    unless Enum.empty?(acu_schedules) do
      Enum.map(acu_schedules, fn(acu_schedule) ->
        unless is_nil(acu_schedule.provider) do
          maps = acu_schedule.provider.agents
                 |> Enum.map(fn(x) ->
                   map = %{first_name: x.first_name, email: x.email, user_id: x.user_id}
                   acu_schedule.acu_schedule_members
                   if Enum.count(acu_schedule.acu_schedule_members) == acu_schedule.no_of_selected_members do
                     if not is_nil(map.user_id) do
                       acu_valid = if_acu_sched_notif?(map.user_id)
                       if acu_valid do
                         inserted_at = transform_date(acu_schedule.inserted_at)
                         send_email(x.id, acu_schedule.id, inserted_at, url_host.id, url_host)
                         ### for a while we comment this for testing purpose until it passes on ist, then we will uncomment this
                         update_acu_email_sent(acu_schedule, true)
                       end
                     end
                   end
                 end)
        end
      end)
    end
  end

  def send_email(agent_id, acu_schedule_id, inserted_at, api_address_id, url_host) do
    with {:ok, token} <- UtilityContext.providerlink_sign_in(url_host),
         head <- [{"Content-type", "application/json"},{"authorization", "Bearer #{token}"}],
         url <- "#{url_host.endpoint}email/send_acu_email",
         body <- Poison.encode!(%{agent_id: agent_id, acu_schedule_id: acu_schedule_id, inserted_at: inserted_at, payor_id: api_address_id}),
         {:ok, response} <- HTTPoison.post(url, body, head, []),
         true <- response.status_code == 200
    do
      insert_scheduler_logs(@module_name, "send_email/5", "Email has been sent.")
    else
      {:error, response} ->
        insert_scheduler_logs(@module_name, "send_email/5", "Error #{response.status_code}")

      _ ->
        Sentry.capture_exception(
          "function send email got error!",
          [
            stacktrace: System.stacktrace(),
            tags: %{
              "app_version" => "#{Appication.spec(:provider_scheduler, :vsn)}",
              "env" => ""
            }
          ]
        )

        insert_scheduler_logs(@module_name, "send_email/5", "function send email got error!")
    end
  end

  # def send_email(agent_id, acu_schedule_id, inserted_at, api_address_id, url_host) do
  #   with {:ok, token} <- UtilityContext.providerlink_sign_in(url_host),
  #        head <- [{"Content-type", "application/json"},{"authorization", "Bearer #{token}"}],
  #        url <- "localhost:4000/api/v1/email/send_acu_email",
  #        body <- Poison.encode!(%{agent_id: agent_id, acu_schedule_id: acu_schedule_id, inserted_at: inserted_at, payor_id: api_address_id}),
  #        {:ok, response} <- HTTPoison.post(url, body, head, []),
  #        true <- response.status_code == 200
  #   do
  #     insert_scheduler_logs(@module_name, "send_email/5", "Email has been sent.")
  #   else
  #     {:error, response} ->
  #       insert_scheduler_logs(@module_name, "send_email/5", "Error #{response.status_code}")

  #     _ ->
  #       insert_scheduler_logs(@module_name, "send_email/5", "function send email got error!")
  #   end
  # end

  def insert_scheduler_logs(module_name, method_name, message), do:
    SchedulerContext.insert_logs(%{module_name: module_name, method_name: method_name, message: message})

  defp if_acu_sched_notif?(id) do
    user = UserContext.get_user_by_id_notif(id)

    applications = Enum.map(user.roles, fn(ur) ->
      Enum.map(ur.role_applications, fn(ra) ->
        ra.application.name
      end)
    end)
    |> Enum.uniq()
    |> List.flatten()

    permissions = Enum.map(user.roles, fn(ur) ->
      Enum.map(ur.role_permissions, fn(rp) ->
        rp.permission.name
      end)
    end)
    |> Enum.uniq()
    |> List.flatten()

    if Enum.all?([
      Enum.member?(applications, "ProviderLink"),
      Enum.member?(permissions, "Manage ProviderLink ACU Schedules"),
      user.acu_schedule_notification
    ]) do
     true
    else
      false
    end
  end

  def transform_date(inserted_at) do
    date = Timex.format!(inserted_at, "{0M}-{D}-{YYYY}")
    month  =
      date
      |> String.split("-")
      |> Enum.at(0)
      |> String.to_integer()
      |> Timex.month_shortname()

    day_and_year =
      date
      |> String.split("-")
      |> List.delete_at(0)
      |> List.insert_at(1, ", ")
      |> Enum.join

    time = DateTime.to_string(Timex.shift(inserted_at, hours: 8))
    # raise time = DateTime.to_string(inserted_at)
    |> String.split(" ")
    |> Enum.at(1)
    |> String.split(":")
    |> List.delete_at(2)
    |> List.insert_at(1, ":")
    |> Enum.join()
    # |> raise

    # plus_hours = time
    # |> String.split(" ")
    # |> Enum.at(0)
    # |> Integer.parse
    # |> elem(0)

    # am_pm = Integer.parse(time)|> elem(0)
    # am_pm = if am_pm <= 12 do
    #              "AM"
    #           else
    #             "PM"
    #         end

    month_d_y = month <> " " <> day_and_year <> " " <> time
    #  <> " " <> am_pm
  end

  def update_forfeited_loa(conn, as, asm, is_recognized) do
    asm = Repo.preload(asm, :loa)
    params = %{
      verified_ids: [],
      forfeited_ids: [asm.loa.payorlink_authorization_id]
    }
    Repo.update(Changeset.change asm, is_recognized: is_recognized, is_registered: true, is_availed: true)
    LoaContext.update_status(asm.loa, %{status: "Forfeited"})
    update_payorlink_loa_status(conn, as, params)
    {:ok, asm}
  end

  def update_acu_schedule_amount(as, params) do
    params =
      %{
        estimate_total_amount: Decimal.new(params["gross_adjustment"]),
        actual_total_amount: Decimal.new(params["total_amount"]),
        registered: params["registered"],
        unregistered: params["unregistered"],
        status: "In Progress"
      }
    as
    |> AcuSchedule.changeset_amount(params)
    |> Repo.update()
  end

  def update_acu_email_sent(as, boolean) do
    as
    |> Ecto.Changeset.change(acu_email_sent: boolean)
    |> Repo.update()
  end

  def get_loa_package_code(loa_id) do
    LoaPackage
    |> where([lp], lp.loa_id == ^loa_id)
    |> select([lp], lp.code)
    |> Repo.one()
  end

  def get_loa_package_rate(loa_package_id) do
    LoaPackage
    |> join(:inner, [lp], l in Loa, lp.loa_id == l.id)
    |> where([lp], lp.id == ^loa_package_id)
    |> select([lp, l], l.total_amount)
    |> Repo.one()
  end

  def update_all_asm_to_encoded(asm_ids) do
    AcuScheduleMember
    |> where([asm], asm.id in ^asm_ids)
    |> Repo.update_all(set: [status: "Encoded", is_registered: true, is_availed: true])
  end

  def check_acu_schedule_progress_and_update_submitted(as) do
    asm =
    AcuScheduleMember
    |> where([asm], asm.acu_schedule_id == ^as.id and asm.status == "Encoded" and is_nil(asm.image) and is_nil(asm.is_recognized))
    |> Repo.all()

    if Enum.empty?(asm) do
      Repo.update(Changeset.change as, status: "Submitted")
    end
  end

  def get_acu_sched_by_batch_no(nil), do: nil
  def get_acu_sched_by_batch_no(batch_no) do
    AcuSchedule
    |> where([as], as.batch_no == ^batch_no)
    |> where([as], as.status != "Stale" or is_nil(as.status))
    |> limit(1)
    |> Repo.one()
  end

  def hide_acu_schedule(nil), do: nil
  def hide_acu_schedule(acu_schedule) do
    acu_schedule
    |> Ecto.Changeset.change(%{hidden_from_mobile: true})
    |> Repo.update()
  end

  def get_asm_batch_file_index(acu_schedule_id) do
    Loa
    |> join(:inner, [l], asm in AcuScheduleMember, asm.loa_id == l.id)
    |> where([l, asm], asm.acu_schedule_id == ^acu_schedule_id)
    |> order_by([l, asm], asc: l.member_card_no)
    |> Repo.all()
    |> Repo.preload([:loa_packages])
  end
end
