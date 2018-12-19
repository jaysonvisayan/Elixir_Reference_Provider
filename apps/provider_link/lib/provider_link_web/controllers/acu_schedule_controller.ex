defmodule ProviderLinkWeb.AcuScheduleController do
  use ProviderLinkWeb, :controller
  alias ProviderLinkWeb.AcuScheduleView
  alias Data.Contexts.{
    MemberContext,
    AcuScheduleContext,
    LoaContext,
    UtilityContext,
    PayorContext
  }
  alias Data.Schemas.{
    AcuSchedule,
    AcuScheduleMember,
    User
  }
  alias Data.Contexts.{
    AcuScheduleContext,
    UserContext,
    BatchContext
  }
  alias Data.Schemas.AcuSchedule
  alias Decimal

  plug Guardian.Permissions.Bitwise,
    [handler: ProviderLinkWeb.FallbackController,
     one_of: [
       %{acu_schedules: [:manage_providerlink_acu_schedules]},
       %{acu_schedules: [:access_providerlink_acu_schedules]},
     ]] when action in [
       :index,
       :render_index,
       :show
     ]

  plug Guardian.Permissions.Bitwise,
    [handler: ProviderLinkWeb.FallbackController,
     one_of: [%{acu_schedules: [:manage_providerlink_acu_schedules]}
     ]] when not action in [
       :index,
       :render_index,
       :show,
     ]


  def index(conn, _params) do
    render_index(conn, nil)
  end

  defp render_index(conn, nil) do
    provider = conn.assigns.current_user.agent.provider
    acu_schedules = AcuScheduleContext.get_all_acu_schedule_by_provider(provider.id)
    render(conn, "index.html", acu_schedules: acu_schedules)
  end

  # defp render_index(conn, paylink_user_id) do
  #   with user = %User{} <- UserContext.get_user_by_paylink_user_id(paylink_user_id) do
  #     provider = user.agent.provider
  #     acu_schedules = AcuScheduleContext.get_all_acu_schedule_by_provider(provider.id)
  #     render(conn, "paylink/index.html", acu_schedules: acu_schedules)
  #   else
  #     _ ->
  #       conn
  #       |> put_flash(:error, "You must be signed in to access that page.")
  #       |> redirect(to: "/sign_in")
  #   end
  # end

  def export(conn, %{"acu_schedule" => params}) do
    # Export Masterlist
  end

  defp load_total_amount(actual_amount, acu_schedule) do
    acu_schedule.id
    |> AcuScheduleContext.total_amount()
    |> AcuScheduleContext.compute_total()
  end
  # defp load_total_amount(actual_amount, acu_schedule) when not is_nil(actual_amount), do: acu_schedule.actual_total_amount

  def render_upload(conn, params) do
    id = params["id"]
    paylink_user_id = params["paylink_user_id"]
    changeset = AcuSchedule.changeset(%AcuSchedule{})
    acu_schedule = AcuScheduleContext.get_acu_schedule(id)

  if not is_nil(acu_schedule) do
    total_amount = load_total_amount(acu_schedule.actual_total_amount, acu_schedule)
    prescription_term = acu_schedule.provider.prescription_term

    with false <- is_nil(paylink_user_id),
         user = %User{} <- UserContext.get_user_by_paylink_user_id(paylink_user_id)
    do
      params = Map.put(conn.params, "paylink_user_id", paylink_user_id)
      conn = Map.put(conn, :params, params)
      render(conn, "paylink/acu_schedule_upload.html", acu_schedule: acu_schedule, changeset: changeset)
    else
      _ ->
        cond  do
          is_nil(acu_schedule) ->
            conn
            |> put_flash(:error, "ACU Schedule does not exist.")
            |> redirect(to: "/acu_schedules/")
          acu_schedule.status == "Submitted" ->
            conn
            |> put_flash(:error, "ACU Schedule is already submitted.")
            |> redirect(to: "/acu_schedules/")
          true ->
             render(
              conn,
              "acu_schedule_upload.html",
              acu_schedule: acu_schedule,
              changeset: changeset,
              total_amount: total_amount,
              prescription_term: prescription_term
            )
        end
      end
    else
      conn
      |> put_flash(:error, "ACU Schedule does not exist.")
      |> redirect(to: "/acu_schedules/")
    end
  end

  defp compute_soa_amount(nil, a_amount, e_amount) do
    result =
      0
      |> Decimal.new()
      |> Decimal.add(Decimal.add(a_amount, e_amount))
  end

  defp compute_soa_amount(g_amount, a_amount, e_amount) do
    if Decimal.to_float(Decimal.add(a_amount, e_amount)) < Decimal.to_float(g_amount) do
      g_amount
    else
      Decimal.add(a_amount, e_amount)
    end
  end

  def submit_upload(conn, params) do
    id = params["id"]
    acu_schedule = AcuScheduleContext.get_acu_schedule(params["id"])

    soa_reference_no = params["acu_schedule_upload"]["soa_reference_no"]
    estimate_total_amount = params["acu_schedule_upload"]["estimate_total_amount"]
    estimate_total_amount =
      if is_nil(estimate_total_amount) || estimate_total_amount == "" do
        Decimal.new(0)
      else
        Decimal.new(estimate_total_amount)
      end

    actual_total_amount =
      if is_nil(params["acu_schedule_upload"]["actual_total_amount"]) || params["acu_schedule_upload"]["actual_total_amount"] == "" do
        Decimal.new(0)
      else
        params["acu_schedule_upload"]["actual_total_amount"]
        |> Decimal.new()
      end
    soa_amount = compute_soa_amount(acu_schedule.guaranteed_amount, actual_total_amount, estimate_total_amount)

    paylink_user_id = params["paylink_user_id"]

    verified_members =
      Enum.filter(acu_schedule.acu_schedule_members, fn(asm) ->
        asm.loa_status == "IBNR" and asm.status == "Encoded"
      end)
    forfeited_members =
      Enum.reject(acu_schedule.acu_schedule_members, fn(asm) ->
        asm.loa_status == "IBNR" and asm.status == "Encoded"
      end)

    verified_ids = Enum.into(verified_members, [], &(&1.loa.payorlink_authorization_id))
    forfeited_ids = Enum.into(forfeited_members, [], &(&1.loa.payorlink_authorization_id))
    verified_loa_ids = Enum.into(verified_members, [], &(&1.loa.id))

    file_params = %{
      acu_schedule_id: acu_schedule.id,
      name: params["acu_schedule_upload"]["file"].filename,
      type: params["acu_schedule_upload"]["file"]
    }

    batch_params = %{
      "soa_reference_no" => soa_reference_no,
      "soa_amount" => soa_amount,
      "edited_soa_amount" => actual_total_amount,
      "status" => "Submitted",
      "type" => "hospital_bill"
    }

    with {:ok, batch} <- BatchContext.create_submitted_batch(batch_params, conn.assigns.current_user.id),
         {:ok, acu_schedule} <- AcuScheduleContext.update_acu_email_sent(acu_schedule, false)
    do
      batch_loa_params = Enum.map(verified_loa_ids, fn(x) ->
        %{
          loa_id: x,
          batch_id: batch.id,
          inserted_at: Ecto.DateTime.utc(),

          updated_at: Ecto.DateTime.utc()
        }
      end)

      BatchContext.create_batch_loa(batch_loa_params)

      {:ok, file} = File.read(params["acu_schedule_upload"]["file"].path)
      case AcuScheduleContext.create_acu_schedule_file(file_params) do
        {:ok, acu_schedule_file} ->
          file = %{
            filename: params["acu_schedule_upload"]["file"].filename,
            base_64_encoded: Base.encode64(file),
            content_type: params["acu_schedule_upload"]["file"].content_type
          }
          params = %{
            verified_ids: verified_ids,
            forfeited_ids: forfeited_ids,
            file: file,
            soa_ref_no: soa_reference_no,
            soa_amount: soa_amount,
            batch_no: batch.number,
            batch_id: batch.id,
            submitted_date: batch.updated_at,
            edited_soa_amount: actual_total_amount,
            acu_schedule_batch_no: acu_schedule.batch_no
          }
          with {:valid_date} <- AcuScheduleContext.acu_schedule_date_checker(acu_schedule),
               {:ok, acu_schedule} <- AcuScheduleContext.update_acu_schedule_est_total(acu_schedule, estimate_total_amount),
               {:ok, acu_schedule} <- AcuScheduleContext.update_acu_schedule_act_total(acu_schedule, acu_schedule.guaranteed_amount, actual_total_amount),
               {:ok, acu_schedule} <- AcuScheduleContext.update_acu_schedule_soa_no(acu_schedule, soa_reference_no),
               {:ok, acu_schedule} <- AcuScheduleContext.update_acu_schedule_batch_id(acu_schedule, batch.id),
               {:ok, acu_schedule} <- AcuScheduleContext.update_payorlink_loa_status(conn, acu_schedule, params)
          do
            AcuScheduleContext.update_schedule_status(acu_schedule, "Submitted")
            redirect_submit_upload(conn, id, paylink_user_id)
          else
            {:error_date} ->
              conn
              |> put_flash(:error, "Submission of Claims shall be on the last day of ACU Mobile schedule: #{acu_schedule.date_to}")
              |> redirect(to: "/acu_schedules/#{id}/upload")
            {:unable_to_login} ->
              conn
              |> put_flash(:error, "Payorlink is currently down")
              |> redirect_submit_upload(id, paylink_user_id)
            {:error, response} ->
              conn
              |> put_flash(:error, response)
              |> redirect_submit_upload(id, paylink_user_id)
            {:error_soa, response} ->
              conn
              |> put_flash(:error, response)
              |> redirect(to: "/acu_schedules/#{id}/upload")
            _ ->
              conn
              |> put_flash(:error, "Payorlink is currently down.")
              |> redirect_submit_upload(id, paylink_user_id)
          end
          _ ->
            conn
            |> put_flash(:error, "Invalid file format upload only (pdf, xls, jpg, csv, doc, docx, xlsx, png, jpeg).")
            |> redirect(to: "/acu_schedules/#{id}/upload")
      end
    else
      _ ->
      conn
      |> put_flash(:error, "Error")
      |> redirect(to: "/acu_schedules/#{id}/upload")
    end
  rescue
    _ ->
    conn
    |> put_flash(:error, "Error submitting upload. Please try again later!")
    |> redirect(to: "/acu_schedules/#{params["id"]}/upload")
  end

  defp redirect_submit_upload(conn, id, nil) do
    provider = conn.assigns.current_user.agent.provider
    acu_schedules = AcuScheduleContext.get_all_acu_schedule_by_provider(provider.id)
    render(conn, "index.html", acu_schedules: acu_schedules, submitted: true)
  end

  defp redirect_submit_upload(conn, id, paylink_user_id) do
    redirect(conn, to: "/paylink/#{paylink_user_id}/acu_schedules/")
  end

  defp request_loa_acu(conn, loa_params, user) do
    provider = user.agent.provider
    loa_id = loa_params["loa_id"]
    loa_params = Map.put(loa_params, "facility_code", provider.code)
    LoaContext.request_update_loa_acu(conn, loa_params)
  end

  def member_index(conn, params) do
    id = params["id"]
    paylink_user_id = params["paylink_user_id"]
    acu_schedule = AcuScheduleContext.get_acu_schedule(id)
    if is_nil(acu_schedule) do
      conn
      |> put_flash(:error, "ACU Schedule not found")
      |> redirect(to: "/acu_schedules")
    else
      if acu_schedule.status != "Encoded" do
        #create_ibnr_loa_of_members(conn, acu_schedule)
        render_member_index(conn, id, acu_schedule, paylink_user_id)
      else
        conn
        |> redirect(to: "/acu_schedules/#{id}/upload")
      end
    end
  end

  def render_member_index(conn, id, acu_schedule, nil) do
    acu_schedule_members = acu_schedule.acu_schedule_members
    selected_members = Enum.count(acu_schedule_members)
    asm_upload_file =
      AcuScheduleContext.get_asm_upload_files(acu_schedule.id)
      |> Enum.at(0)
    {:ok, acu_schedule} = AcuScheduleContext.update_selected_members(acu_schedule, selected_members, acu_schedule.no_of_selected_members)
    cond do
      Enum.empty?(acu_schedule_members) ->
        conn
        |> put_flash(:error, "The members for this batch is not yet completely transmitted.")
        |> redirect(to: "/acu_schedules/")
      acu_schedule.no_of_selected_members != selected_members ->
        conn
        |> put_flash(:error, "The members for this batch is not yet completely transmitted")
        |> redirect(to: "/acu_schedules/")
      true  ->
        changeset = AcuSchedule.changeset(%AcuSchedule{})
        render(
          conn,
          "acu_schedule_member.html",
          acu_schedule_members: acu_schedule_members,
          acu_schedule: acu_schedule,
          asm_upload_file: asm_upload_file,
          changeset: changeset
        )
    end
  end

  def render_member_index(conn, id, acu_schedule, paylink_user_id) do
    acu_schedule_members = acu_schedule.acu_schedule_members
    selected_members = Enum.count(acu_schedule_members)
    {:ok, acu_schedule} = AcuScheduleContext.update_selected_members(acu_schedule, selected_members, acu_schedule.no_of_selected_members)
    cond do
      Enum.empty?(acu_schedule_members) ->
        conn
        |> redirect(to: "/paylink/#{paylink_user_id}/acu_schedules/#{id}/upload")
      acu_schedule.no_of_selected_members != selected_members ->
        conn
        |> put_flash(:error, "The members for this batch is not yet completely transmitted")
        |> redirect(to: "/acu_schedules/")
      true ->
        changeset = AcuSchedule.changeset(%AcuSchedule{})
        render(
          conn,
          "paylink/acu_schedule_member.html",
          acu_schedule_members: acu_schedule_members,
          acu_schedule: acu_schedule,
          changeset: changeset
        )
    end
  end

  # defp acu_schedule_members(acu_schedule) do
  #   Enum.reject(acu_schedule.acu_schedule_members, &(&1.loa_status == "IBNR"))
  # end

  defp create_ibnr_loa_of_members(conn, acu_schedule) do
    asms = Enum.reject(acu_schedule.acu_schedule_members, &(&1.loa_status == "IBNR" and &1.status == "Encoded"))
    user = conn.assigns.current_user
    for asm <- asms do
      acu_params =
        %{
          facility_code: conn.assigns.current_user.agent.provider.code,
          coverage_code: "ACU",
          card_no: asm.member.card.number
        }
      {result, loa_response_payor} = LoaContext.get_acu_details(conn, acu_params)

      if result == :ok do
        params = %{
          "card_no" => asm.member.card.number,
          "verification_type"  => "acu_mobile",
          "user_id" => user.id,
          "provider_id" => conn.assigns.current_user.agent.provider.id
        }
        {:ok, loa_response_provider} =  LoaContext.request_loa_acu(params, loa_response_payor)
        loa_params = %{
          "acu_type" => "Regular-Outpatient",
          "amount" => loa_response_payor["package_facility_rate"],
          "authorization_id" => loa_response_payor["authorization_id"],
          "benefit_provider_access" => "Mobile",
          "card_no" => asm.member.card.number,
          "loa_id" => loa_response_provider.id,
          "member_id" => asm.member.id,
          "valid_until" => asm.member.expiry_date,
          "verification_type"  => "acu_mobile"
        }
        conn
        |> request_loa_acu(
          loa_params,
          user
        )
        AcuScheduleContext.update_asm_loa_status(asm, %{loa_status: "IBNR", loa_id: loa_response_provider.id})
      end
    end
  end

  def update_member_schedule(conn, params) do
    id = params["id"]
    paylink_user_id = params["paylink_user_id"]
    acu_schedule = AcuScheduleContext.get_acu_schedule(id)
    acu_schedule_members = String.split(params["acu_schedule_member"]["acu_schedule_member_ids_main"], ",")
    if acu_schedule_members == [""] do
      conn
      |> put_flash(:error, "Please select at least (1) one member")
      |> redirect_update_member_schedule(id, paylink_user_id)
    else
      # if Enum.count(acu_schedule_members) <= acu_schedule.no_of_guaranteed do
        # AcuScheduleContext.update_schedule_status(acu_schedule, "Encoded")
        AcuScheduleContext.update_encode_status(acu_schedule_members)
        conn = put_flash(conn, :info, "Member/s successfully encoded")
        if is_nil(paylink_user_id) do
          redirect(conn, to: "/acu_schedules/#{id}/upload")
        else
          redirect(conn, to: "/paylink/#{paylink_user_id}/acu_schedules/#{id}/upload")
        end
      # else
      #   conn
      #   |> put_flash(:error, "Selected Members exceed no of guaranteed")
      #   |> redirect_update_member_schedule(id, paylink_user_id)
      # end
    end
  end

  defp redirect_update_member_schedule(conn, id, nil) do
    redirect(conn, to: "/acu_schedules/#{id}/members")
  end

  defp redirect_update_member_schedule(conn, id, paylink_user_id) do
    redirect(conn, to: "/paylink/#{paylink_user_id}/acu_schedules/#{id}/members")
  end

   def acu_schedule_export(conn, params) do
    params = params["id"]
    params = Poison.decode!(params)
    id = params["id"]
    datetime = params["datetime"]

    with {:ok, file} <- AcuScheduleContext.acu_schedule_export(id, datetime) do
      {file_name, binary} = file

      conn
      |> put_resp_content_type("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      |> put_resp_header("content-disposition", "inline; filename=#{file_name}")
      |> send_resp(200, binary)
    else
      _ ->
        json(conn, %{status: "failed"})
    end
  end

  def acu_schedule_email_export(conn, %{"id" => id}) do
    acu_schedule = AcuScheduleContext.get_acu_schedule(id)
    datetime = AcuScheduleContext.transform_date(acu_schedule.inserted_at)

    with {:ok, file} <- AcuScheduleContext.acu_schedule_export(id, datetime) do
      {file_name, binary} = file

      conn
      |> put_resp_content_type("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      |> put_resp_header("content-disposition", "inline; filename=#{file_name}")
      |> send_resp(200, binary)
    else
      _ ->
        json(conn, %{status: "failed"})
    end
  end

  def cancel_upload(conn, %{"id" => id}) do
    acu_schedule = AcuScheduleContext.get_acu_schedule(id)
    if is_nil(acu_schedule) do
      conn
      |> put_flash(:error, "ACU Schedule not found.")
      |> redirect(to: "/acu_schedules/")
    else
      AcuScheduleContext.update_schedule_status(acu_schedule, nil)
      conn
      |> redirect(to: "/acu_schedules/#{id}/members")
    end
  end

  def upload_asm(conn, params) do
    user_id = conn.assigns.current_user.id
    if Enum.count(params) == 1, do:
      conn
      |> put_flash(:error, "Please choose a file.")
      |> redirect(to: "/acu_schedules/#{params["id"]}/members")

    case AcuScheduleContext.upload_member(params, user_id) do
      {:ok, card_nos} ->
        {:ok, encoded, all} = AcuScheduleContext.update_encode_card_nos(params["id"], card_nos)
        asm_upload_file =
          AcuScheduleContext.get_asm_upload_files(params["id"])
          |> Enum.at(0)
          json(conn, %{
            message: "#{encoded} out of #{all} have been selected",
            id: asm_upload_file.id,
            filename: asm_upload_file.filename,
            card_nos: card_nos
          })
      {:not_found} ->
        json(conn, %{
          message: "File has empty records."
        })
      {:not_equal} ->
        json(conn, %{
          message: "Invalid column format."
        })
      {:not_equal, columns} ->
        json(conn, %{
          message: "File has missing column/s: #{columns}."
        })
      {:invalid, message} ->
        json(conn, %{
          message: message
        })
      {:error, _changeset} ->
        json(conn, %{
          message: "Oops, something went wrong.."
        })
    end
  end

  def download_asm(conn, %{"log_id" => log_id}) do
    data =
      [[
        "Card Number", "Full Name", "Gender", "Birthdate",
        "Age", "Package Code", "Signature", "Availed ACU? (Y or N)", "Remarks"
      ]]

    data =
      data ++ AcuScheduleContext.get_asm_batch_file(log_id)
      |> CSV.encode
      |> Enum.to_list
      |> Enum.uniq
      |> to_string

    conn
    |> json(data)
  end

  def show(conn, %{"id" => id}) do
    case AcuScheduleContext.get_acu_schedule(id) do
      %AcuSchedule{} ->
        provider = conn.assigns.current_user.agent.provider
        acu_schedule = AcuScheduleContext.get_acu_schedule(id)
        changeset = AcuSchedule.changeset(acu_schedule)
        members = acu_schedule.acu_schedule_members
        packages = Enum.map(members, fn(x) -> x.loa.loa_packages end)
                   |> List.flatten()
        loas = Enum.map(members, fn(x) -> x.loa end)
        render(
          conn, "show_acu_schedule.html",
          acu_schedule: acu_schedule,
          changeset: changeset,
          # account_groups: account_groups,
          # clusters: clusters,
          acu_schedule_members: [],
          # asm_removes: asm_removes,
          acu_schedule_packages: packages,
          loas: loas,
          provider: %{code: provider.code, name: provider.name, id: provider.id}
        )
      _ ->
        conn
        |> put_flash(:error, "ACU Schedule not Found")
        |> redirect(to: acu_schedule_path(conn, :index))
    end
  end

  def export_member_details(conn,  params) do
    params = params["id"]
    params = Poison.decode!(params)
    id = params["id"]
    record = AcuScheduleContext.load_acu(id)
    date_now = DateTime.utc_now()
    filename = "#{record.batch_no}-#{record.account_code}-#{DateTime.to_date(date_now)}MemberList.csv"

    data =
      id
      |> member_details(record.status)
      |> CSV.encode
      |> Enum.to_list
      |> to_string

    conn
    |> json(%{
        data: data,
        filename: filename
      })
  end

  defp member_details(id, status) when status == "Submitted" do
    data =
      [[
        "Card Number", "Full Name", "Gender",
        "Birthdate", "Age", "Package Code",
        "Package Name", "Package Amount", "Signature",
        "Status"
      ]]

    member_details =
      id
      |> AcuScheduleContext.get_asm_batch_file_index()
      |> Enum.map(fn(loa) ->
          [
            AcuScheduleView.member_card_no(loa),
            AcuScheduleView.member_full_name(loa),
            AcuScheduleView.member_gender(loa),
            AcuScheduleView.member_birthdate(loa),
            loa.member_age,
            List.first(loa.loa_packages).code,
            List.first(loa.loa_packages).description,
            loa.total_amount,
            "",
            loa.status
          ]
        end)

    data ++ member_details
  end

  defp member_details(id, status) do
    data =
      [[
        "Card Number", "Full Name", "Gender",
        "Birthdate", "Age", "Package Code",
        "Signature", "Availed ACU? (Y or N)"
      ]]

    member_details =
      id
      |> AcuScheduleContext.get_asm_batch_file_index()
      |> Enum.map(fn(loa) ->
          [
            AcuScheduleView.member_card_no(loa),
            AcuScheduleView.member_full_name(loa),
            AcuScheduleView.member_gender(loa),
            AcuScheduleView.member_birthdate(loa),
            loa.member_age,
            List.first(loa.loa_packages).code
          ]
        end)

    data ++ member_details
  end

end
