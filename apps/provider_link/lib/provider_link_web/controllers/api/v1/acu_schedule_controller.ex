defmodule ProviderLinkWeb.Api.V1.AcuScheduleController do
  use ProviderLinkWeb, :controller
  alias ProviderLinkWeb.AcuScheduleView
  alias ProviderLinkWeb.Api.V1.ErrorView
  alias ProviderLinkWeb.Api.V1.StatusView
 alias Data.Repo
  alias Ecto.Changeset
  alias Data.Schemas.{
    Provider,
    AcuSchedule,
    AcuScheduleMember,
    Loa,
    Batch
  }
  alias Data.Contexts.{
    AcuScheduleContext,
    MemberContext,
    ProviderContext,
    LoaContext,
    BatchContext,
    UtilityContext
  }
  alias ProviderLink.Guardian, as: PG

  def create_schedule(conn, params) do
    with {:ok, acu_schedule} <- AcuScheduleContext.insert_schedule(params),
         {:ok, acu_schedule} <- AcuScheduleContext.update_acu_email_sent(acu_schedule, false)
    do
      conn
      |> put_status(200)
      |> render(AcuScheduleView, "success.json", message: "ACU Schedule successfully inserted.")
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(AcuScheduleView, "error.json", message: "Error inserting ACU Schedule.")
      _ ->
        conn
        |> put_status(400)
        |> render(AcuScheduleView, "error.json", message: "Error inserting ACU Schedule.")
    end
  end

  def insert_schedule_member(conn, params) do
    user = PG.current_resource_api(conn)
    acu_schedule = AcuScheduleContext.get_acu_schedule_by_payorlink_id(params["id"])
    provider_id = acu_schedule.provider_id
    with {:ok, member} <- AcuScheduleContext.insert_acu_member(params),
         {:ok, loa} <- request_acu_loa(user, provider_id, params, acu_schedule.id, member.id)
    do
      conn
      |> put_status(200)
      |> render(AcuScheduleView, "success.json", message: "ACU Schedule successfully inserted.")
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(AcuScheduleView, "error.json", message: "Error Requesting ACU Loa.")
      _ ->
        conn
        |> put_status(400)
        |> render(AcuScheduleView, "error.json", message: "Error Reqeusting ACU Loa.")
    end
  end

  def insert_schedule_member_from_payorlink(conn, params) do
    user = PG.current_resource_api(conn)
    acu_schedule = AcuScheduleContext.get_acu_schedule_by_payorlink_id_2(params["id"])
    provider_id = acu_schedule.provider_id
    with {:ok, member} <- AcuScheduleContext.insert_acu_member(params, acu_schedule.id),
         {:ok, loa} <- request_acu_loa_from_payorlink(user, provider_id, params, acu_schedule.id, member)
    do
      conn
      |> put_status(200)
      |> render(AcuScheduleView, "success.json", message: "ACU Schedule successfully inserted.")
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(AcuScheduleView, "error.json", message: "Error Requesting ACU Loa.")
      _ ->
        conn
        |> put_status(400)
        |> render(AcuScheduleView, "error.json", message: "Error Reqeusting ACU Loa.")
    end
    rescue
    e in Ecto.MultipleResultsError ->
    conn
    |> put_status(400)
    |> render(AcuScheduleView, "error.json", message: "Duplicate data.")
    _ ->
    conn
    |> put_status(400)
    |> render(AcuScheduleView, "error.json", message: "Error Requesting ACU Loa.")
  end

  defp request_acu_loa(user, provider_id, params, acu_schedule_id, asm_id) do
    # member = MemberContext.get_member_by_payorlink_member_id(params["member_id"])
    acu_params = %{
      # "card_no" => member.card.number,
      "verification_type"  => "acu_mobile",
      "user_id" => user.id,
      "provider_id" => provider_id,
      # "member_id" => member.id
    }
    {:ok, loa} = LoaContext.request_loa_acu(acu_params, params)
    acu_params =
      acu_params
      |> has_admission_date()
      |> has_discharge_date()
      |> Map.put("valid_until", params["member_expiry_date"])
      |> Map.put("status", params["status"])
      |> Map.put("issue_date", params["issue_date"])
      |> Map.put("request_date", Ecto.DateTime.utc())
      |> Map.put("loa_number", params["loa_number"])
      |> Map.put("control_number", params["control_number"])
    {:ok, loa} = LoaContext.update_loa_acu(loa, acu_params)
    asm = AcuScheduleContext.get_acu_schedule_member(asm_id)
    AcuScheduleContext.update_asm_loa_status(asm, %{loa_status: "IBNR", loa_id: loa.id})
  end

  defp request_acu_loa_from_payorlink(user, provider_id, params, acu_schedule_id, asm) do
    # member = MemberContext.get_member_by_payorlink_member_id(params["member_id"])
    acu_params = %{
      # "card_no" => member.card.number,
      "verification_type"  => "acu_mobile",
      "user_id" => user.id,
      "provider_id" => provider_id,
      # "member_id" => member.id
    }
    {:ok, loa} = LoaContext.request_loa_acu_update(acu_params, params)
    acu_params =
      acu_params
      |> Map.put("admission_date", params["admission_date"])
      |> Map.put("valid_until", params["member_expiry_date"])
      |> Map.put("status", params["status"])
      |> Map.put("issue_date", params["issue_date"])
      |> Map.put("request_date", Ecto.DateTime.utc())
      |> Map.put("loa_number", params["loa_number"])
      |> Map.put("control_number", params["control_number"])
    {:ok, loa} = LoaContext.update_loa_acu(loa, acu_params)
    AcuScheduleContext.update_asm_loa_status(asm, %{loa_status: "IBNR", loa_id: loa.id})
  end

  defp has_discharge_date(params) do
    if Map.has_key?(params, "discharge_date") do
      Map.put(params, "discharge_date", transform_to_datetime(params["discharge_date"]))
    else
      params
    end
  end

  defp has_admission_date(params) do
    if Map.has_key?(params, "admission_date") do
      Map.put(params, "admission_date", transform_to_datetime(params["admission_date"]))
    else
      params
    end
  end

  def transform_to_datetime(date) do
    Ecto.DateTime.cast!("#{date} 00:00:00")
  end

  def update_acu_loa_verified(conn, %{"id" => id}) do
    loa = LoaContext.get_loa_by_payorlink_id(id)
    params = %{
      otp: true,
      status: "Availed",
      admission_date: Ecto.DateTime.utc(),
      discharge_date: Ecto.DateTime.utc()
    }
    LoaContext.update_loa_acu(loa, params)
    json conn, Poison.encode!(true)
  end

  def update_acu_loa_forfeited(conn, %{"id" => id}) do
    loa = LoaContext.get_loa_by_payorlink_id(id)
    params = %{
      status: "Forfeited"
    }
    LoaContext.update_loa_acu(loa, params)
    json conn, Poison.encode!(true)
  end

  def update_member_registration(conn, params) do
    with true <- Map.has_key?(params, "member_card_no"),
         true <- Map.has_key?(params, "batch_no"),
         true <- params["batch_no"] != "",
         # %Member{} = member <- MemberContext.get_member_by_card(params["card_no"]),
         %Loa{} = loa <- LoaContext.get_member_by_card(params["member_card_no"]),
         %AcuScheduleMember{} = acu_schedule_member <- member_acu_sched(loa.id, params)
    do
      if is_nil(acu_schedule_member.is_registered) || acu_schedule_member.is_registered == false do
        AcuScheduleContext.update_member_registration(acu_schedule_member)
        conn
        |> render(StatusView, "success.json")
      else
          conn
          |> put_status(400)
          |> render(ErrorView, "error.json", message: "Member already registered!")
      end
    else
      _ ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid Parameters!")
    end
  end

  def update_member_availment(conn, params) do
    with true <- Map.has_key?(params, "member_card_no"),
         true <- Map.has_key?(params, "batch_no"),
         true <- params["batch_no"] != "",
         # %Member{} = member <- MemberContext.get_member_by_card(params["card_no"]),
         %Loa{} = loa <- LoaContext.get_member_by_card(params["member_card_no"]),
         %AcuScheduleMember{} = acu_schedule_member <- member_acu_sched(loa.id, params)
    do
        if is_nil(acu_schedule_member.is_availed) || acu_schedule_member.is_availed == false do
          AcuScheduleContext.update_member_availment(acu_schedule_member)
          conn
          |> render(StatusView, "success.json")
        else
          conn
          |> put_status(400)
          |> render(ErrorView, "error.json", message: "Member already registered!")
        end
    else
      _ ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid Parameters!")
    end
  end

  defp member_acu_sched(loa_id, params) do
    MemberContext.get_acu_schedule_by_loa_id(loa_id, params["batch_no"])
  end

  def get_acu_schedules_by_provider_code(conn, params) do
    code = params["provider_code"]
    with {:ok} <- check_if_valid(code),
         provider = %Provider{} <- ProviderContext.get_provider_by_code(code),
         false <- Enum.empty?(as = AcuScheduleContext.get_all_acu_schedule_by_provider_id(provider.id))
    do
      render(conn, "acu_schedules_by_providers.json", acu_schedules: as)
    else
      {:invalid_parameter} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid parameter")
      {:invalid, message} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: message)
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Provider not found")
      true ->
        conn
        |> put_status(404)
        |> render("acu_schedules_by_providers.json", acu_schedules: [])
      _ ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "No ACU Schedules found")
    end
  end

  def get_by_batch_no(conn, params) do
    batch_no = params["batch_no"]
    with {:ok} <- check_if_valid_batch_no(batch_no),
         as = %AcuSchedule{} <- AcuScheduleContext.get_schedule_by_batch_no3(batch_no)
    do
      render(conn, "acu_schedule.json", acu_schedule: as)
    else
      {:error, nil} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "ACU Schedule not found")
      {:invalid_parameter} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid parameter")
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Provider not found")
      true ->
        conn
        |> put_status(404)
        |> render("acu_schedules.json", acu_schedules: [])
      _ ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "No ACU Schedules found")
    end
  end

  def check_if_valid(params) do
    if is_nil(params) do
      {:invalid_parameter}
    else
      {:ok}
    end
  end

  def check_if_valid_batch_no(params) do
    if is_integer(params) do
      {:ok}
    else
      if is_nil(params) or not  Regex.match?(~r/^[0-9]*$/, params) do
        {:invalid_parameter}
      else
        {:ok}
      end
    end
  end

  def submit_batch(conn, params) do
    id = params["id"]
    batch_no = params["batch_no"]
    image = params["image"]
    with {:ok, params} <- check_submit_batch_valid_params(params),
         asm = %AcuScheduleMember{} <- AcuScheduleContext.get_acu_schedule_member(id),
         as = %AcuSchedule{} <- AcuScheduleContext.get_schedule_by_batch_no(batch_no),
         {:ok} <- validate_acu_schedule_member(as, asm),
         {:ok, batch} <- get_batch_by_acu_schedule(as),
         true <- check_image_params(image),
         # {:ok, as} <- AcuScheduleContext.update_acu_schedule_amount(as, params),
         batch = %Batch{} <- create_batch_loa(conn, asm, batch)
    do
      Repo.update(Changeset.change as,
                  estimate_total_amount: Decimal.new(params["gross_adjustment"]),
                  actual_total_amount: Decimal.new(params["total_amount"]),
                  registered: params["registered"],
                  unregistered: params["unregistered"],
                  status: "Submitted")

      is_recognized = AcuScheduleContext.verify_facial_biometrics(conn, asm, image)
      is_recognized = if is_recognized == true or is_recognized == false do
        Repo.update(Changeset.change asm, submit_log: "Successfully Submitted")
        is_recognized
      else
        Repo.update(Changeset.change asm, submit_log: "Unable to connect in facial biometrics API")
        false
      end

      Repo.update(Changeset.change batch, soa_amount: Decimal.new(params["direct_cost"]),
                  edited_soa_amount: Decimal.new(params["total_amount"]))

      params = %{
        image: params["image"],
        soa_ref_no: as.soa_reference_no,
        soa_amount: params["direct_cost"],
        batch_no: batch.number,
        submitted_date: batch.updated_at,
        edited_soa_amount: params["total_amount"],
        registered: params["registered"]
      }
      case AcuScheduleContext.update_availed_acu_schedule(conn, as, asm, params, is_recognized) do
        {:ok, asm} ->
          asm =
            asm
            |> Map.put(:is_recognized, is_recognized)

            conn
            |> put_status(200)
            |> render(AcuScheduleView, "image.json", asm: asm)
        _ ->
          conn
          |> put_status(404)
          |> render(ErrorView, "error.json", message: "Invalid File Type")
      end
    else
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "ACU Schedule Member not found")
      {:error, nil} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "ACU Schedule not found")
      false ->
        asm = AcuScheduleContext.get_acu_schedule_member(id)
        as = AcuScheduleContext.get_schedule_by_batch_no(batch_no)
        {:ok, batch} = get_batch_by_acu_schedule(as)
        case AcuScheduleContext.update_forfeited_loa(conn, as, asm, false) do
          {:ok, asm} ->
            Repo.update(Changeset.change asm, submit_log: "Successfully Submitted")
            Repo.update(Changeset.change batch, soa_amount: Decimal.new(params["direct_cost"]),
                        edited_soa_amount: Decimal.new(params["total_amount"]))
            AcuScheduleContext.update_acu_schedule_amount(as, params)
            asm =
              asm
              |> Map.put(:is_recognized, false)

              conn
              |> put_status(200)
              |> render(AcuScheduleView, "image.json", asm: asm)
          _ ->
            conn
            |> put_status(404)
            |> render(ErrorView, "error.json", message: "Internal Server Error")
        end
      {:error_params, message} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: message)
      {:asm_already_submitted} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Member Already Submitted")
      {:asm_not_found_in_acu_schedule} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Member is not found in acu schedule")
      {:batch_not_exist} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Error Creating Batch please attached soa first")
      _ ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Error updating member")
    end
  end

  # def submit_batch(conn, params) do
  #   conn
  #   |> put_status(404)
  #   |> render(ErrorView, "error.json", message: "Invalid Parameters")
  # end

  def attach_soa_to_batch(conn, params) do
    with {:ok, acu_schedule} <- AcuScheduleContext.attach_soa(params),
         {:ok, batch} <- create_batch_for_acu_schedule(conn, acu_schedule)
    do
      Repo.update(Changeset.change acu_schedule, batch_id: batch.id)
      conn
      |> put_status(200)
      |> render(
        StatusView,
        "success.json"
      )
    else
      {:error_upload_params} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid Upload Parameters")
      {:error_base_64} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid Upload Base 64")
      {:error_nil_srn} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Please Attach Soa Reference Number")
      {:error_soa_ref_no} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Soa Reference Number Already Exists!")
      {:acu_schedule_not_found} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Acu Schedule Not Found")
      _ ->
        conn
        |> put_status(500)
        |> render(ErrorView, "error.json", message: "Server Error")
    end
  end

  defp create_batch_for_acu_schedule(conn, as) do
    batch_params = %{
      "soa_reference_no" => as.soa_reference_no,
      "soa_amount" => Decimal.new(0),
      "edited_soa_amount" => Decimal.new(0),
      "status" => "Submitted",
      "type" => "hospital_bill"
    }
    {:ok, batch} = BatchContext.create_submitted_batch(batch_params, PG.current_resource_api(conn).id)

    payor_batch_params = %{
      batch_no: batch.number,
      type: "HB",
      facility_id: PG.current_resource(conn).agent.provider.payorlink_facility_id,
      coverage: "ACU",
      soa_ref_no: as.soa_reference_no,
      soa_amount: "0",
      edit_soa_amount: "0",
      registered: "0",
      acu_schedule_batch_no: as.batch_no
    }

    url = "loa/batch/acu_schedule/create_batch"
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        with {:ok, response} <- UtilityContext.connect_to_api_put_with_token(token, url, payor_batch_params,  "Maxicar") do
          {:ok, response}
        else
          {:error, response} ->
            {:error, response}
          _ ->
            {:unable_to_login}
        end
      _ ->
        {:unable_to_login}
    end
    {:ok, batch}
  end

  def attach_soa_to_batch_v2(conn, params) do
    with {:ok, acu_schedule} <- AcuScheduleContext.attach_soa(params)
    do
      conn
      |> put_status(200)
      |> render(
        StatusView,
        "success.json"
      )
    else
      {:batch_no_invalid_type} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Batch No. Should Only Contain Numbers.")
      {:error_upload_params} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid Upload Parameters")
      {:error_base_64} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid Upload Base 64")
      {:error_nil_srn} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Please Attach Soa Reference Number")
      {:error_soa_ref_no} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Soa Reference Number Already Exists!")
      {:acu_schedule_not_found} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Acu Schedule Not Found")
      _ ->
        conn
        |> put_status(500)
        |> render(ErrorView, "error.json", message: "Server Error")
    end
  end


  def view_soa(conn, params) do
    with {:ok, soas} <- AcuScheduleContext.view_soa(params) do
      case soas do
        {:error, message} ->
          conn
          |> put_status(400)
          |> render(ErrorView, "error.json", message: "Error viewing data.")
        _ ->
          conn
          |> put_status(200)
          |> render(ProviderLinkWeb.Api.V1.AcuScheduleView, "view_soas.json", soas: soas)
      end
    else
      {:acu_schedule_not_found} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Acu Schedule Not Found")
      {:no_files_found} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "No Files Found")
      _ ->
        conn
        |> put_status(500)
        |> render(ErrorView, "error.json", message: "Server Error")
    end
  end

  def create_claims(conn, params) do
    user = PG.current_resource_api(conn)
    with {no_of_claim, nil} <- AcuScheduleContext.create_claim(user, params) do
      conn
      |> put_status(200)
      |> render(
        StatusView,
        "success2.json",
        claim: no_of_claim
      )
    else
      _ ->
        conn
        |> put_status(500)
        |> render(ErrorView, "error.json", message: "Server Error")
    end
  end

  defp check_submit_batch_valid_params(params) do
    required_keys = ["batch_no", "registered", "unregistered", "direct_cost", "gross_adjustment", "total_amount"]

    results = Enum.map(required_keys, fn k -> Map.has_key?(params, k) and params[k] != ""  and params[k] != [] and not is_nil(params[k]) end)

    if Enum.member?(results, false)  do
      keys_not_found =
        Enum.map(Enum.with_index(results), fn({result, i}) ->
          if result == false, do: "#{Enum.at(required_keys, i)} is required"
        end)
        |> Enum.uniq()
        |> List.delete(nil)

      {:error_params, Enum.join(keys_not_found, ", ")}
    else
      {:ok, params}
    end
  end

  defp check_image_params(image) do
    if (!is_nil(image) and image != "" and image != [])
       and (!is_nil(image["base_64_encoded"]) and image["base_64_encoded"] != "")
    do
      true
    else
      false
    end
  end

  defp validate_acu_schedule_member(as, asm) do
    asm_ids = for asm <- as.acu_schedule_members do
      asm.id
    end

    if asm.is_availed == true do
      {:asm_already_submitted}
    else

      if Enum.member?(asm_ids, asm.id) do
        {:ok}
      else
        {:asm_not_found_in_acu_schedule}
      end
    end
  end

  defp get_batch_by_acu_schedule(as) do
    batch =  BatchContext.get_batch_by_acu_schedule_id(as.id)
    if is_nil(batch) do
      {:batch_not_exist}
    else
      {:ok, batch}
    end
  end

  defp create_batch_loa(conn, asm, batch) do
    batch_loa_params =
      [%{
        loa_id: asm.loa_id,
        batch_id: batch.id,
        inserted_at: Ecto.DateTime.utc(),
        updated_at: Ecto.DateTime.utc()
      }]

    BatchContext.create_batch_loa(batch_loa_params)
    batch
  end

  # def acu_schedule_create_batch(conn, params) do
  #   with {:ok, params} <- check_create_batch_valid_params(params),
  #        false <- is_nil(PG.current_resource(conn)),
  #        as = %AcuSchedule{} <- AcuScheduleContext.get_schedule_by_batch_no(params["batch_no"]),
  #        {:ok} <- check_if_batch_is_already_created(as),
  #        batch = %Batch{} <- create_batch(conn, as, params),
  #        {:ok, response} <- create_batch_payorlink(conn, as, batch, params)
  #   do
  #     AcuScheduleContext.update_acu_schedule_amount(as, params, batch)
  #     update_all_asm_to_encoded(as, params)
  #     update_all_loa_to_availed(as, params)
  #     update_all_loa_to_forfeited(as, params)
  #     conn
  #     |> put_status(200)
  #     |> render(StatusView, "success.json")
  #   else
  #     {:error_params, message} ->
  #       conn
  #       |> put_status(404)
  #       |> render(ErrorView, "error.json", message: message)
  #     true ->
  #       conn
  #       |> put_status(404)
  #       |> render(ErrorView, "error.json", message: "Session expired")
  #     {:error, nil} ->
  #       conn
  #       |> put_status(404)
  #       |> render(ErrorView, "error.json", message: "ACU Schedule not found")
  #     {:batch_already_exist} ->
  #       conn
  #       |> put_status(404)
  #       |> render(ErrorView, "error.json", message: "Batch is already existed")
  #     {:error_creating_batch} ->
  #       conn
  #       |> put_status(404)
  #       |> render(ErrorView, "error.json", message: "Error Creating Batch please attached soa first")
  #     {:payorlink_error} ->
  #       conn
  #       |> put_status(404)
  #       |> render(ErrorView, "error.json", message: "Error Creating Batch in payorlink")
  #     _ ->
  #       conn
  #       |> put_status(404)
  #       |> render(ErrorView, "error.json", message: "Internal Server Error!")
  #   end
  # end

  def acu_schedule_submit_batch(conn, params) do
    with {:ok, params} <- get_params_from_base64_zip_file(params),
         {:ok, params} <- check_create_batch_valid_params(params),
         false <- is_nil(PG.current_resource_api(conn)),
         as = %AcuSchedule{} <- AcuScheduleContext.get_schedule_by_batch_no(params["batch_no"]),
         {:ok} <- check_if_batch_is_already_created(as),
         batch = %Batch{} <- create_batch(conn, as, params),
         {:ok, response} <- create_batch_payorlink(conn, as, batch, params)
    do
      AcuScheduleContext.update_acu_schedule_amount(as, params)
      Repo.update(Changeset.change as, batch_id: batch.id)
      update_all_asm_to_encoded(as, params)
      update_all_loa_to_availed(as, params)
      update_all_loa_to_forfeited(as, params)
      upload_photos_acu_schedule_worker(conn, as, params)
      conn
      |> put_status(200)
      |> render(StatusView, "success.json")
    else
      {:zip_base64_is_required} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "zip_base64 is required")
      {:zip_base64_is_invalid} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "zip_base64 is invalid")
      {:path_or_file_cannot_read} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Path or File cannot read")
      {:error_extacting} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Error in extracting zip file")
      {:error_params, message} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: message)
      true ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Session expired")
      {:error, nil} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "ACU Schedule not found")
      {:batch_already_exist} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Batch is already existed")
      {:error_creating_batch} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Error Creating Batch please attached soa first")
      {:payorlink_error} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Error Creating Batch in payorlink")
      _ ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Internal Server Error!")
    end
  end

  defp get_params_from_base64_zip_file(params) do
    with {:valid} <- validate_zip_base64(params["zip_base64"]),
         {:ok, file} <- Base.decode64(params["zip_base64"])
    do
      {:ok, [{_, map}]} = :zip.unzip(Base.decode64!(params["zip_base64"]), [:memory])
      Poison.decode(map)
    else
      {:invalid} ->
        {:zip_base64_is_required}
      :error ->
        {:zip_base64_is_invalid}
      {:error, :enoent} ->
        {:path_or_file_cannot_read}
      {:error, zip} ->
        {:error_extacting}
      _ ->
        {:internal_server_error}
    end
  end

  defp validate_zip_base64(nil), do: {:invalid}
  defp validate_zip_base64(""), do: {:invalid}
  defp validate_zip_base64([]), do: {:invalid}
  defp validate_zip_base64(_), do: {:valid}

  defp check_create_batch_valid_params(params) do
    required_keys = ["batch_no", "registered", "unregistered", "direct_cost", "gross_adjustment", "total_amount", "availed_ids"]

    results = Enum.map(required_keys, fn k -> Map.has_key?(params, k) and params[k] != ""  and params[k] != [] and not is_nil(params[k]) end)

    if Enum.member?(results, false)  do
      keys_not_found =
        Enum.map(Enum.with_index(results), fn({result, i}) ->
          if result == false, do: "#{Enum.at(required_keys, i)} is required"
        end)
        |> Enum.uniq()
        |> List.delete(nil)

      {:error_params, Enum.join(keys_not_found, ", ")}
    else
      {:ok, params}
    end
  end

  defp check_if_batch_is_already_created(as) do
    case BatchContext.get_batch_by_acu_schedule_id(as.id) do
      %Batch{} ->
        {:batch_already_exist}
      nil ->
        {:ok}
      _ ->
        {:internal_server_error}
    end
  end

  defp create_batch(conn, as, params) do
    batch_params = %{
      "soa_reference_no" => as.soa_reference_no,
      "soa_amount" => params["direct_cost"],
      "edited_soa_amount" => params["total_amount"],
      "status" => "Submitted",
      "type" => "hospital_bill",
      "acu_schedule_id" => as.id
    }
    with {:ok, batch} <- BatchContext.create_submitted_batch(batch_params, PG.current_resource_api(conn).id)
    do
      create_batch_loa_v2(as, params, batch)
      batch
    else
      {:error, changeset} ->
        {:error_creating_batch}
      _ ->
        {:internal_server_error}
    end
  end

  defp create_batch_loa_v2(as, params, batch) do
    #65535 maximum parameters can handle insert_all
    availed_ids = Enum.map(params["availed_ids"], &(&1["id"]))
    batch_loa_params =
      Enum.map(as.acu_schedule_members, fn(asm) ->
        if Enum.member?(availed_ids, asm.id) do
          %{
            loa_id: asm.loa_id,
            batch_id: batch.id,
            inserted_at: Ecto.DateTime.utc(),
            updated_at: Ecto.DateTime.utc()
          }
        end
      end)

    batch_loa_params =
      batch_loa_params
      |> Enum.uniq()
      |> List.delete(nil)

    batch_loa_count =
      batch_loa_params
      |> Enum.count()

    if batch_loa_count > 15000 do
      lists =
        batch_loa_params
        |> UtilityContext.partition_list(15000, [])

      Enum.map(lists, fn(x) ->
        BatchContext.create_batch_loa(x)
      end)
    else
      BatchContext.create_batch_loa(batch_loa_params)
    end
  end

  defp create_batch_payorlink(conn, as, batch, params) do
    if Application.get_env(:data, :env) == :test do
      {:ok, ""}
    else
      availed_ids = Enum.map(params["availed_ids"], &(&1["id"]))
      verified_ids = Enum.map(as.acu_schedule_members, fn(asm) ->
        if Enum.member?(availed_ids, asm.id) do
          asm.loa.payorlink_authorization_id
        end
      end)

      verified_ids =
        verified_ids
        |> Enum.uniq()
        |> List.delete(nil)

      forfeited_ids = Enum.map(as.acu_schedule_members, &(&1.id)) -- availed_ids

      forfeited_ids = Enum.map(as.acu_schedule_members, fn(asm) ->
        if Enum.member?(forfeited_ids, asm.id) do
          asm.loa.payorlink_authorization_id
        end
      end)

      forfeited_ids =
        forfeited_ids
        |> Enum.uniq()
        |> List.delete(nil)

      batch_params =
        %{
          soa_ref_no: as.soa_reference_no,
          soa_amount: params["direct_cost"],
          batch_no: batch.number,
          edited_soa_amount: params["total_amount"],
          estimate_no_of_claims: params["registered"],
          as_batch_no: as.batch_no,
          verified_ids: verified_ids,
          forfeited_ids: forfeited_ids,
          submitted_date: batch.updated_at
        }
        with {:ok, response} <- BatchContext.create_submitted_batch_payorlink(conn, batch_params)
        do
          {:ok, response}
        else
          {:unable_to_login} ->
            delete_batch(batch)
            {:payorlink_error}
          {:error, response} ->
            delete_batch(batch)
            {:payorlink_error}
          _ ->
            delete_batch(batch)
            {:internal_server_error}
        end
    end
  end


  defp update_all_asm_to_encoded(as, params) do
    availed_ids = Enum.map(params["availed_ids"], &(&1["id"]))
    AcuScheduleContext.update_all_asm_to_encoded(availed_ids)
  end

  defp update_all_loa_to_availed(as, params) do
    availed_ids = Enum.map(params["availed_ids"], &(&1["id"]))
    verified_ids = Enum.map(as.acu_schedule_members, fn(asm) ->
      if Enum.member?(availed_ids, asm.id) do
        asm.loa.id
      end
    end)

    verified_ids =
      verified_ids
      |> Enum.uniq()
      |> List.delete(nil)

    LoaContext.update_all_loa_to_availed(verified_ids)
  end

  defp update_all_loa_to_forfeited(as, params) do
    availed_ids = Enum.map(params["availed_ids"], &(&1["id"]))
    forfeited_ids = Enum.map(as.acu_schedule_members, &(&1.id)) -- availed_ids

    forfeited_ids = Enum.map(as.acu_schedule_members, fn(asm) ->
      if Enum.member?(forfeited_ids, asm.id) do
        asm.loa.id
      end
    end)

    forfeited_ids =
      forfeited_ids
      |> Enum.uniq()
      |> List.delete(nil)

    LoaContext.update_all_loa_to_forfeited(forfeited_ids)
  end

  def upload_photos_acu_schedule_worker(conn, as, params) do
    Exq.Enqueuer.start_link

    params["availed_ids"]
    |> Enum.map(&(
      Exq.Enqueuer
      |> Exq.Enqueuer.enqueue(
        "submit_acu_schedule_upload_job",
        "ProviderWorker.Job.SubmitAcuScheduleUploadJob",
        [&1, %{scheme: conn.scheme}]
      )
    ))
  end

  def acu_schedule_check_progress(conn, params) do
    batch_no = params["batch_no"]
    with {:ok} <- check_if_valid(batch_no),
         as = %AcuSchedule{} <- AcuScheduleContext.get_schedule_by_batch_no3(batch_no)
    do
      AcuScheduleContext.check_acu_schedule_progress_and_update_submitted(as)
      render(conn, "acu_schedule_progress.json", acu_schedule: as)
    else
      {:error, nil} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "ACU Schedule not found")
      {:invalid_parameter} ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Invalid parameter")
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "Provider not found")
      true ->
        conn
        |> put_status(404)
        |> render("acu_schedules.json", acu_schedules: [])
      _ ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "No ACU Schedules found")
    end
  end

  defp delete_batch(batch) do
    BatchContext.delete_batch_loas(batch)
    BatchContext.delete_batch(batch)
    BatchContext.rollback_sequence("batch_no")
  end

  def hide_acu_schedule(conn, %{"batch_no" => batch_no}) do
    with acu_schedule = %AcuSchedule{} <- AcuScheduleContext.get_acu_sched_by_batch_no(batch_no),
         {:valid} <- validate_batch_no(acu_schedule.hidden_from_mobile),
         {:ok, _} <- AcuScheduleContext.hide_acu_schedule(acu_schedule)
    do
      conn
      |> put_status(200)
      |> render(AcuScheduleView, "success.json", message: "ACU Schedule successfully hidden to mobile.")
    else
      {:invalid, message} ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: message)
      _ ->
        conn
        |> put_status(404)
        |> render(ErrorView, "error.json", message: "ACU Schedule not found.")
    end
  end

  def hide_acu_schedule(conn, _) do
    conn
    |> put_status(404)
    |> render(ErrorView, "error.json", message: "Error hiding acu schedule from mobile.")
  end

  defp validate_batch_no(true), do: {:invalid, "ACU Schedule already hidden from mobile.`"}
  defp validate_batch_no(false), do: {:valid}
  defp validate_batch_no(_), do: {:invalid, "Invalid ACU Schedule."}

end
