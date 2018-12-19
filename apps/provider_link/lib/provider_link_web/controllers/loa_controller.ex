defmodule ProviderLinkWeb.LoaController do
  use ProviderLinkWeb, :controller

  alias Data.Schemas.{
    Loa,
    LoaPackage,
    LoaProcedure,
    User,
    Specialization,
    File
  }

  alias Phoenix.View
  alias ProviderLinkWeb.LoaView
  alias Data.Contexts.{
    LoaContext,
    UserContext,
    DiagnosisContext,
    DoctorContext,
    ProcedureContext,
    MemberContext,
    ProviderContext,
    UtilityContext,
    BatchContext
  }

  alias ProviderLink.Guardian, as: PG
  alias Timex.Duration
  alias Data.Utilities.SMS
  alias ProviderLink.{
    EmailSmtp,
    Mailer
  }
  alias ProviderLinkWeb.Api.V1.LoaView

  #For LOAS Permissions
  # plug Guardian.Permissions.Bitwise,
  #   [handler: ProviderLinkWeb.FallbackController,
  #    one_of: [
  #      %{loas: [:manage_loas]},
  #      %{loas: [:access_loas]}
  #    ]] when action in [
  #      :index,
  #      :show,
  #    ]

  # plug Guardian.Permissions.Bitwise,
  #   [handler: ProviderLinkWeb.FallbackController,
  #    one_of: [%{loas: [:manage_loas]}
  #    ]] when not action in [
  #      :index,
  #      :show,
  #      :search_acu,
  #      :search_peme,
  #      :search_consult,
  #      :search_lab,
  #      :verified_loa
  #    ]

  # FOR Home Permissions
  # TODO: access in this module is currently failing if added
  # plug Guardian.Permissions.Bitwise,
  #   [handler: ProviderLinkWeb.FallbackController,
  #    one_of: [
  #      %{home: [:manage_home]},
  #      # %{home: [:access_home]},
  #    ]] when action in [
  #      :validate_member_by_details,
  #      :validate_member_by_card_number,
  #      :cancel_loa,
  #      :get_member_by_card_no
  #    ]

  # plug Guardian.Permissions.Bitwise,
  #   [handler: ProviderLinkWeb.FallbackController,
  #    one_of: [%{home: [:manage_loas]}
  #    ]] when not action in [
  #    ]

  def index(conn, _params) do
    changeset = Loa.changeset_cart(%Loa{})
    user =
      conn
      |> PG.current_resource()

    consults =
      "OP Consult"
      |> LoaContext.get_loa_by_coverage_by_provider_consult(
        user.agent.provider.id,
        false
      )

    labs =
      "OP Laboratory"
      |> LoaContext.get_loa_by_coverage_by_provider(
        user.agent.provider.id,
        false
      )

    acus =
      "ACU"
      |> LoaContext.get_loa_by_coverage_by_provider(
        user.agent.provider.id,
        false
      )
    # acus = LoaContext.dummy_data()

    pemes =
      "PEME"
      |> LoaContext.get_loa_by_coverage_by_provider(
        user.agent.provider.id,
        true
      )

    loa_carts =
      LoaContext.list_all_cart_loa()

    batch =
      BatchContext.list_all_batch_for_loa()

    conn
    |> render(
      "index.html",
      consults: consults,
      labs: labs,
      acus: acus,
      pemes: pemes,
      changeset: changeset,
      loa_carts: loa_carts,
      batch: batch
    )
  end

  def search_consult(conn, %{"search" => search_params}) do
    user =
      conn
      |> PG.current_resource()

    loas =
      search_params
      |> LoaContext.get_loa_by_coverage_by_provider_by_search(
        "OP Consult",
        user.agent.provider.id,
        false
      )

    conn
    |> render(ProviderLinkWeb.LoaView, "loas.json", loas: loas)
  end

  def search_consult(conn, %{}) do
    conn
    |> put_flash(:info, "Please insert search parameters")
    |> redirect(to: loa_path(conn, :index))
  end

  def search_lab(conn, %{"search" => search_params}) do
    user =
      conn
      |> PG.current_resource()

    loas =
      search_params
      |> LoaContext.get_loa_by_coverage_by_provider_by_search(
        "OP Laboratory",
        user.agent.provider.id,
        false
      )

    conn
    |> render(ProviderLinkWeb.LoaView, "loas.json", loas: loas)
  end

  def search_acu(conn, %{"search" => search_params}) do
    user =
      conn
      |> PG.current_resource()

    loas =
      search_params
      |> LoaContext.get_loa_by_coverage_by_provider_by_search(
        "ACU",
        user.agent.provider.id,
        false
      )

    conn
    |> render(ProviderLinkWeb.LoaView, "loas.json", loas: loas)
  end

  def search_peme(conn, %{"search" => search_params}) do
    user =
      conn
      |> PG.current_resource()

    loas =
      search_params
      |> LoaContext.get_loa_by_coverage_by_provider_by_search(
        "PEME",
        user.agent.provider.id,
        true
      )

    conn
    |> render(ProviderLinkWeb.LoaView, "loas.json", loas: loas)
  end

  def consult(conn, params) do
    user = PG.current_resource(conn)
    doctors = DoctorContext.get_all_affiliated_doctors(conn.assigns.current_user.agent.provider.id)
    changeset = Loa.create_changeset(%Loa{})
    loa = LoaContext.get_loa_by_id(params["id"])

    diagnoses = DiagnosisContext.payor_link_diagnosis(
      params, loa.card.member.payor.code, conn)
    specializations = LoaContext.get_all_specializations

    conn
    |> render("request_consult.html", diagnoses: diagnoses, loa: loa,
           doctors: doctors, changeset: changeset, user: user,
           conn: @conn, specializations: specializations)
  end

  def lab(conn, params) do
    user = PG.current_resource(conn)
    doctors = DoctorContext.get_all_doctors()
    changeset = Loa.create_changeset(%Loa{})
    loa = LoaContext.get_loa_by_id(params["id"])
    diagnoses = DiagnosisContext.payor_link_diagnosis(
      params, loa.card.member.payor.code, conn)
    procedures = ProcedureContext.payor_link_procedure(
      params, loa.card.member.payor.code, conn)

    render(conn, "request_lab_loa.html", diagnoses: diagnoses, procedures: procedures, loa: loa,
           doctors: doctors, changeset: changeset, user: user)
  end

  def ip(conn, _params) do
    render conn, "request_ip_loa.html"
  end

  def er(conn, _params) do
    render conn, "request_er_loa.html"
  end

  def peme(conn, _params) do
    render conn, "request_peme_loa.html"
  end

  def update_consult(conn, %{"id" => id, "loa" => params}) do
    with {:ok, loa} <- LoaContext.request_op_consult(conn, params)
    do
      loa = LoaContext.get_loa_by_id(loa.id)
      diagnosis =
      DiagnosisContext.get_payor_link_diagnosis(
        params["diagnosis_id"],
        loa.card.member.payor.code, conn)

      doctor_id = DoctorContext.get_doctor_by_pl_doctor_specialization_id(params["doctor_specialization_id"]).doctor_id
      with {:ok, loa_doctor} <- LoaContext.insert_loa_doctor(%{
                                  loa_id: loa.id,
                                  doctor_id: doctor_id
                                }),
           {:ok, loa_diagnosis} <- LoaContext.insert_loa_diagnosis(%{
                                  loa_id: loa.id,
                                  payorlink_diagnosis_id: params["diagnosis_id"],
                                  diagnosis_code: diagnosis["code"],
                                  diagnosis_description: diagnosis["description"]
                                })
      do
        conn
         |> put_flash(:info, "LOA Successfully Created")
         |> redirect(to: loa_path(conn, :index))
      end
    else
      {:error, message} ->
        user = PG.current_resource(conn)
        doctors = DoctorContext.get_all_doctors()
        changeset = Loa.create_changeset(%Loa{})

        loa = LoaContext.get_loa_by_id(id)

        diagnoses = DiagnosisContext.payor_link_diagnosis(
          params, loa.card.member.payor.code, conn)

        specializations = LoaContext.get_all_specializations

        conn
        |> put_flash(:error, message)
        |> redirect(to: loa_path(conn, :consult, id))

       _ ->
          user = PG.current_resource(conn)
          doctors = DoctorContext.get_all_doctors()
          changeset = Loa.create_changeset(%Loa{})

          loa = LoaContext.get_loa_by_id(id)

          diagnoses = DiagnosisContext.payor_link_diagnosis(
            params, loa.card.member.payor.code, conn)

          specializations = LoaContext.get_all_specializations

          conn
          |> put_flash(:error, "Error in requesting OP Consult")
          |> redirect(to: loa_path(conn, :consult, id))
    end
  end

  def update_lab(conn, %{"id" => id, "lab" => params}) do
    loa = LoaContext.get_loa_by_id(id)
    loa_number = "#{Enum.random(100000..999999)}"
    params =
      params
      |> Map.put("loa_number", loa_number)
      |> Map.put("status", "approved")
      #change to pending once payorlink approval is implemented

    with {:ok, loa_doctor} <- LoaContext.insert_loa_doctor(
      %{
        loa_id: loa.id,
        doctor_id: params["doctor_id"]
      }),
         {:ok, loa} <- LoaContext.update_loa(loa, params)
    do
      conn
      |> put_flash(:info, "LOA Successfully Created")
      |> redirect(to: loa_path(conn, :index))
    else
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Error creating LOA")
        |> redirect(to: loa_path(conn, :lab, id))
    end
  end

  def update_diagnosis(conn, params) do
    payor_code = params["loa"]["payor_code"]

    diagnosis = DiagnosisContext.get_payor_link_diagnosis(
      params["loa"]["diagnosis_id"], payor_code, conn)

    diagnosis_params = %{payorlink_diagnosis_id: params["loa"]["diagnosis_id"],
      diagnosis_code: diagnosis["code"],
      diagnosis_description: diagnosis["description"],
      loa_id: params["loa"]["loa_id"]}

    diagnosis = LoaContext.insert_loa_diagnosis!(diagnosis_params)

    for {counter, params} <- params["procedure"] do
      procedure = ProcedureContext.get_payor_link_payor_procedure(
        params["procedure_id"], payor_code, conn)

      params = %{procedure_code: procedure["payor_code"],
        procedure_description: procedure["payor_description"],
        loa_diagnosis_id: diagnosis.id, unit: params["unit"],
        amount: params["amount"]}

      LoaContext.insert_loa_procedure(params)
    end

    conn
    |> put_flash(:info, "Successfully added Disease/Procedrue")
    |> redirect(to: loa_path(conn, :lab, params["loa"]["loa_id"]))
  end

  def show_no_session(conn, %{"loe_no" => payorlinkone_loe_no, "paylink_user_id" => paylink_user_id, "valid" => valid}) do
    with user = %User{} <- UserContext.get_user_by_paylink_user_id(paylink_user_id),
         loa = %Loa{} <- LoaContext.get_loa_by_payorlinkone_loe_no(payorlinkone_loe_no, user.agent.provider_id)
    do
      provider = user.agent.provider.name
      changeset = Loa.changeset_status(%Loa{})
      action = loa_path(conn, :cancel_loa, loa)
      conn =
        conn
        |> assign(:current_user, user)
      render(
        conn,
        "show.html",
        loa: loa,
        changeset: changeset,
        action: action,
        provider: provider,
        paylink_user_id: paylink_user_id,
        session: "no",
        valid: valid,
        permission: nil
      )
    else
      nil ->
        conn
        |> put_flash(:error, "Loa not found!")
        |> redirect(to: "/sign_in")
      _ ->
        conn
        |> put_flash(:error, "You must be signed in to access that page.")
        |> redirect(to: "/sign_in")
    end
 end

 def show_no_session(conn, %{"loe_no" => payorlinkone_loe_no, "paylink_user_id" => paylink_user_id}) do
    with user = %User{} <- UserContext.get_user_by_paylink_user_id(paylink_user_id),
         loa = %Loa{} <- LoaContext.get_loa_by_payorlinkone_loe_no(payorlinkone_loe_no, user.agent.provider_id)
    do
      provider = user.agent.provider.name

      changeset = Loa.changeset_status(%Loa{})

      action =
        conn
        |> loa_path(:cancel_loa, loa)

      conn =
        conn
        |> assign(:current_user, user)

      conn
      |> render(
        "show.html",
        loa: loa,
        changeset: changeset,
        action: action,
        provider: provider,
        paylink_user_id: paylink_user_id,
        session: "no"
      )
    else
      nil ->
        conn
        |> put_flash(:error, "Loa not found!")
        |> redirect(to: "/sign_in")
      _ ->
        conn
        |> put_flash(:error, "You must be signed in to access that page.")
        |> redirect(to: "/sign_in")
    end
  end

  def show(conn, %{"id" => id, "valid" => valid}) do
    user = conn |> PG.current_resource()
    provider = user.agent.provider.name
    with loa = %Loa{} <- LoaContext.get_loa_by_id(id) do
      changeset = Loa.changeset_status(%Loa{})
      action = loa_path(conn, :cancel_loa, loa)
      render(conn, "show.html", loa: loa, changeset: changeset, action: action, provider: provider, session: "yes", valid: valid)
    else
      _ ->
        conn
        |> put_flash(:error, "LOA not found")
        |> redirect(to: page_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    pem = conn.private.guardian_default_claims["pem"]["loas"]
    user = PG.current_resource(conn)
    provider = user.agent.provider.name
    with loa = %Loa{} <- LoaContext.get_loa_by_id(id) do
      changeset = Loa.changeset_status(%Loa{})
      action = loa_path(conn, :cancel_loa, loa)
      render(conn, "show.html", loa: loa, changeset: changeset, action: action, provider: provider, session: "yes", permission: pem)
    else
      _ ->
        conn
        |> put_flash(:error, "LOA not found")
        |> redirect(to: page_path(conn, :index))
    end
  end

  def show_consult(conn, %{"id" => id}) do
    user = PG.current_resource(conn)
    provider = user.agent.provider.name
    loa = LoaContext.get_loa_by_id(id)

    changeset = Loa.changeset_status(%Loa{})
    action = loa_path(conn, :cancel_loa, loa)
    render(conn, "show_consult.html", loa: loa, changeset: changeset, action: action, provider: provider, session: "yes")
  end

  def show_consult_success(conn, %{"id" => id}) do
    user = PG.current_resource(conn)
    provider = user.agent.provider.name
    loa = LoaContext.get_loa_by_id(id)

    changeset = Loa.changeset_status(%Loa{})
    action = loa_path(conn, :cancel_loa, loa)
    conn
    |> put_flash(:info, "Successfully Rescheduled LOA")
    |> render("show_consult.html", loa: loa, changeset: changeset, action: action, provider: provider, session: "yes")
  end

  def verified(conn, %{"id" => loa_id, "loa" => loa_params}) do
    with false <- is_nil(loa_params["files"]),
         false <- Enum.empty?(loa_params["files"]),
         loa = %Loa{} <- LoaContext.get_loa_by_id(loa_id),
         {:ok, loa} <- LoaContext.insert_file(loa_params, loa_id),
         {:approved} <- approved_loa(loa)
    do
      verify_paylink(conn, loa, loa_params)
    else
      true ->
        conn
        |> put_flash(:error, "Please upload supporting documents")
        |> redirect_show(loa_id, loa_params)
      nil ->
        conn
        |> put_flash(:error, "LOA not found!")
        |> redirect_show(loa_id, loa_params)
      {:not_approved} ->
        conn
        |> put_flash(:error, "Failed to verify LOA due to status is not yet approved.")
        |> redirect_show(loa_id, loa_params)
      _ ->
        conn
        |> put_flash(:error, "Error inserting files")
        |> redirect(to: loa_path(conn, :show, loa_id))
    end
  end

  defp approved_loa(loa) do
    if String.downcase("#{loa.status}") == "approved" do
      {:approved}
    else
      {:not_approved}
    end
  end

  defp verify_paylink(conn, loa, loa_params) do
    if Map.has_key?(loa_params, "paylink_user_id") == false && not is_nil(loa_params["paylink_user_id"]) do
      redirect_show_with_swal(conn, loa.id, loa_params)
    else
      with {:ok, batch_no} <- UtilityContext.verify_otp_paylink_sign_in(loa) do
        {:ok, loa} = LoaContext.update_loa_batch_no(loa, batch_no)
        LoaContext.update_payorlink_loa_status(conn, loa)
        paylink_user_id = loa_params["paylink_user_id"]
        redirect(conn, to: "/loas/#{loa.id}/show")
      else
        _ ->
         paylink_user_id = loa_params["paylink_user_id"]
         redirect(conn, to: "/loas/#{loa.id}/show")
         # paylink_user_id = loa_params["paylink_user_id"]
         # redirect(conn, to: "/loas/#{loa.payorlinkone_loe_no}/show_loa_no_session/#{paylink_user_id}")
      end
    end
  end

  defp redirect_show_with_swal(conn, loa_id, loa_params) do
  if is_nil(loa_params["paylink_user_id"]) do
      conn
        |> redirect(to: loa_path(conn, :show, loa_id, swal: true))
    else
      loa =
        loa_id
        |> LoaContext.get_loa_by_id

      paylink_user_id = loa_params["paylink_user_id"]
      redirect(conn, to: "/loas/#{loa.payorlinkone_loe_no}/show_loa_no_session/#{paylink_user_id}")
    end
  end

  defp redirect_show(conn, loa_id, loa_params) do
    if is_nil(loa_params["paylink_user_id"]) do
      conn
      |> redirect(to: loa_path(conn, :show, loa_id))
    else
      loa =
        loa_id
        |> LoaContext.get_loa_by_id

      paylink_user_id = loa_params["paylink_user_id"]
      redirect(conn, to: "/loas/#{loa.payorlinkone_loe_no}/show_loa_no_session/#{paylink_user_id}")
    end
  end

  def verified(conn, %{"id" => loa_id}) do
    conn
    |> put_flash(:error, "Please upload supporting documents")
    |> redirect(to: loa_path(conn, :show, loa_id))
  end

  def show_otp(conn, %{"id" => id}) do
    user = PG.current_resource(conn)
    provider = user.agent.provider.name
    loa = LoaContext.get_loa_by_id(id)

    if loa.otp != true do

      if is_nil(loa.pin_expires_at) do
        {:ok, loa} = LoaContext.insert_pin(loa)

        if not is_nil(loa.card.member.mobile) do
          # transform number to 639
          member_mobile = SMS.transforms_number(loa.card.member.mobile)
          SMS.send(%{text: "Your verification code is #{loa.pin} with LOA Number: #{loa.loa_number}", to: member_mobile})
          conn.assigns.current_user
          |> EmailSmtp.send_pin(loa)
          |> Mailer.deliver_now()
        end

      end

      render(conn, "verification_type/show_otp.html", loa: loa, provider: provider, expiry: loa.pin_expires_at)
    else
      conn
      |> put_flash(:error, "LOA already consumated")
      |> redirect(to: loa_path(conn, :show, loa.id))
    end

    render(conn, "verification_type/show_otp.html", loa: loa, provider: provider, expiry: loa.pin_expires_at)
  end

  def print_original_evoucher(conn, params) do
    with {:ok, loa} <- get_peme_loa(params["id"]),
         {:ok, html} <- validate_evoucher(conn, loa, params["print_qrcode_evoucher"]),
         {:ok, filename} <- create_filename(loa, loa.is_peme),
         {:ok, content} <- PdfGenerator.generate_binary(html,
            filename: filename,
            delete_temporary: true)
    do
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "inline; filename=#{filename}.pdf")
        |> send_resp(200, content)
    else
      {:error} ->
        conn
        |> put_flash(:error, "Failed to print authorization.")
        |> redirect(to: "/loas/#{params["id"]}/show_peme")
      _ ->
        conn
        |> put_flash(:error, "Failed to print authorization.")
        |> redirect(to: "/loas/#{params["id"]}/show")
    end
  end

  defp get_peme_loa(nil), do: {:error}
  defp get_peme_loa(id), do: get_peme_loa_v2(LoaContext.get_loa_by_id(id))
  defp get_peme_loa_v2(nil), do: {:error}
  defp get_peme_loa_v2(loa), do: {:ok, loa}

  defp validate_evoucher(nil, _, _), do: {:error}
  defp validate_evoucher(_, nil, _), do: {:error}
  defp validate_evoucher(_, _, nil), do: {:error}
  defp validate_evoucher(conn, loa, canvas), do: validate_evoucher_v2(conn, loa, loa.coverage, loa.otp, canvas)

  defp validate_evoucher_v2(_, _, nil, _, _), do: {:error}
  defp validate_evoucher_v2(_, _, _, nil, _), do: {:error}
  defp validate_evoucher_v2(conn, loa, "OP Consult", _, canvas), do: validate_evoucher_v3(conn, loa, canvas, "print/original_op_consult_loa.html")
  defp validate_evoucher_v2(conn, loa, "ACU", true, canvas), do: validate_evoucher_v3(conn, loa, canvas, "print/availed_e-voucher.html")
  defp validate_evoucher_v2(conn, loa, "ACU", _, canvas), do: validate_evoucher_v3(conn, loa, canvas, "print/original_e-voucher.html")
  defp validate_evoucher_v2(conn, loa, "PEME", true, canvas), do: validate_evoucher_v3(conn, loa, canvas, "print/availed_peme.html")
  defp validate_evoucher_v2(conn, loa, "PEME", _, canvas), do: validate_evoucher_v3(conn, loa, canvas, "print/original_peme.html")

  defp validate_evoucher_v3(conn, loa, canvas, html) do
    {:ok, View.render_to_string(
      ProviderLinkWeb.LoaView,
      html,
      loa: loa,
      canvas: canvas,
      conn: conn
    )}
  end

  defp unique_id() do
    {date, time} = :erlang.localtime()
    Enum.join(Tuple.to_list(date)) <> Enum.join(Tuple.to_list(time))
  end

  defp create_filename(nil, _), do: {:error}
  defp create_filename(_, nil), do: {:error}
  defp create_filename(loa, true), do: {:ok, "#{loa.member_evoucher_number}_#{unique_id()}"}
  defp create_filename(_, _), do: {:ok, "print_auth"}

  def card_no_cvv_verify(conn, %{"id" => id}) do
    user = PG.current_resource(conn)
    provider = user.agent.provider.name
    loa = LoaContext.get_loa_by_id(id)
    render(conn, "verification_type/card_no_cvv.html", loa: loa, provider: provider)
  end

  def show_verified(conn, %{"id" => id}) do
    user = PG.current_resource(conn)
    provider = user.agent.provider.name
    loa = LoaContext.get_loa_by_id(id)
    with {:ok, loa} <- LoaContext.verify_otp(loa) do
      changeset = Loa.changeset_status(%Loa{})
      action = loa_path(conn, :cancel_loa, loa)
      render(conn, "show.html", loa: loa, changeset: changeset, action: action, provider: provider)
    else
      _ ->
      changeset = Loa.changeset_status(%Loa{})
      action = loa_path(conn, :cancel_loa, loa)
      render(conn, "show.html", loa: loa, changeset: changeset, action: action, provider: provider)
    end
  end

  def show_cancel(conn, %{"loe_no" => loe_no, "paylink_user_id" => paylink_user_id}) do
    with user = %User{} <- UserContext.get_user_by_paylink_user_id(paylink_user_id),
         loa = %Loa{} <- LoaContext.get_loa_by_payorlinkone_loe_no(loe_no, user.agent.provider.id)
    do
      changeset = Loa.changeset_status(%Loa{})
      action = loa_path(conn, :cancel_loa, loa)
      render(conn, "modal_cancel.html",
        user: user,
        loa: loa,
        changeset: changeset,
        action: action,
        provider: user.agent.provider.name,
        session: "yes",
        paylink_user_id: paylink_user_id
      )
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid LOA")
        |> redirect(to: page_path(conn, :index))
    end
  end

  def cancel_loa(conn, %{"id" => id}) do
    with %Loa{} = loa <- LoaContext.get_loa_by_id(id),
         {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
         {:ok, response} <- UtilityContext.connect_to_api_get_with_token(
                            token, "loa/cancel/#{loa.payorlink_authorization_id}",
                            "Maxicar")
    do
      decoded = Poison.decode!(response.body)
      cancel_loa_return(conn, loa, decoded["message"])
    else
      _ ->
        render(conn, LoaView, "message.json", message: "fail")
    end
  rescue
    _ ->
      render(conn, LoaView, "message.json", message: "fail")
  end

  defp cancel_loa_return(conn, loa, "success") do
    with {:ok, loa} <- LoaContext.cancel_loa(loa) do
      render(conn, LoaView, "message.json", message: "success")
    else
      _ ->
        render(conn, LoaView, "message.json", message: "fail")
    end
  end

  defp cancel_loa_return(conn, _, message), do: render(conn, LoaView, "message.json", message: Enum.join(["Payorlink: ", message]))

  def cancel_loa_no_session(conn, %{"loe_no" => loe_no, "paylink_user_id" => paylink_user_id}) do
    user = UserContext.get_user_by_paylink_user_id(paylink_user_id)
    loa = LoaContext.get_loa_by_payorlinkone_loe_no(loe_no,
          user.agent.provider_id
        )
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/cancel/#{loa.payorlink_authorization_id}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            cancel_loa_return_no_session(conn, loa, decoded["message"])
            _ ->
             render(conn, LoaView, "message.json", message: "fail")
        end
      _ ->
        render(conn, LoaView, "message.json", message: "fail")
    end
  end

  defp cancel_loa_return_no_session(conn, loa, message) do
    if message == "success" do
      with true <- UtilityContext.update_status_paylink_sign_in(loa.payorlinkone_claim_no) do
         with {:ok, loa} <- LoaContext.cancel_loa(loa) do
            render(conn, LoaView, "message.json", message: "success")
          else
            {:error, _changeset} ->
              render(conn, LoaView, "message.json", message: "fail")
          end
      else
        _ ->
        render(conn, LoaView, "message.json", message: "fail")
      end
    else
      render(conn, LoaView, "message.json", message: "fail")
    end
  end

  def package_info(conn, %{
      "card_no" => card_no,
      "verification" => verification_type,
      "loa_id" => loa_id
    })
  do
    loa = LoaContext.get_loa_by_id(loa_id)
    user = conn.assigns.current_user
    cond do
      String.downcase(loa.coverage) == "acu" ->
        if loa.otp do
          redirect(conn, to: loa_path(conn, :show, loa.id))
        else
          changeset = Loa.changeset_status(%Loa{})
          # member = MemberContext.get_acu_member(member_id)
          acu_details = acu_details(loa)
          render(
            conn,
            "form_package_info.html",
            changeset: changeset,
            # member: member,
            acu_details: acu_details,
            disabled: "",
            loa_id: loa.id,
            loa: loa,
            user: user
          )
        end
      String.downcase(loa.coverage) == "peme" ->
        changeset = Loa.changeset_status(%Loa{})
        peme_details = peme_details(loa)
        render(
          conn,
          "peme/peme_package_info.html",
          changeset: changeset,
          loa: loa,
          peme_details: peme_details,
          disabled: "",
          user: user
        )
      true ->

    end

  end

  def package_info_no_session(conn, %{"loe_no" => payorlinkone_loe_no, "verification" => verification_type, "paylink_user_id" => paylink_user_id}) do
    with user = %User{} <- UserContext.get_user_by_paylink_user_id(paylink_user_id) do

      loa =
        payorlinkone_loe_no
        |> LoaContext.get_loa_by_payorlinkone_loe_no(
          user.agent.provider_id
        )
      loa_params =
        %{
          "paylink_user_id" => paylink_user_id
        }
      # conn =
      #   conn
      #   |> assign(:current_user, user)
      #   |> assign(:paylink_user_id, paylink_user_id)
      #   |> assign(:loe_no, loa.payorlinkone_loe_no)
      redirect_show(conn, loa.id, loa_params)
    else
      _ ->
        conn
        |> put_flash(:error, "You must be signed in to access that page.")
        |> redirect(to: "/sign_in")
    end
  end

  def package_info(conn, %{"id" => id, "verification" => verification_type}) do
    user = conn.assigns.current_user
    provider = user.agent.provider
    loa = LoaContext.get_loa_by_id(id)
    params = %{
      facility_code: provider.code,
      coverage_code: "ACU",
      card_no: loa.member_card_no
    }
      response =
        loa
        |> acu_details()
        |> Map.put("verification_type", verification_type)
      changeset = Loa.create_changeset(%Loa{})

      if Map.has_key?(conn.assigns, :paylink_user_id) do
        user = UserContext.get_user_by_paylink_user_id(conn.assigns.paylink_user_id)
        loa = LoaContext.get_loa_by_payorlinkone_loe_no(conn.assigns.loe_no, user.agent.provider.id)

      render(
        conn,
        "form_package_info_no_session.html",
         changeset: changeset,
         # member: member,
         acu_details: response,
         disabled: "",
         paylink_user_id: conn.assigns.paylink_user_id,
         user: user,
         loa: loa
      )
      else

      loa_params = %{
        "amount" => response["package_facility_rate"],
        "authorization_id" => loa.payorlink_authorization_id,
        "card_no" => loa.member_card_no,
        "facility_code" => provider.code,
        "loa_id" => loa.id,
        # "member_id" => member.id,
        # "valid_until" => member.expiry_date,
        "verification_type" => verification_type
      }

      conn
      |> request_loa_acu(
        loa_params,
        user
      )

      # render(
      #   conn,
      #   "form_package_info.html",
      #    changeset: changeset,
      #    member: member,
      #    acu_details: response,
      #    disabled: "",
      #    user: user
      # )
      end
  end

  def request_loa_acu_no_session(conn, %{"loa" => loa_params, "paylink_user_id" => paylink_user_id}) do
    user =
      paylink_user_id
      |> UserContext.get_user_by_paylink_user_id

    conn
    |> request_loa_acu(
      loa_params,
      user
    )
  end

  def request_loa_acu(conn, %{"loa" => loa_params}) do
    user = conn.assigns.current_user
    conn
    |> request_loa_acu(
      loa_params,
      user
    )
  end

  defp request_loa_acu(conn, loa_params, user) do
    provider = user.agent.provider
    loa_id = loa_params["loa_id"]
    if is_nil(loa_id) do
      loa =
        loa_params["paylink_loe_no"]
        |> LoaContext.get_loa_by_payorlinkone_loe_no(
          user.agent.provider_id)
      loa_id = loa.id
    else
      loa_id = loa_id
    end
    loa_params = Map.put(loa_params, "facility_code", provider.code)

    with {:ok, loa} <- LoaContext.request_update_loa_acu(conn, loa_params) do
      #redirect_show_with_swal(conn, loa_id, loa_params)
      conn
      |> put_flash(:info, "LOA has been approved")
      |> redirect_show(loa_id, loa_params)
    else
      {:error, "Internal server error"} ->
        conn
        |> put_flash(:error, "Error when getting data from payor_link ")
        |> redirect(to: loa_path(conn, :show, loa_id))
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: loa_path(conn, :show, loa_id))
      {:error_connecting} ->
        conn
        |> put_flash(:error, "Error when connecting to payorlink")
        |> redirect(to: loa_path(conn, :show, loa_id))
       _ ->
        conn
        |> put_flash(:error, "Invalid parameters")
        |> redirect(to: loa_path(conn, :show, loa_id))
    end
  end

  defp check_package_facility_rate(params) do
    rate = String.trim("#{params["package_facility_rate"]}")
    if rate == "" or is_nil(rate) do
      {:no_rate}
    else
      {:has_rate}
    end
  end

  defp acu_details(loa) do
    acu_type = String.split(loa.acu_type, "-")
    %{
      "acu_coverage" => String.trim(Enum.at(acu_type, 1)),
      "acu_type" => Enum.at(acu_type, 0),
      "benefit_package_id" => List.first(loa.loa_packages).payorlink_benefit_package_id,
      "benefit_provdier_access" => List.first(loa.loa_packages).payorlink_benefit_package_id,
      "package" => %{
        "code" => List.first(loa.loa_packages).code,
        "name" => List.first(loa.loa_packages).description
      },
      "package_facility_rate" => loa.total_amount,
      "payor_pays" => loa.payor_pays,
      "member_pays" => loa.member_pays,
      "payor_procedure" => procedure_details(loa.loa_procedures),
      "benefit_provider_access" => List.first(loa.loa_packages).benefit_provider_access
    }
  end

  defp peme_details(loa) do
    %{
      "benefit_package_id" => List.first(loa.loa_packages).payorlink_benefit_package_id,
      "benefit_provdier_access" => List.first(loa.loa_packages).payorlink_benefit_package_id,
      "package" => %{
        "code" => List.first(loa.loa_packages).code,
        "name" => List.first(loa.loa_packages).description
      },
      "package_facility_rate" => loa.total_amount,
      "payor_pays" => loa.payor_pays,
      "member_pays" => loa.member_pays,
      "payor_procedure" => procedure_details(loa.loa_procedures),
      "benefit_provider_access" => List.first(loa.loa_packages).benefit_provider_access
    }
  end

  defp procedure_details([]), do: []
  defp procedure_details(params) do
    Enum.map(params, fn(param) ->
      %{
        "id" => param.payorlink_procedure_id ,
        "code" => param.procedure_code,
        "description" => param.procedure_description
       }
    end)
  end

  defp acu_params(user, provider, loa_params) do
    loa_params
    |> Map.put("card_no", loa_params["card_no"])
    |> Map.put("facility_code", provider.code)
    |> Map.put("provider_id", provider.id)
    |> Map.put("user_id", user.id)
    |> Map.put("coverage_code", "ACU")
    |> Map.put("acu_type", Enum.join([loa_params["acu_type"], loa_params["acu_coverage"]]))
    |> Map.put("payor_pays", loa_params["amount"])
    |> Map.put("total_amount", loa_params["amount"])
    |> Map.put("origin", "providerlink")
  end

  def validate_pin(conn, %{"id" => id, "pin" => pin}) do
    case LoaContext.validate_pin(id, pin) do
      {:ok} ->
        loa =
          id
          |> LoaContext.get_loa_by_id()

        loa
        |> MemberContext.tag_loa_as_verified()

        conn
        |> render(
          ProviderLinkWeb.Api.V1.LoaView,
          "message2.json",
          message: "Successfully Availed LOA",
          valid: true
        )
      {:member_not_found} ->
        conn
        |> render(
          ProviderLinkWeb.Api.V1.LoaView,
          "message2.json",
          message: "Loa Not Found!",
          valid: false
        )
      {:invalid_pin_length} ->
        conn
        |> render(
          ProviderLinkWeb.Api.V1.LoaView,
          "message2.json",
          message: "OTP should be 4-digit",
          valid: false
        )
      {:expired} ->
        conn
        |> render(
          ProviderLinkWeb.Api.V1.LoaView,
          "message2.json",
          message: "The 4-Digit PIN Code that you have entered is already expired.",
          valid: false
        )
        _ ->
        conn
        |> render(
          ProviderLinkWeb.Api.V1.LoaView,
          "message2.json",
          message: "Error authenticating PIN Code",
          valid: false
        )
    end
  end

  def send_pin(conn, %{"id" => id}) do
   loa = LoaContext.get_loa_by_id(id)
    {:ok, loa} = LoaContext.insert_pin(loa)
    if not is_nil(loa.card.member.mobile) do
      # transform number to 639
      member_mobile = SMS.transforms_number(loa.card.member.mobile)
      SMS.send(%{text: "Your verification code is #{loa.pin} with LOA Number: #{loa.loa_number}", to: member_mobile})
    end

    conn
    |> render(
      ProviderLinkWeb.LoaView,
      "loa_pin.json",
      loa: loa
    )
  end

  def verify_swipe_card(conn, %{"id" => id, "card" => card_no}) do
    with {:ok, %Loa{} = loa} <- MemberContext.verify_swipe_card(conn, card_no, id)
    do
      conn
      |> render(ProviderLinkWeb.LoaView, "message.json", valid: true, message: "Successfully Availed LOA")
    else
      {error, message} ->
        conn
        |> render(ProviderLinkWeb.LoaView, "message.json", valid: false, message: message)
    end
  end

  def verify_cvv(conn, %{"id" => id, "cvv" => cvv}) do
    with {:ok, %Loa{} = loa} <- MemberContext.verify_cvv(conn, cvv, id)
    do
      conn
      |> render(ProviderLinkWeb.LoaView, "message.json", valid: true, message: "Successfully Availed LOA")
    else
      {error, message} ->
        conn
        |> render(ProviderLinkWeb.LoaView, "message.json", valid: false, message: message)
    end
  end

  def request_loa_peme(conn, %{"loa" => loa_params}) do
    user = conn.assigns.current_user
    conn
    |> request_loa_acu(
      loa_params,
      user
    )
  end

  def request_peme(conn, params) do
    member = MemberContext.get_acu_member(params["id"])
    peme =
    params["peme"]
    |> Map.put("birth_date", UtilityContext.format_date(params["peme"]["birth_date"]))
    |> Map.put("birthdate", UtilityContext.format_date(params["peme"]["birth_date"]))
    |> Map.put("member_id", member.payorlink_member_id)

    params =
    params
    |> Map.put("user_id", conn.assigns.current_user.id)
    |> Map.put("member_id", params["id"])

    member = MemberContext.update_accountlink_member(member, peme)

    url = "member/update_peme_member"
    case UtilityContext.connect_to_api_post(conn, "Maxicar", url, peme) do
      {:ok, response} ->
      decoded = Poison.decode!(response.body)
      peme_params =
        %{
         facility_code: conn.assigns.current_user.agent.provider.code,
         coverage_code: "ACU",
         member_id: member.payorlink_member_id
        }
      with {:ok, response} <- LoaContext.get_peme_details(conn, peme_params),
           false <- Enum.empty?(response["payor_procedure"]),
           true <- Enum.empty?(LoaContext.get_loas_by_member(member.id)),
           {:ok, loa} <- LoaContext.request_loa_peme(conn, params, response)
      do
          conn
          |> redirect(to: loa_path(conn, :show, loa))
      else
        {:error, message} ->
          conn
          |> put_flash(:error, message)
          |> redirect(to: page_path(conn, :index))
        true ->
          conn
          |> put_flash(:error, "Member is not eligible to avail ACU in this Hospital/Clinic.")
          |> redirect(to: page_path(conn, :index))
        false ->
          loa = LoaContext.get_loas_by_member_id(member.card.id)
          loa = loa |> List.first()
          conn
          |> put_flash(:error, "Already have LOA")
          |> redirect(to: page_path(conn, :index))
        _ ->
          conn
          |> put_flash(:error, "Error")
          |> redirect(to: page_path(conn, :index))
      end
      _ ->
       render(conn, MemberView, "message.json", message: "fail")
    end
  end

  def reschedule_loa(conn, %{"id" => id}) do
     params = %{
     loa_id: id
    }
    loa = LoaContext.get_loa_by_id(id)
    with {:ok, new_loa} <- LoaContext.reschedule_loa(conn, params)
    do
      params = %{
        loa_id: new_loa.id,
      }
           json conn, params
    else
      _ ->
        conn
    end
  end

  def filter_doctor_specialization(conn, %{"facility_id" => facility_id, "name" => name}) do
    result = DoctorContext.filter_affiliated_doctor_specialization(facility_id, name)
    json(conn, Poison.encode!(result))
  end

  def filter_all_doctor_specialization(conn, %{"facility_id" => facility_id}) do
    result = DoctorContext.filter_affiliated_doctor(facility_id)
    json(conn, Poison.encode!(result))
  end

  def cancel_loa_request(conn, %{"id" => id}) do
    with {:ok, loa} <- LoaContext.delete_loa_by_id(id) do
      conn
      |> put_flash(:info, "Request successfully deleted")
      |> redirect(to: loa_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:info, "Error canceling request")
        |> redirect(to: "/loas/#{id}/request/consult")
    end
  end
  #TODO

  def verified_loa(conn, %{"id" => loa_id, "loa" => loa_params}) do
      if is_nil(loa_params["selected_package"]) or loa_params["selected_package"] == "" do
          loa_params = if is_nil(loa_params["discharge_date"]) do
            Map.merge(loa_params,
            %{
              "admission_date" => "#{Ecto.DateTime.to_date(Ecto.DateTime.from_erl(:erlang.localtime))}",
              "discharge_date" => "#{Ecto.DateTime.to_date(Ecto.DateTime.from_erl(:erlang.localtime))}"
            })
          else
            Map.merge(loa_params,
            %{
              "admission_date" => loa_params["admission_date"],
              "discharge_date" => loa_params["discharge_date"]
            })
          end
        with false <- is_nil(loa_params["files"]),
             false <- Enum.empty?(loa_params["files"]),
             {:success} <- LoaContext.insert_file(loa_params, loa_id),
             loa = %Loa{} <- LoaContext.get_loa_by_id(loa_id),
             {:approved} <- approved_loa(loa),
             {:ok, _loa} <- LoaContext.request_verified_loa_acu(conn, loa_params),
             # {:ok, loa} <- LoaContext.update_payorlink_loa_status(conn, loa),
             {:ok, loa} <- LoaContext.verify_loa_payorlink(loa_params, loa_id)
        do
          if is_nil(loa_params["paylink_user"]) do
            loa = LoaContext.get_loa_by_id(loa.id)
            create_batch_for_acu_clinic(conn, loa, loa_params)
            redirect(conn, to: "/loas/#{loa.id}/show")
          else
            verify_paylink(conn, loa, loa_params)
          end

        else
          nil ->
            conn
            |> put_flash(:error, "LOA not found!")
            |> redirect_show(loa_id, loa_params)
          {:not_approved} ->
            conn
            |> put_flash(:error, "Failed to verify LOA due to status is not yet approved.")
            |> redirect_show(loa_id, loa_params)
          {:error, message} ->
            conn
            |> put_flash(:error, message)
            |> redirect_show(loa_id, loa_params)
          true ->
            conn
            |> put_flash(:error, "Please upload Statement of Account (SOA)")
            |> redirect_show(loa_id, loa_params)
          _ ->
            conn
            |> put_flash(:error, "Error")
            |> redirect(to: loa_path(conn, :show, loa_id))
        end
      else
        LoaContext.delete_loa_package_not_selected(loa_params)
        loa = LoaContext.get_loa_by_id(loa_id)
        if not is_nil(loa) do
          params =
          %{
            "authorization_id" => loa.payorlink_authorization_id,
            "loa_number" => loa.loa_number,
            "benefit_package_id" => List.first(loa.loa_packages).payorlink_benefit_package_id,
            "benefit_code" => List.first(loa.loa_packages).benefit_code,
            "benefit_provider_access" => List.first(loa.loa_packages).benefit_provider_access,
            "limit_amount" => List.first(loa.loa_packages).loa_limit_amount,
            "package" =>
            %{
              "code" => List.first(loa.loa_packages).code,
              "name" => List.first(loa.loa_packages).description
            },
            "package_facility_rate" => List.first(loa.loa_packages).amount,
            "payor_procedure" =>
            %{
              "id" => List.first(loa.loa_procedures).payorlink_procedure_id,
              "code" => List.first(loa.loa_procedures).procedure_code,
              "description" => List.first(loa.loa_procedures).procedure_description
            },
            "acu_type" => List.first(loa.loa_packages).loa_benefit_acu_type,
            "payor_pays" => ProviderLinkWeb.LoaView.loa_pays(List.first(loa.loa_packages)).payor_pays,
            "member_pays" => ProviderLinkWeb.LoaView.loa_pays(List.first(loa.loa_packages)).member_pays,
            "total_amount" => ProviderLinkWeb.LoaView.loa_pays(List.first(loa.loa_packages)).total_amount
          }
          params = if is_nil(loa_params["discharge_date"]) do
            Map.merge(params,
            %{
              "admission_date" => "#{Ecto.DateTime.to_date(Ecto.DateTime.from_erl(:erlang.localtime))}",
              "discharge_date" => "#{Ecto.DateTime.to_date(Ecto.DateTime.from_erl(:erlang.localtime))}"
            })
          else
            Map.merge(params,
            %{
              "admission_date" => loa_params["admission_date"],
              "discharge_date" => loa_params["discharge_date"]
            })
          end

          with {:ok, loa} <- LoaContext.request_update_loa_acu(conn, loa, params) do
            conn
            |> redirect(to: "/loas/#{loa.id}/show")
          else
            _ ->
              conn
              |> put_flash(:error, "Error")
              |> redirect(to: "/loas/#{loa.id}/show")
          end
        else
          conn
          |> put_flash(:error, "LOA not found!")
          |> redirect(to: "/loas/#{loa.id}/show")
        end
      end
    rescue
      ErlangError ->
        conn
        |> put_flash(:error, "Timeout error")
        |> redirect(to: "/loas/#{loa_id}/show")
  end

  def save_discharge_date(
    conn,
    %{
      "discharge_date" => discharge_date,
      "loa_id" => loa_id
    }
  ) do
    LoaContext.save_discharge_date(loa_id, discharge_date)

    conn
    |> json(%{status: "success"})
  end

  def add_to_cart(conn, params) do
    loa = params["loa"]
    loa_ids = loa["loa_ids"]
    if loa_ids == "" do
      conn
      |> put_flash(:error, "Please select at least one (1) LOA.")
      |> redirect(to: loa_path(conn, :index))
    else
      loa_ids = String.split(loa_ids, ",")
    end
    with {:ok, is_cart} <- LoaContext.update_all_loa(loa_ids) do
      conn
      |> put_flash(:info, "LOA Successfully added to cart")
      |> redirect(to: loa_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Error adding items to cart")
        |> redirect(to: loa_path(conn, :index))
    end
  end

  def list_cart(conn, params) do
    loas = LoaContext.list_all_cart_loa()
  end

  # def add_to_cart(conn, params) do
  #   ids = params["ids"]
  #   params = Poison.decode!(ids)
  #   with {:ok, loa} <- LoaContext.update_loa_cart(params) do
  #     conn
  #     |> put_flash(:info, "LOA added to cart")
  #     |> redirect(to: loa_path(conn, :index))
  #   else
  #     {:not_found} ->
  #     conn
  #     |> put_flash(:error, "LOA not found!")
  #     |> redirect(to: loa_path(conn, :index))
  #     _ ->
  #     conn
  #     |> put_flash(:error, "Error Adding to cart!")
  #     |> redirect(to: loa_path(conn, :index))
  #   end
  # end

  def add_to_batch(conn, %{"loa_batch" => loa_batch}) do
    batch = BatchContext.get_batch_by_number(loa_batch["batch_no"])
    loa_ids = LoaContext.list_all_cart_loa_ids()
    if not Enum.empty?(loa_ids) do
      with true <- LoaContext.loa_batch_existing_op_consult_checker(loa_ids, batch),
           {:ok, loa_ids} <- LoaContext.loa_doctor_checker(loa_ids, batch.id),
           {:ok, batch_loa} <- BatchContext.add_loa_to_batch(batch.id, loa_ids)
      do
        conn
        |> put_flash(:info, "LOAs added to batch")
        |> redirect(to: batch_path(conn, :batch_details, batch.id))
      else
        false ->
          conn
          |> put_flash(:error, "Coverage must only be OP Consult.")
          |> redirect(to: loa_path(conn, :index))
        {:not_equal_doctor_id} ->
          conn
          |> put_flash(:error, "You are not allowed to add LOA to the batch reason: LOA has different practitioner")
          |> redirect(to: loa_path(conn, :index))
        {:not_found} ->
          conn
          |> put_flash(:error, "LOA not found!")
          |> redirect(to: loa_path(conn, :index))
        {:already_submitted} ->
          conn
          |> put_flash(:error, "Batch already submitted")
          |> redirect(to: loa_path(conn, :index))
        _ ->
          conn
          |> put_flash(:error, "error adding to batch!")
          |> redirect(to: loa_path(conn, :index))
      end
    else
      conn
      |> put_flash(:error, "no loas found")
      |> redirect(to: loa_path(conn, :index))
    end
  end

  def remove_to_cart(conn, %{"id" => id}) do
    LoaContext.remove_loa_cart(id)

    loa = LoaContext.list_all_cart_loa()
    conn
    |> render(LoaView, "loa_cart.json", loa: loa)
  end

  # TODO

  def submit_loa_peme(conn, %{"id" => id, "coverage" => coverage}) do
    loa = LoaContext.get_loa_by_id(id)
    with {:ok, payorlink_loa} <- LoaContext.approve_payorlink_loa_status(conn, loa),
          {:ok, loa} <- LoaContext.update_status(loa, payorlink_loa)
    do
      conn
      |> put_flash(:info, "LOA successfully generated.")
      |> redirect(to: "/loas/#{loa.id}/show_peme")
    else
      _ ->
        conn
        |> put_flash(:error, "Error in updating status in payorlink")
    end
    user = conn.assigns.current_user

  end

  def search_loa(conn, %{"value" => value}) do
    loas = LoaContext.get_loas_by_search(value)

    conn
    |> render(ProviderLinkWeb.LoaView, "search_loas.json", loas: loas)
  end

  def show_peme(conn, %{"id" => id}) do
    user = PG.current_resource(conn)
    provider = user.agent.provider.name
    loa = LoaContext.get_peme_loa_by_id(id)

    changeset = Loa.changeset_status(%Loa{})
    render(conn, "peme/show_peme.html", loa: loa, changeset: changeset, provider: provider, session: "yes")
  end

  def cancel_peme_loa(conn, %{"id" => id}) do
    loa = LoaContext.get_loa_by_id(id)
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/cancel/#{loa.payorlink_authorization_id}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            cancel_peme_loa_return(conn, loa, decoded["message"])
            _ ->
             render(conn, MemberView, "message.json", message: "fail")
        end
      _ ->
        render(conn, MemberView, "message.json", message: "fail")
    end
  end

  defp cancel_peme_loa_return(conn, loa, message) do
    if message == "success" do
      with {:ok, loa} <- LoaContext.cancel_loa(loa) do
        conn
        |> put_flash(:info, "LOA Cancellation Successful")
        |> redirect(to: "/loas")
      else
        {:error, _changeset} ->
          render(conn, MemberView, "message.json", message: "fail")
      end
    else
      render(conn, MemberView, "message.json", message: "fail")
    end
  end

  def redirect_peme_cancel(conn, params) do
    conn
    |> put_flash(:info, "LOA Cancellation Successful")
    |> redirect(to: "/loas")
  end

  def verified_loa_peme(conn, %{"id" => loa_id, "loa" => loa_params}) do
    date_today = Ecto.Date.utc()
    date_admission = loa_params["admission_date"]

    date_string =
      date_admission
      |> String.split(" ", trim: true)

    date_of_admission = (Enum.at(date_string, 0))

    converted_date =
      date_of_admission
      |> String.split("-", trim: true)

    {:ok, admission_date} = Ecto.Date.cast("#{Enum.at(converted_date, 0)}-#{Enum.at(converted_date, 1)}-#{Enum.at(converted_date, 2)}")

    date_compare = Ecto.Date.compare(date_today, admission_date)

    if (date_compare == :lt) do
      conn
      |> put_flash(:error, "Please verify within schedule PEME date.")
      |> redirect(to: loa_path(conn, :show_peme, loa_id))
    else
      verified_loa_peme(conn, loa_id, loa_params)
    end
  end

  def verified_loa_peme(conn, loa_id, loa_params) do
    with false <- is_nil(loa_params["files"]),
         false <- Enum.empty?(loa_params["files"]),
         loa = %Loa{} <- LoaContext.get_peme_loa_by_id(loa_id),
         {:approved} <- approved_loa(loa),
         {:ok, loa} <- LoaContext.update_peme_payorlink_loa_status(conn, loa, loa_params),
         {:ok, loa} <- LoaContext.verify_loa_providerlink(loa_params, loa_id),
         {:success} <- LoaContext.insert_file(loa_params, loa_id)
    do
      conn
      |> put_flash(:info, "LOA has been approved")
      |> redirect(to: loa_path(conn, :show_peme, loa_id))
    else
      nil ->
        conn
        |> put_flash(:error, "LOA not found!")
        |> redirect(to: loa_path(conn, :show_peme, loa_id))
      {:not_approved} ->
        conn
        |> put_flash(:error, "Failed to verify LOA due to status is not yet approved.")
        |> redirect(to: loa_path(conn, :show_peme, loa_id))
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: loa_path(conn, :show_peme, loa_id))
      true ->
        conn
        |> put_flash(:error, "Please upload Statement of Account (SOA)")
        |> redirect(to: loa_path(conn, :show_peme, loa_id))
      _ ->
        conn
        |> put_flash(:error, "Error")
        |> redirect(to: loa_path(conn, :show_peme, loa_id))
    end
  end

#From Member Controller

  def validate_member_by_details(conn, %{"full_name" => full_name, "birth_date" => birth_date, "coverage" => coverage}) do
    facility_code = conn.assigns.current_user.agent.provider.code

    conn
    |> validate_member(
      facility_code,
      full_name,
      birth_date,
      coverage
    )
  end

  def validate_member_no_session(conn, %{"paylink_user_id" => paylink_user_id, "full_name" => full_name, "birth_date" => birth_date, "coverage" => coverage}) do
    user =
      paylink_user_id
      |> UserContext.get_user_by_paylink_user_id

    facility_code = user.agent.provider.code

    conn
    |> validate_member(
      facility_code,
      full_name,
      birth_date,
      coverage
    )
  end

  defp validate_member(conn, facility_code, full_name, birth_date, coverage) do
    with {:ok, member} <- LoaContext.validate_member_by_details(conn, facility_code, full_name, birth_date, coverage)
    do
      facilities = ProviderContext.get_all_providers_name
      if Enum.count(List.flatten(member)) == 1 do
        member =
          member
          |> List.flatten()
          |> List.first

            conn
            |> render(
              LoaView,
              "single_member.json",
              member: member,
              facilities: facilities
            )
      else
        conn
        |> render(
          LoaView,
          "many_member.json",
          member: member
        )
      end
    else
      {:invalid, message} ->
        conn
        |> render(LoaView, "message.json", message: message)
      _->
        conn
        |> render(LoaView, "message.json", message: "Error has been encountered while validating member.")
    end
  end

  def get_member_by_card_no(conn, %{"card_no" => card_no}) do
    with {:ok, member} <- LoaContext.payorlink_get_member(conn, card_no) do
      facilities = ProviderContext.get_all_providers_name
      conn
      |> render(
        LoaView,
        "single_member.json",
        member: member
      )
    else
      _ ->
        conn
        |> render(LoaView, "message.json", message: "Member not found")
    end
  end

  def validate_number_no_session(conn, %{"paylink_user_id" => paylink_user_id, "number" => number, "bdate" => bdate, "coverage" => coverage}) do
    user =
      paylink_user_id
      |> UserContext.get_user_by_paylink_user_id

    facility_code = user.agent.provider.code
    coverage = "ACU"

    conn
    |> validate_number(number, bdate, facility_code, coverage)

  end

  def validate_member_by_card_number(conn, %{"number" => number, "bdate" => bdate, "coverage" => coverage}) do
    with {:ok, member} <- LoaContext.get_payorlink_member_card(conn, number, bdate),
         {:eligible} <- LoaContext.payorlink_loa_validate(conn, number, conn.assigns.current_user.agent.provider.code, "ACU")
    do
    facilities = ProviderContext.get_all_providers_name
      conn
      |> render(
        LoaView,
        "single_member.json",
        member: member,
        facilities: facilities
      )
    else
      {:invalid, message} ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
      {:error_message, message} ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
      _ ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Card number not found!")
    end
  end

  defp validate_number(conn, number, bdate, facility_code, coverage) do
   validate = LoaContext.validate_number(conn, number, bdate, facility_code, coverage)
    with {:valid} <- validate do
      conn
        |> render(LoaView, "message.json", message: "success")
    else
      _ ->
        validate_number_return(conn, validate)
    end
  end

  defp validate_number_return(conn, validate) do
    case validate do
      {:invalid_number_length} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "Card Number should be 16-digit")

      {:internal} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "PayorLink Internal Server Error")

      {:invalid_member} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "Member not eligible")

      {:member_not_active} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "Member is not active")

      {:error} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "Please enter valid card number/birthdate to avail ACU.")

      {:invalid, message} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: message)

      _ ->
        validate_number_return2(conn, validate)
    end
  end

  defp validate_number_return2(conn, validate) do
    case validate do
      ### for payorlink_validate_loa_return
      {:internal_get_error} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "PayorLink Internal Server Error")

      ### Handled all error messages for eligibility
      {:error_message, message} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: message)

      {:error, response} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: response)

      {:unable_to_login} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "Unable to Login")

      {:payor_does_not_exists} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "Payor not existing")

      {:card_no_bdate_not_matched, message} ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: message)

      _ ->
        render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: "Internal Server Error")
    end
  end

  def attempt_expiry(conn, %{"card_no" => card_no}) do
    datetime = Ecto.DateTime.utc()
    status = LoaContext.add_attempt_to_payorlink_member(conn, card_no)
    render(conn, ProviderLinkWeb.Api.V1.LoaView, "message.json", message: status)
  end

  def add_photo(conn, %{"photo_params" => params}) do
      if params["photo"] == "" or is_nil(params["photo"]) do
        conn
        |> put_flash(:error, "Please upload photo")
        |> redirect(to: page_path(conn, :index))
      else
        redirect_with_session(conn, %{
          "card_no" => params["card_no"],
          "verification" => "Upload Government ID",
          "coverage" => "ACU",
          "params" => params
        })
      end
    rescue
      ErlangError ->
        conn
        |> put_flash(:error, "Timeout error")
        |> redirect(to: page_path(conn, :index))
  end

  def redirect_with_session(conn, %{"card_no" => card_no, "verification" => verification_type, "coverage" => coverage, "params2" => params}) do
    user = conn |> PG.current_resource()
    # params = Map.put(params, "name", params["photo_params"].filename)
    photo_params = if not is_nil(params["photo_params"]["photo"]) do
      params
      |> Map.put("type", params["photo_params"]["photo"])
      |> Map.put("name", params["photo_params"]["photo"].filename)
    else
      %{}
    end
    photo_params2 =
      params
      |> Map.put("facial_image", params["photo_params2"]["facial_image"])
      |> Map.put("name", params["photo_params2"]["facial_image"].filename)

    with {:ok, member} <- LoaContext.payorlink_get_member(conn, card_no),
         {:ok, loa} <- LoaContext.insert_loa_acu(member),
         {:ok, loa} <- LoaContext.update_facial_image(loa, photo_params2),
         {:ok, response} <- LoaContext.insert_government_id(Map.put(params, "loa_id", loa.id)),
         {:ok, file} <- LoaContext.update_government_id(response, photo_params)
        do
         pamd_params =
          if not is_nil(params["photo_params"]["photo"]) do
          %{
           filename: params["photo_params"]["photo"].filename,
           content_type: params["photo_params"]["photo"].content_type,
           uploaded_by: user.username,
           purpose: "ACU Availment - Government ID",
           uploaded_from: "ProviderLink",
           date_uploaded: loa.updated_at,
           file: file
          }
          else
            %{}
          end
         pamd_params1 =  %{
          filename: params["photo_params2"]["facial_image"].filename,
          content_type: params["photo_params2"]["facial_image"].content_type,
          uploaded_by: user.username,
          purpose: "ACU Availment - Facial Image",
          uploaded_from: "ProviderLink",
          date_uploaded: loa.updated_at,
          file: loa,
          authorization: "true"
         }
      LoaContext.delete_local_img(params["photo_params2"]["facial_image"].filename, "png")
      get_coverage_params =
        %{
          facility_code: conn.assigns.current_user.agent.provider.code,
          coverage_code: coverage,
          card_no: loa.member_card_no
        }
      params =
        %{
          "provider_id" => conn.assigns.current_user.agent.provider.id,
          "coverage_code" => coverage,
          "card_no" => loa.member_card_no,
          "member_id" => loa.payorlink_member_id,
          "verification_type" => verification_type,
          "user_id" => conn.assigns.current_user.id
        }

      redirect_to_package_info(conn, loa, get_coverage_params, params, verification_type, pamd_params, pamd_params1)
    else
      _ ->
        conn
        |> put_flash(:error, "Error")
        |> redirect(to: page_path(conn, :index))
    end
  end

  # def redirect_with_session(conn, %{"card_no" => card_no, "verification" => verification_type, "coverage" => coverage, "params" => params}) do
  #   user = conn |> PG.current_resource()
  #   params = Map.put(params, "name", params["photo"].filename)
  #   photo_params = Map.put(params, "type", params["photo"])

  #   with {:ok, member} <- LoaContext.payorlink_get_member(conn, card_no),
  #        {:ok, loa} <- LoaContext.insert_loa_acu(member),
  #        {:ok, response} <- LoaContext.insert_government_id(Map.put(params, "loa_id", loa.id)),
  #        {:ok, file} <- LoaContext.update_government_id(response, photo_params),
  #        pamd_params <- %{
  #          filename: params["photo"].filename,
  #          content_type: params["photo"].content_type,
  #          uploaded_by: user.username,
  #          purpose: "ACU Availment",
  #          uploaded_from: "ProviderLink",
  #          date_uploaded: file.type.updated_at,
  #          file: file
  #        }
  #   do
  #     LoaContext.delete_local_img(params["photo"].filename, "png")
  #     get_coverage_params =
  #       %{
  #         facility_code: conn.assigns.current_user.agent.provider.code,
  #         coverage_code: coverage,
  #         card_no: loa.member_card_no
  #       }
  #     params =
  #       %{
  #         "provider_id" => conn.assigns.current_user.agent.provider.id,
  #         "coverage_code" => coverage,
  #         "card_no" => loa.member_card_no,
  #         "member_id" => loa.payorlink_member_id,
  #         "verification_type" => verification_type,
  #         "user_id" => conn.assigns.current_user.id
  #       }

  #       # render("pae/index.html", loa: loa, swal_facial: true)
  #     redirect_to_package_info(conn, loa, get_coverage_params, params, verification_type, pamd_params)
  #   else
  #     _ ->
  #       conn
  #       |> put_flash(:error, "Error")
  #       |> redirect(to: page_path(conn, :index))
  #   end
  # end

  def redirect_with_session(conn, %{"card_no" => card_no, "verification" => verification_type, "coverage" => coverage}) do
    case String.downcase(coverage) do
      "peme" ->
        with {:ok, member} <- LoaContext.payorlink_get_member(conn, card_no),
              {:ok, loa} <- LoaContext.insert_loa_acu(member)
        do
          peme_coverage_params =
            %{
              facility_code: conn.assigns.current_user.agent.provider.code,
              coverage_code: coverage,
              member_id: loa.payorlink_member_id
            }
          params =
            %{
              "provider_id" => conn.assigns.current_user.agent.provider.id,
              "coverage_code" => coverage,
              "card_no" => loa.member_card_no,
              "member_id" => loa.payorlink_member_id,
              "verification_type" => verification_type,
              "user_id" => conn.assigns.current_user.id
            }

          redirect_to_package_info_peme(conn, loa, peme_coverage_params, params, verification_type)
        else
          _ ->
            conn
            |> put_flash(:error, "Error")
            |> redirect(to: page_path(conn, :index))
        end
      "acu" ->
        with {:ok, member} <- LoaContext.payorlink_get_member(conn, card_no),
             {:ok, loa} <- LoaContext.insert_loa_acu(member)
        do
          get_coverage_params =
          %{
            facility_code: conn.assigns.current_user.agent.provider.code,
            coverage_code: coverage,
            card_no: loa.member_card_no
          }
          params =
            %{
              "provider_id" => conn.assigns.current_user.agent.provider.id,
              "coverage_code" => coverage,
              "card_no" => loa.member_card_no,
              "member_id" => loa.payorlink_member_id,
              "verification_type" => verification_type,
              "user_id" => conn.assigns.current_user.id
            }

          redirect_to_package_info(conn, loa, get_coverage_params, params, verification_type)
        else
          _ ->
            conn
            |> put_flash(:error, "Error")
            |> redirect(to: page_path(conn, :index))
        end
      "consult" ->
        with {:ok, member} <- LoaContext.payorlink_get_member(conn, card_no),
              {:ok, loa} <- LoaContext.insert_loa_acu(member)
        do
          get_coverage_params =
            %{
              facility_code: conn.assigns.current_user.agent.provider.code,
              coverage_code: coverage,
              card_no: member.card.number
            }
          params = %{}
          params =
            params
            |> Map.put("card_id", member.card.id)
            |> Map.put("coverage", coverage)
            |> Map.put("created_by_id", conn.assigns.current_user.id)
            |> Map.put("status", "Draft")
            |> Map.put("consultation_date",  Ecto.DateTime.utc)

          conn
          |> redirect_to_consult_info(member, params)
        else
          _ ->
            conn
            |> put_flash(:error, "Error")
            |> redirect(to: page_path(conn, :index))
        end
    end
  end

  def capture_photo(conn, %{"capture_params" => params}) do
    if params["photo"] == "" or is_nil(params["photo"]) do
      conn
      |> put_flash(:error, "Please capture photo")
      |> redirect(to: page_path(conn, :index))
    else
      card_no = params["card_no"]
      params =
        params
        |> Map.put("file_name", "captured_image")
        |> Map.put("extension", "png")

        with {:ok, params} <- LoaContext.convert_base64_to_file(params) do
          redirect_with_session(conn, %{
            "card_no" => card_no,
            "verification" => "Upload Government ID",
            "coverage" => "ACU",
            "params" => params
          })
        else
          _ ->
          conn
          |> put_flash(:error, "Error inserting photo")
          |> redirect(to: page_path(conn, :index))
        end
    end
  end

  def add_photo(conn, %{"photo_params" => params}) do
      if params["photo"] == "" or is_nil(params["photo"]) do
        conn
        |> put_flash(:error, "Please upload photo")
        |> redirect(to: page_path(conn, :index))
      else
        redirect_with_session(conn, %{
          "card_no" => params["card_no"],
          "verification" => "Upload Government ID",
          "coverage" => "ACU",
          "params" => params
        })
      end
    rescue
      ErlangError ->
        conn
        |> put_flash(:error, "Timeout error")
        |> redirect(to: page_path(conn, :index))
  end

  def redirect_peme_with_session(conn, %{"id" => id, "verification" => verification_type, "coverage" => coverage}) do
    loa = LoaContext.get_loa_by_id(id)
    peme_coverage_params =
      %{
        facility_code: conn.assigns.current_user.agent.provider.code,
        coverage_code: coverage,
        member_id: loa.payorlink_member_id
      }
    params =
      %{
        "provider_id" => conn.assigns.current_user.agent.provider.id,
        "coverage_code" => coverage,
        "card_no" => loa.member_card_no,
        "member_id" => loa.payorlink_member_id,
        "verification_type" => verification_type,
        "user_id" => conn.assigns.current_user.id
      }

    redirect_to_package_info_peme(conn, loa, peme_coverage_params, params, verification_type)
  end

  defp redirect_to_package_info_peme(conn, loa, peme_params, params, verification_type) do
    with {:ok, response} <- LoaContext.get_peme_details(conn, peme_params),
         false <- Enum.empty?(response["payor_procedure"]),
         {:ok, loa} <- LoaContext.request_loa_peme(conn, loa, params, response)
    do
      conn
      |> redirect(to: "/loas/#{loa.payorlink_member_id}/package_info/#{verification_type}/#{loa.id}")
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: page_path(conn, :index))
      true ->
        conn
        |> put_flash(:error, "Member is not eligible to avail PEME in this Hospital/Clinic.")
        |> redirect(to: page_path(conn, :index))
      _ ->
        conn
        |> put_flash(:error, "Error")
        |> redirect(to: page_path(conn, :index))
    end
  end

  defp redirect_to_package_info(conn, loa, acu_params, params, verification_type) do
    LoaContext.remove_attempt_to_payorlink_member(conn, params["card_no"])

    acu_params =
     acu_params
      |> Map.put(:requested_by, conn.assigns.current_user.username)

    with {:ok, response} <- LoaContext.get_acu_details(conn, acu_params),
         false <- Enum.empty?(response["payor_procedure"]),
         # true <- Enum.empty?(LoaContext.get_loas_by_card_no(params["card_no"])),
         {:ok, loa} <- LoaContext.request_loa_acu_update_security(params, loa, response),
         {:ok, loa} <- LoaContext.request_update_loa_acu(conn, loa, response  |> Map.drop(["acu_type"]))
    do
      conn
      # |> redirect(to: "/loas/#{loa.id}/package_info/#{verification_type}")
      |> redirect(to: "/loas/#{loa.id}/show")
    else
      {:multiple, response} ->
        case LoaContext.request_loa_acu_update_security(params, loa, response) do
          {:ok, loa} ->
            conn
            |> redirect(to: "/loas/#{loa.id}/show")
          _ ->
            conn
            |> put_flash(:error, "Error")
            |> redirect(to: page_path(conn, :index))
        end
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: page_path(conn, :index))
      true ->
        conn
        |> put_flash(:error, "Member is not eligible to avail ACU in this Hospital/Clinic.")
        |> redirect(to: page_path(conn, :index))
      # false ->
      #   loa = LoaContext.get_loas_by_card_no(params["card_no"])
      #   loa = loa |> List.first()
      #   conn
      #   |> redirect(to: "/loas/#{params["card_no"]}/package_info/#{verification_type}/#{loa.id}")
      _ ->
        conn
        |> put_flash(:error, "Error")
        |> redirect(to: page_path(conn, :index))
    end
  end

  ## mimic of defp redirect_to_package_info/5
  defp redirect_to_package_info(conn, loa, acu_params, params, verification_type, pamd_params, pamd_params1) do
    LoaContext.remove_attempt_to_payorlink_member(conn, params["card_no"])
    acu_params =
      acu_params
      |> Map.put(:requested_by, conn.assigns.current_user.username)

    with {:ok, response} <- LoaContext.get_acu_details(conn, acu_params),
         false <- Enum.empty?(response["payor_procedure"]),
         {:ok, loa} <- LoaContext.request_loa_acu_update_security(params, loa, response),
         {:ok, loa} <- LoaContext.request_update_loa_acu(conn, loa, response)
    do
      if pamd_params != %{} do
        pamd_params = update_member_document_params(pamd_params, loa)
        {:ok, member_document} = MemberContext.payor_api_member_document(pamd_params)
      end
      pamd_params1 = update_member_document_params_facial(pamd_params1, loa)
      {:ok, member_document} = MemberContext.payor_api_member_document(pamd_params1)
      conn
      |> redirect(to: "/loas/#{loa.id}/show?valid=true")
    else
      {:multiple, response} ->
        with {:ok, loa} <- LoaContext.request_loa_acu_update_security(params, loa, response)
        do
          if pamd_params != %{} do
            pamd_params = update_member_document_params(pamd_params, loa)
            {:ok, member_document} = MemberContext.payor_api_member_document(pamd_params)
          end
          pamd_params1 = update_member_document_params_facial(pamd_params1, loa)
          {:ok, member_document} = MemberContext.payor_api_member_document(pamd_params1)
          conn
          |> redirect(to: "/loas/#{loa.id}/show")
        else
          _ ->
            conn
            |> put_flash(:error, "Error")
            |> redirect(to: page_path(conn, :index))
        end
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: page_path(conn, :index))
      true ->
        conn
        |> put_flash(:error, "Member is not eligible to avail ACU in this Hospital/Clinic.")
        |> redirect(to: page_path(conn, :index))

      {:error_api, response} ->
        conn
        |> put_flash(:error, response) ## temporary try only for response
        |> redirect(to: page_path(conn, :index))

      400 ->
        conn
        |> put_flash(:error, "Error 400 in PAYOR API Member Document")
        |> redirect(to: page_path(conn, :index))

      403 ->
        conn
        |> put_flash(:error, "Error 403 in PAYOR API Member Document")
        |> redirect(to: page_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Error")
        |> redirect(to: page_path(conn, :index))

    end
  end

  defp redirect_to_consult_info(conn, member, params) do
    with {:ok, params} <- generate_transaction_no(conn, params),
         {:ok, loa} <- LoaContext.create_loa(params)
    do
        conn
        |> redirect(to: "/loas/#{loa.id}/request/consult")
    else
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: page_path(conn, :index))
      {:unable_to_login} ->
        conn
        |> put_flash(:error, "Unable to login")
        |> redirect(to: page_path(conn, :index))
      {:error_connecting_api} ->
        conn
        |> put_flash(:error, "Error Connecting API")
        |> redirect(to: page_path(conn, :index))
      {:payor_does_not_exists} ->
        conn
        |> put_flash(:error, "Payor does not exist")
        |> redirect(to: page_path(conn, :index))
    end
  end

  def generate_transaction_no(conn, params) do
    with {:ok, response} <- UtilityContext.connect_to_api_get(conn,
      "Maxicar", "loa/generate/transaction_no")
    do
      decoded = Poison.decode!(response.body)

      params =
      params
      |> Map.put("transaction_id", decoded["message"])
      {:ok, params}
    else
      {:unable_to_login} ->
        {:unable_to_login}
      {:error_connecting_api} ->
        {:error_connecting_api}
      {:payor_does_not_exists} ->
        {:payor_does_not_exists}
    end
  end

  #PEME
  def validate_accountlink_evoucher(conn, %{"evoucher" => evoucher}) do
    facility_code = conn.assigns.current_user.agent.provider.code
    with {:ok, loa} <- LoaContext.get_accountlink_member_evoucher(conn, evoucher, facility_code, "PEME") do
        conn
        |> render(
          ProviderLinkWeb.MemberView,
          "loa_member.json",
          loa: loa
        )
    else
      {:internal} ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: "PayorLink Internal Server Error")
      {:evoucher_not_found} ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: "eVoucher number does not exist")
      {:unable_to_login} ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Payorlink Error")
      {:invalid, message} ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
      ### Handled all error messages for eligibility
      {:error_message, message} ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
      {:error, response} ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: response)
      {:error} ->
        render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Timeout Error")
    end
  end

  def validate_accountlink_qrcode(conn, %{"RemoteFile" => remote_file}) do
    file = File.read!(remote_file.path)
    {:ok, zbar} = file |> Zbar.scan()
    if not Enum.empty?(zbar) || not is_nil(List.first(zbar)) do
      evoucher = List.first(String.split(List.first(zbar).data, "|"))
      facility_code = conn.assigns.current_user.agent.provider.code

      with {:ok, loa} <- LoaContext.get_accountlink_member_evoucher(conn, evoucher, facility_code, "PEME") do
        conn
        |> render(
          ProviderLinkWeb.MemberView,
          "loa_member.json",
          loa: loa
        )
      else
        {:internal} ->
          render(conn, ProviderLinkWeb.MemberView, "message.json", message: "PayorLink Internal Server Error")
        {:evoucher_not_found} ->
          render(conn, ProviderLinkWeb.MemberView, "message.json", message: "eVoucher number does not exist")
        {:unable_to_login} ->
          render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Payorlink Error")
        {:invalid, message} ->
          render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
          ### Handled all error messages for eligibility
        {:error_message, message} ->
          render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
        {:error, response} ->
          render(conn, ProviderLinkWeb.MemberView, "message.json", message: response)
        {:error} ->
          render(conn, ProviderLinkWeb.MemberView, "message.json", message: "eVoucher Number does not exist")
      end
    else
      render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Invalid Evoucher")
    end
  end

  def member_index(conn, %{"paylink_user_id" => paylink_user_id}) do
    with user = %User{} <- paylink_user_id |> UserContext.get_user_by_paylink_user_id
    do
      render(conn, "member_eligibility_no_session.html", user: user)
    else
      nil ->
        conn
        |> put_flash(:error, "You must be signed in to access that page.")
        |> redirect(to: "/sign_in")
    end
  end

  def member_security_index(conn, %{"paylink_user_id" => paylink_user_id, "card_no" => card_no, "code" => code}) do
    with user = %User{} <- paylink_user_id |> UserContext.get_user_by_paylink_user_id,
         {:ok, member} <- LoaContext.payorlink_get_member(conn, card_no),
         {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
         {:valid, false} <- LoaContext.validate_loa_coverage(token, card_no, user.agent.provider.code, "ACU")
    do
      render(conn, "member_security_no_session.html", paylink_user_id: user.paylink_user_id, card_no: card_no, valid: true, attempts: member.attempts, code: code)
    else
      nil ->
        conn
        |> put_flash(:error, "User does not exist!")
        |> render("member_security_no_session.html", paylink_user_id: "", card_no: "")
      {:valid, true} ->
        conn
        |> put_flash(:error, "Member have multiple ACU plans, please escalate to Maxicare")
        |> render("member_security_no_session.html", paylink_user_id: "", card_no: "")
      {:invalid, message} ->
        conn
        |> put_flash(:error, message)
        |> render("member_security_no_session.html", paylink_user_id: "", card_no: "")
      _ ->
        conn
        |> put_flash(:error, "Error has been occured!")
        |> render("member_security_no_session.html", paylink_user_id: "", card_no: "")
    end
  end

  def member_security_index(conn, %{"paylink_user_id" => paylink_user_id, "card_no" => card_no}) do
    with user = %User{} <- paylink_user_id |> UserContext.get_user_by_paylink_user_id,
         {:ok, member} <- LoaContext.payorlink_get_member(conn, card_no),
         {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
         {:valid, false} <- LoaContext.validate_loa_coverage(token, card_no, user.agent.provider.code, "ACU")
    do
      render(conn, "member_security_no_session.html", paylink_user_id: user.paylink_user_id, card_no: card_no, valid: true, attempts: member.attempts, code: "")
    else
      nil ->
        conn
        |> put_flash(:error, "User does not exist!")
        |> render("member_security_no_session.html", paylink_user_id: "", card_no: "")
      {:valid, true} ->
        conn
        |> put_flash(:error, "Member have multiple ACU plans, please escalate to Maxicare")
        |> render("member_security_no_session.html", paylink_user_id: "", card_no: "")
      {:invalid, message} ->
        conn
        |> put_flash(:error, message)
        |> render("member_security_no_session.html", paylink_user_id: "", card_no: "")
      _ ->
        conn
        |> put_flash(:error, "Error has been occured!")
        |> render("member_security_no_session.html", paylink_user_id: "", card_no: "")
    end
  end


  def no_session_for_all(conn, params, code) do
    no_session_params(conn, params, code)
  end

  def no_session_params(conn, params, code) do
    # member_id = params["member_id"]
    card_no = params["card_no"]
    paylink_user_id = params["paylink_user_id"]
    verification_type = params["verification"]
    client_ip =
      conn.remote_ip
      |> Tuple.to_list
      |> Enum.join(".")
    user =
      paylink_user_id
      |> UserContext.get_user_by_paylink_user_id
    conn =
      conn
      |> assign(:current_user, user)
    # member = MemberContext.get_acu_member(member_id)
    acu_params =
    %{
      facility_code: user.agent.provider.code,
      coverage_code: "ACU",
      card_no: card_no,
      user: Enum.join([user.agent.first_name, user.agent.last_name], " "),
      client_ip: client_ip
    }
    params =
      params
      |> Map.put("provider_id", user.agent.provider.id)
      |> Map.put("user_id", user.id)
      |> Map.put("verification_type", verification_type)
    redirect_to_package_info_no_session(conn, acu_params, params, paylink_user_id, params["photo_params"]["photo"], code)
  end

  defp redirect_to_package_info_no_session(conn, acu_params, params, paylink_user_id, nil, code) do
    LoaContext.remove_attempt_to_payorlink_member(conn, params["card_no"])
    acu_params =
     acu_params
        |> Map.put(:requested_by, paylink_user_id)

    # photo_params = if not is_nil(params["photo_params"]["photo"]) do
    #   params
    #     |> Map.put("type", params["photo_params"]["photo"])
    #     |> Map.put("name", params["photo_params"]["photo"].filename)
    #   else
    #     %{}
    #   end
    photo_params2 =
      params
        |> Map.put("facial_image", params["photo_params2"]["facial_image"])
        |> Map.put("name", params["photo_params2"]["facial_image"].filename)

    loas =
      acu_params.card_no
      |> LoaContext.get_loas_by_card_no()
      |> Enum.reject(&(is_nil(&1.payorlinkone_loe_no)))
      |> Enum.reject(&(&1.status != "Availed"))
      |> Enum.reject(&(&1.status != "Approved"))

    user = UserContext.get_user_by_paylink_user_id(paylink_user_id)

    with true <- Enum.empty?(loas),
         {:ok, response} <- LoaContext.get_acu_details(conn, acu_params),
         {:ok, member} <- LoaContext.payorlink_get_member(conn, params["card_no"]),
         {:ok, loa} <- LoaContext.insert_loa_acu(member),
         {:ok, loa} <- LoaContext.request_loa_acu_update_security(params, loa, response),
         {:ok, paylink_response} <- LoaContext.create_acu_loa_paylink_params(conn, loa, acu_params, response),
         {:ok, loa} <- LoaContext.insert_loe_n_claim_no(loa, List.first(paylink_response)),
         {:ok, loa} <- LoaContext.request_update_loa_acu_2(conn, loa, response),
         {:ok, loa} <- LoaContext.request_update_loa_acu_3(conn, loa, response),
         {:ok, loa} <- LoaContext.update_facial_image(loa, photo_params2)
    do
      pamd_params1 =  %{
        filename: params["photo_params2"]["facial_image"].filename,
        content_type: params["photo_params2"]["facial_image"].content_type,
        uploaded_by: user.username,
        purpose: "ACU Availment - Facial Image",
        uploaded_from: "ProviderLink",
        date_uploaded: loa.updated_at,
        file: loa,
        authorization: "true"
       }
      pamd_params1 = update_member_document_params_facial(pamd_params1, loa)
      {:ok, member_document} = MemberContext.payor_api_member_document(pamd_params1)
      redirect(conn, to: "/loas/#{loa.payorlinkone_loe_no}/show_loa_no_session/#{paylink_user_id}?valid=true")
    else
      {:multiple, response} ->
        conn
        |> put_flash(:error, "Member have multiple ACU plans, please escalate to Maxicare")
        |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, params["card_no"], code, valid: true))
      false ->
        check_loa_provider(conn, loas, params, paylink_user_id)
      {:error, nil} ->
        conn
        |> put_flash(:error, "Error inserting data in paylink")
        |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, params["card_no"], code, valid: true))
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, params["card_no"], code, valid: true))
    end
  end

  defp redirect_to_package_info_no_session(conn, acu_params, params, paylink_user_id, photo_params, code) do
    acu_params =
      acu_params
      |> Map.put(:requested_by, paylink_user_id)
    photo_params = if not is_nil(params["photo_params"]["photo"]) do
      params
        |> Map.put("type", params["photo_params"]["photo"])
        |> Map.put("name", params["photo_params"]["photo"].filename)
      else
        %{}
      end
    photo_params2 =
      params
        |> Map.put("facial_image", params["photo_params2"]["facial_image"])
        |> Map.put("name", params["photo_params2"]["facial_image"].filename)

    LoaContext.remove_attempt_to_payorlink_member(conn, params["card_no"])
    loas =
      acu_params.card_no
      |> LoaContext.get_loas_by_card_no()
      |> Enum.reject(&(is_nil(&1.payorlinkone_loe_no)))
      |> Enum.reject(&(&1.status != "Availed"))
      |> Enum.reject(&(&1.status != "Approved"))

    user = UserContext.get_user_by_paylink_user_id(paylink_user_id)

    with true <- Enum.empty?(loas),
         {:ok, response} <- LoaContext.get_acu_details(conn, acu_params),
         {:ok, member} <- LoaContext.payorlink_get_member(conn, params["card_no"]),
         {:ok, loa} <- LoaContext.insert_loa_acu(member),
         {:ok, loa} <- LoaContext.request_loa_acu_update_security(params, loa, response),
         {:ok, paylink_response} <- LoaContext.create_acu_loa_paylink_params(conn, loa, acu_params, response),
         {:ok, loa} <- LoaContext.insert_loe_n_claim_no(loa, List.first(paylink_response)),
         {:ok, loa} <- LoaContext.request_update_loa_acu_2(conn, loa, response),
         {:ok, loa} <- LoaContext.request_update_loa_acu_3(conn, loa, response),
         {:ok, response} <- LoaContext.insert_government_id(Map.put(params, "loa_id", loa.id)),
         {:ok, file} <- LoaContext.update_government_id(response, photo_params),
         {:ok, loa} <- LoaContext.update_facial_image(loa, photo_params2)
    do
      pamd_params = %{
        filename: params["photo_params"]["photo"].filename,
        content_type: params["photo_params"]["photo"].content_type,
        uploaded_by: user.username,
        purpose: "ACU Availment - Government ID",
        uploaded_from: "ProviderLink",
        date_uploaded: loa.updated_at,
        file: file
      }
      pamd_params = update_member_document_params(pamd_params, loa)
      {:ok, member_document} = MemberContext.payor_api_member_document(pamd_params)

      pamd_params1 =  %{
       filename: params["photo_params2"]["facial_image"].filename,
       content_type: params["photo_params2"]["facial_image"].content_type,
       uploaded_by: user.username,
       purpose: "ACU Availment - Facial Image",
       uploaded_from: "ProviderLink",
       date_uploaded: loa.updated_at,
       file: loa,
       authorization: "true"
      }
      pamd_params1 = update_member_document_params_facial(pamd_params1, loa)
      {:ok, member_document} = MemberContext.payor_api_member_document(pamd_params1)

        redirect(conn, to: "/loas/#{loa.payorlinkone_loe_no}/show_loa_no_session/#{paylink_user_id}")
    else
      {:multiple, response} ->
        conn
        |> put_flash(:error, "Member have multiple ACU plans, please escalate to Maxicare")
        |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, params["card_no"], code, valid: true))
      false ->
        check_loa_provider(conn, loas, params, paylink_user_id)
      {:error, nil} ->
        conn
        |> put_flash(:error, "Error inserting data in paylink")
        |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, params["card_no"], code, valid: true))
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, params["card_no"], code, valid: true))
    end
  end

  defp check_loa_provider(conn, loas, params, paylink_user_id) do
    loa = Enum.find(loas, &(&1.provider_id == params["provider_id"]))
    if is_nil(loa) do
      conn
      |> put_flash(:error, "You are no longer valid to request ACU’. Reason: Member already requested in another Hospital/Clinic.")
      |> redirect(to: "/members/eligibility/#{paylink_user_id}")
    else
      conn
      |> redirect(to: "/loas/#{loa.payorlinkone_loe_no}/package_info_no_session/member_details/#{paylink_user_id}")
    end
  end

  def show_loa_cart(conn, _params) do
    loas = LoaContext.list_all_cart_loa()
    changeset = Loa.changeset_cart(%Loa{})
    batch = BatchContext.list_all()
    render(conn, "show_loa_cart.html", loas: loas, batch: batch, changeset: changeset)
  end

  def remove_to_cart_page(conn, %{"id" => id}) do
    LoaContext.remove_loa_cart(id)

    loa = LoaContext.list_all_cart_loa()
    conn
    |> put_flash(:info, " LOA Successfully removed")
    |> redirect(to: "/loas/show_loa_cart")
  end

  def add_photo_no_session(conn, %{"photo_params" => params}) do
      card_no = params["card_no"]
      paylink_user_id = params["paylink_user_id"]
      if params["photo"] == "" or is_nil(params["photo"]) do
        conn
        |> put_flash(:error, "Please upload photo")
        |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, card_no, params["code"], valid: true))
      else
        no_session_for_all(conn, params, params["code"])
      end
    rescue
      ErlangError ->
        conn
        |> put_flash(:error, "Timeout error")
        |> redirect(to: page_path(conn, :index))
  end

  def capture_photo_no_session(conn, %{"capture_params" => params}) do
    card_no = params["card_no"]
    paylink_user_id = params["paylink_user_id"]
    if params["photo"] == "" or is_nil(params["photo"]) do
      conn
      |> put_flash(:error, "Please capture photo")
      |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, card_no, params["code"], valid: true))
    else
      params =
        params
        |> Map.put("file_name", "captured_image")
        |> Map.put("extension", "png")

        with {:ok, params} <- LoaContext.convert_base64_to_file(params) do
          params =
            params
            |> Map.put("card_no", card_no)
            |> Map.put("paylink_user_id", paylink_user_id)
            |> Map.put("verification", "Upload Government ID")
          no_session_for_all(conn, params, params["code"])
        else
          _ ->
          conn
          |> put_flash(:error, "Error inserting photo")
          |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, card_no, params["code"], valid: true))
        end
    end
  end

  defp check_env(params) do
    if Application.get_env(:data, :env) == :dev do
     var = ProviderLinkWeb.MemberView.get_file_url(params.file)
      "localhost:4000#{var}"
    else
      ###  for AWS
      ProviderLinkWeb.MemberView.get_file_url(params.file)
    end
  end

  defp check_env_facial(params) do
    if Application.get_env(:data, :env) == :dev do
     var = ProviderLinkWeb.MemberView.get_file_url_facial(params.file)
      "localhost:4000#{var}"
    else
      ###  for AWS
      ProviderLinkWeb.MemberView.get_file_url_facial(params.file)
    end
  end

  defp update_member_document_params(params, loa) do
    link = check_env(params)
    params
    |> Map.put(:link, link)
    |> Map.put(:authorization_id, loa.payorlink_authorization_id)
    |> Map.put(:member_id, loa.payorlink_member_id)
  end

  defp update_member_document_params_facial(params, loa) do
    link = check_env_facial(params)
    params
    |> Map.put(:link, link)
    |> Map.put(:authorization_id, loa.payorlink_authorization_id)
    |> Map.put(:member_id, loa.payorlink_member_id)
  end

  defp create_batch_for_acu_clinic(conn, loa, loa_params) do
    batch_params = %{
      "soa_reference_no" => loa_params["soa_reference_no"],
      "soa_amount" => Decimal.new(loa_params["amount"]),
      "edited_soa_amount" => Decimal.new(0),
      "status" => "Submitted",
      "type" => "hospital_bill"
    }

    {:ok, batch} = BatchContext.create_submitted_batch(batch_params, loa.created_by_id)
    create_batch_loa(loa_params["loa_id"], batch)

    payor_batch_params = %{
      batch_no: batch.number,
      type: "HB",
      facility_id: loa.provider.payorlink_facility_id,
      coverage: "ACU",
      soa_ref_no: loa_params["soa_reference_no"],
      soa_amount: loa_params["amount"],
      edit_soa_amount: "0",
      authorization_id: loa_params["authorization_id"]
    }

    url = "loa/batch/clinic/create_batch"
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

  defp create_batch_loa(loa_id, batch) do
    params = [%{
      loa_id: loa_id,
      batch_id: batch.id,
      inserted_at: Ecto.DateTime.utc(),
      updated_at: Ecto.DateTime.utc()
    }]
    BatchContext.create_batch_loa(params)
  end

  def capture_facial(conn, %{"facial_params" => params}) do
    if params["facial_image"] == "" or is_nil(params["facial_image"]) do
      conn
      |> put_flash(:error, "Please capture photo")
      |> redirect(to: page_path(conn, :index))
    else
      card_no = params["card_no"]
      params =
        params
        |> Map.put("filename", "goverment_id_image")
        |> Map.put("extension", "png")
        |> Map.put("filename1", "facial_image")

        with {:ok, gov_params} <- LoaContext.convert_base64_to_file(params |> Map.drop(["facial_image", "filename1"])),
             {:ok, facial_params} <- LoaContext.convert_base64_to_file2(params |> Map.drop(["photo", "filename"]))
         do

          redirect_with_session(conn, %{
            "card_no" => card_no,
            "verification" => "Capture Facial Image Required!",
            "coverage" => "ACU",
            "params2" => params |> Map.put("photo_params", gov_params) |> Map.put("photo_params2", facial_params)
          })
        else
          _ ->
          conn
          |> put_flash(:error, "Error inserting photo")
          |> redirect(to: page_path(conn, :index))
        end
    end
  end

  def capture_facial_no_session(conn, %{"facial_params" => params}) do
    card_no = params["card_no"]
    paylink_user_id = params["paylink_user_id"]
    if params["facial_image"] == "" or is_nil(params["facial_image"]) do
      conn
      |> put_flash(:error, "Please capture photo")
      |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, card_no, params["code"], valid: true))
    else
      params =
        params
        |> Map.put("filename", "goverment_id_image")
        |> Map.put("extension", "png")
        |> Map.put("filename1", "facial_image")

        with {:ok, gov_params} <- LoaContext.convert_base64_to_file(params |> Map.drop(["facial_image", "filename1"])),
             {:ok, facial_params} <- LoaContext.convert_base64_to_file2(params |> Map.drop(["photo", "filename"]))
         do
          params =
            params
            |> Map.put("card_no", card_no)
            |> Map.put("paylink_user_id", paylink_user_id)
            |> Map.put("verification", "Upload Government ID")
          no_session_for_all(conn, params |> Map.put("photo_params", gov_params) |> Map.put("photo_params2", facial_params), params["code"])
        else
          _ ->
          conn
          |> put_flash(:error, "Error inserting photo")
          |> redirect(to: loa_path(conn, :member_security_index, paylink_user_id, card_no, params["code"], valid: true))
        end
    end
  end

end
