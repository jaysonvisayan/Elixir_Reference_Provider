defmodule Data.Contexts.LoaContext do
  @moduledoc """
  """

  import Ecto.Query

  alias Data.Repo
  alias Data.Parsers.ProviderLinkParser, as: PP
  alias Data.Schemas.{
    AcuSchedule,
    Loa,
    LoaDoctor,
    LoaDiagnosis,
    LoaProcedure,
    LoaPackage,
    Card,
    Member,
    Provider,
    File,
    Specialization,
    Claim
  }
  alias Data.Contexts.{
    UtilityContext,
    MemberContext,
    ProviderContext,
    UserContext,
    PayorContext,
    DoctorContext,
    CardContext,
    BatchContext
  }
  alias Ecto.Changeset
  alias Decimal
  alias Ecto.Date
  alias ProviderLink.Guardian, as: PG

  def get_loa_by_card_no(card_no) do
    Loa
    |> join(:inner, [l], c in Card, l.card_id == c.id)
    |> where([l, c], c.number == ^card_no)
    |> Repo.all()
  end

  def create_loa(params) do
    %Loa{}
    |> Loa.create_changeset(params)
    |> Repo.insert()
  end

  def update_loa(%Loa{} = loa, params) do
    loa
    |> Loa.create_changeset(params)
    |> Repo.update()
  end

  def get_loa_by_coverage_by_provider(coverage, provider_id, is_peme) do
    Loa
    |> where(
      [l],
      fragment(
        "upper(?) = upper(?)",
        l.coverage,
        ^coverage
      )
      and l.provider_id == ^provider_id
      and fragment(
        "coalesce(?,?) = ?",
        l.is_peme,
        false,
        ^is_peme
      )
    )
    |> Repo.all()
    |> Repo.preload([
      [card: [member: :payor]],
      :member, :payor
    ])
  end

  def get_loa_by_coverage_by_provider_consult(coverage, provider_id, is_peme) do
    Loa
    |> where(
      [l],
      fragment(
        "upper(?) = upper(?)",
        l.coverage,
        ^coverage
      )
      and l.provider_id == ^provider_id
    )
    |> Repo.all()
    |> Repo.preload([
      :payor,
      card: [member: :payor]
    ])
  end

  defp get_loa_by_coverage_by_provider_struct(struct, coverage, provider_id) do
    struct
    |> where([l], fragment("upper(?) = upper(?)", l.coverage, ^coverage) and l.provider_id == ^provider_id)
  end

  defp get_loa_by_card_number(struct, card_no) do
    from l in struct,
      where: fragment("coalesce(?,?) ilike ?", l.member_card_no, "", ^("%#{String.replace(card_no, "-", "")}%"))
  end

  defp get_loa_by_status(struct, status) do
    from l in struct,
      where: fragment("coalesce(?,?) ilike ?", l.status, "", ^("%#{String.replace(status, "-", "")}%"))
  end

  defp get_loa_by_evoucher_number(struct, evoucher_no) do
    from l in struct,
      where: fragment("coalesce(?,?) ilike ?", l.member_evoucher_number, "", ^("%#{evoucher_no}%"))
  end

  defp get_loa_by_loa_number(struct, loa_no) do
    struct
    |> where([l], fragment("coalesce(?,?) ilike ?", l.loa_number, "", ^("%#{loa_no}%")))
  end

  defp get_loa_by_birth_date(struct, birth_date) do
    from l in struct,
      where: fragment("? = coalesce(?, ?)", l.member_birth_date, ^birth_date, l.member_birth_date)
  end

  defp get_loa_by_birth_date_without_card(struct, birth_date) do
    from l in struct,
      where: fragment("? = coalesce(?, ?)", l.member_birth_date, ^birth_date, l.member_birth_date)
  end

  defp get_loa_by_consultation_date(struct, start_date, end_date) do
    struct
    |> where([l], fragment("? between coalesce(?,?) and coalesce(?,?)",
        l.consultation_date, ^start_date,
        l.consultation_date, ^end_date,
        l.consultation_date))
  end

  defp get_loa_by_issue_date(struct, start_date, end_date) do
    struct
    |> where(
      [l],
      fragment(
        "?::date between coalesce(?,?::date) and coalesce(?,?::date)",
        # "(? at time zone 'Asia/Singapore')::date between
        # coalesce(?,(? at time zone 'Asia/Singapore')::date) and coalesce(?,(? at time zone 'Asia/Singapore')::date)",
        l.issue_date,
        ^start_date,
        l.issue_date,
        ^end_date,
        l.issue_date
      )
    )
  end

  defp get_loa_by_admission_date(struct, start_date) do
    struct
    |> where(
      [l],
      fragment(
        "?::date = ?::date",
        # "(? at time zone 'Asia/Singapore')::date between
        # coalesce(?,(? at time zone 'Asia/Singapore')::date) and coalesce(?,(? at time zone 'Asia/Singapore')::date)",
        l.admission_date,
        ^start_date
      )
    )
  end

  defp get_loa_by_is_peme(struct, is_peme) do
    struct
    |> where(
      [l],
      fragment(
        "coalesce(?,?) = ?",
        l.is_peme,
        false,
        ^is_peme
      )
    )
  end

  def get_loa_by_coverage_by_provider_by_search(params, coverage, provider_id, is_peme) do
    start_date = params["start_date"]
    end_date = params["end_date"]
    card_no = params["card_no"]
    birth_date = params["birth_date"]
    loa_no = params["loa_no"]
    payor = params["payor"]
    status = params["status"]
    birth_date = if is_nil(birth_date) or birth_date == "" do
      birth_date
    else
      birth_date = UtilityContext.format_date(birth_date)
    end
      start_date = UtilityContext.format_date(start_date)
      end_date = UtilityContext.format_date(end_date)
      query =
        Loa
        |> get_loa_by_coverage_by_provider_struct(coverage, provider_id)
        |> get_loa_by_loa_number(loa_no)
        |> get_loa_by_is_peme(is_peme)

      query =
        if is_nil(start_date) and is_nil(end_date) do
          query
        else
          query
          |> get_loa_by_issue_date(start_date, end_date)
        end
      query =
        if is_peme do

          if is_nil(start_date) and is_nil(end_date) do
            query
          else
            query
            |> get_loa_by_issue_date(start_date, end_date)
          end

          query = if is_nil(birth_date) || birth_date == "" do
            query
          else
            query
            |> get_loa_by_birth_date(birth_date)
          end

          query = if is_nil(loa_no) || loa_no == "" do
            query
          else
            query
            |> get_loa_by_loa_number(loa_no)
          end

          query = if is_nil(card_no) || card_no == "" do
             query
          else
            query
            |> get_loa_by_evoucher_number(card_no)
          end

          # cond do
          # not is_nil(birth_date) && card_no != "" ->
            #   query
            #   |> get_loa_by_birth_date_without_card(birth_date)
            #   |> get_loa_by_evoucher_number(card_no)
          # not is_nil(birth_date) ->
            #   query
            #   |> get_loa_by_birth_date_without_card(birth_date)
          # not is_nil(card_no) ->
            #   query
            #   |> get_loa_by_evoucher_number(card_no)
          # true ->
            #   query
            # end
        else
        query = query
                |> get_loa_by_birth_date(birth_date)
        query = if is_nil(card_no) || card_no == "" do
          query
        else
          query
          |> get_loa_by_card_number(card_no)
        end
        query = if is_nil(status) || status == "" do
          query
        else
          query
          |> get_loa_by_status(status)
        end

        if is_nil(payor) || payor == "" do
          query
        else
          query
          |> get_loa_by_payor(payor)
        end
      end

      query
      |> Repo.all()
      |> Repo.preload([
        [card: [member: [:payor]]],
        :member, :payor
      ])
    end

  def get_loa_by_id(id) do
    Loa
    |> Repo.get(id)
    |> Repo.preload(
      [
        :payor,
        :files,
        :provider,
        :loa_packages,
        :loa_procedures,
        card: [member: [:payor]],
        loa_diagnosis: [loa_procedure: :loa_diagnosis],
        loa_doctor: [:doctor]
    ])
  end

  def get_peme_loa_by_id(id) do
    Loa
    |> Repo.get(id)
    |> Repo.preload(
      [
        :payor,
        :files,
        :provider,
        :loa_packages,
        :loa_procedures,
        loa_diagnosis: [loa_procedure: :loa_diagnosis],
        loa_doctor: [:doctor]
      ])
  end

  def get_loa_id(id) do
    Loa
    |> Repo.get!(id)
  end

  def get_loa_by_payorlink_id(id) do
    Loa
    |> Repo.get_by([payorlink_authorization_id: id])
    |> Repo.preload(
      [
        [member: :payor],
        :files,
        :provider,
        :loa_packages,
        :loa_procedures,
        card: [member: [:payor]],
        loa_diagnosis: [loa_procedure: :loa_diagnosis],
        loa_doctor: [:doctor]
    ])
  end

  def insert_card_loa(params) do
    %Loa{}
    |> Loa.changeset_card(params)
    |> Repo.insert!()
  end

  def insert_loa_doctor(params) do
    %LoaDoctor{}
    |> LoaDoctor.create_changeset(params)
    |> Repo.insert()
  end

  def insert_loa_diagnosis(params) do
    %LoaDiagnosis{}
    |> LoaDiagnosis.create_changeset(params)
    |> Repo.insert()
  end

  def insert_loa_diagnosis!(params) do
    %LoaDiagnosis{}
    |> LoaDiagnosis.create_changeset(params)
    |> Repo.insert!()
  end

  def insert_loa_procedure(params) do
    %LoaProcedure{}
    |> LoaProcedure.create_changeset(params)
    |> Repo.insert()
  end

  def insert_loa_procedure!(params) do
    %LoaProcedure{}
    |> LoaProcedure.create_changeset(params)
    |> Repo.insert!()
  end

  def insert_loa_doctor!(params) do
    %LoaDoctor{}
    |> LoaDoctor.create_changeset(params)
    |> Repo.insert!()
  end

  # def insert_government_id(params) do
  #   %File{}
  #   |> File.changeset_loa(params)
  #   |> Repo.insert()
  # end

  # def update_government_id(file, params) do
  #   file
  #   |> File.changeset_file(params)
  #   |> Repo.update()
  # end

  def cancel_loa(loa) do
    loa
    |> Loa.changeset_status(%{status: "Cancelled"})
    |> Repo.update()
  end

  defp convert_nil_to_map(params) do
    if is_nil(params) || params == "" do
      %{}
    else
      params
    end
  end

  def create_loa_api(params) do
    changeset =
      %Loa{}
      |> Loa.api_create_changeset(params)

    with true <- changeset.valid?,
         {:ok, member_changeset} <- validate_member(params["member"]),
         true <- params["member"] |> Map.has_key?("card_number"),
         {:ok, provider_changeset} <- validate_provider(params["provider"]),
         {true, _} <- validate_diagnosis(params["diagnosis"]),
         {:ok, member = %Member{}} <-
           member_changeset
           |> Map.put(:card_number, params["member"]["card_number"])
           |> MemberContext.insert_member_not_exist,
         {:ok, provider = %Provider{}} <-
           provider_changeset
           |> ProviderContext.insert_provider_not_exist,
         {:ok, loa = %Loa{}} <-
           changeset.changes
           |> Map.put(:card_id, member.card.id)
           |> Map.put(:provider_id, provider.id)
           |> insert_loa_api
    do

      params
      |> insert_loa_diagnosis_api(loa.id)

      {:ok, changeset
      |> api_return(params)}

    else
      false ->
        {:error, changeset
        |> api_return(params)}

      {false, _} ->
        {:error, changeset
        |> api_return(params)}

      {:error, _} ->
        {:error, changeset
        |> api_return(params)}
    end
  end

  defp insert_loa_diagnosis_api(params, loa_id) do

    if params |> Map.has_key?("diagnosis") do
      params["diagnosis"]
      |> Enum.each(fn(row) ->
        row
        |> Map.put("loa_id", loa_id)
        |> insert_loa_diagnosis
      end)
    end
  end

  defp insert_loa_api(params) do
    %Loa{}
    |> Loa.api_create_changeset(params)
    |> Repo.insert
  end

  defp api_return(changeset, params) do
    {_, member} =
      params["member"]
      |> validate_member

    card_number =
      if params |> Map.has_key?("member") do
        if params["member"] |> Map.has_key?("card_number") do
          params["member"]["card_number"]
        else
          "Card number is required"
        end
      else
          "Card number is required"
      end

    member =
      member
      |> Map.put(:card_number, card_number)

    {_, provider} =
      params["provider"]
      |> validate_provider

    return =
      changeset.errors
      |> transform_validation_msg
      |> Map.merge(changeset.changes)
      |> Map.put(:member, member)
      |> Map.put(:provider, provider)

    if params |> Map.has_key?("diagnosis") do

      {_, diagnosis} =
        params["diagnosis"]
        |> validate_diagnosis

        return
        |> Map.put(
          :diagnosis,
          diagnosis
          |> Enum.into(
            [],
            fn{_, val} ->
              val
            end)
        )
    else
      return
    end
  end

  defp transform_validation_msg(changeset_error) do
    changeset_error
    |> Enum.into(
      %{},
      fn{key, {_, val}} ->
        if Keyword.get(val, :validation) == :required do
          {key, key |> convert_atom_to_text |> required_msg}
        else
          {key, key |> convert_atom_to_text |> invalid_msg}
        end
      end)
  end

  defp validate_diagnosis(params) do
    if is_nil(params) do
      {true, params}
    else
      validated_diagnosis =
        params
        |> Enum.into(
          [],
          fn(row) ->
            types = %{
              payorlink_diagnosis_id: :binary_id,
              diagnosis_code: :string,
              diagnosis_description: :string
            }

            changeset =
              {%{}, types}
              |> Changeset.cast(row, Map.keys(types))
              |> Changeset.validate_required([
                :payorlink_diagnosis_id,
                :diagnosis_code,
                :diagnosis_description
              ])

              with true <- changeset.valid?
              do
                {:ok, changeset.changes}
              else
                false ->
                  {:error, changeset.errors
                  |> transform_validation_msg
                  |> Map.merge(changeset.changes)}
              end

          end)

      {validated_diagnosis
      |> Enum.all?(fn{key, _} ->
        key == :ok
      end), validated_diagnosis}
    end
  end

  defp validate_member(params) do
    changeset =
      %Member{}
      |> Member.changeset(convert_nil_to_map(params))

    with true <- changeset.valid?
    do
      {:ok, changeset.changes}
    else
      false ->
        {:error, changeset.errors
        |> transform_validation_msg
        |> Map.merge(changeset.changes)}
    end
  end

  defp validate_provider(params) do
    changeset =
      %Provider{}
      |> Provider.create_changeset(convert_nil_to_map(params))

    with true <- changeset.valid?
    do
      {:ok, changeset.changes}
    else
      false ->
        {:error, changeset.errors
        |> transform_validation_msg
        |> Map.merge(changeset.changes)}
    end
  end

  def get_acu_details(conn, params) do
    facility_code = "facility_code=#{params.facility_code}&"
    coverage_code = "coverage_code=#{params.coverage_code}&"
    card_no = "card_no=#{params.card_no}&"
    requested_by = "requested_by=#{params.requested_by}"
    params = Enum.join([facility_code, coverage_code, card_no, requested_by])


    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/details/acu?#{params}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            with {:ok, response} <- return(response) do
              if Map.has_key?(response, "benefit_packages") do
                {:multiple, response}
              else
                {:ok, response}
              end
            else
              {:error, message} ->
                {:error, message}
            end
          _ ->
            {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  def get_peme_details(conn, params) do
    facility_code = "facility_code=#{params.facility_code}&"
    coverage_code = "coverage_code=#{params.coverage_code}&"
    member_id = "member_id=#{params.member_id}"
    params = Enum.join([facility_code, coverage_code, member_id])

    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/details/peme?#{params}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
              return_peme(response)
            _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  defp return(response) do
      decoded = Poison.decode! response.body
      if Enum.count(Map.keys(decoded)) > 2 do
        {:ok, decoded}
      else
        {:error, decoded["message"]}
      end
    rescue
      _ ->
      {:error, response.body}
  end

  defp return_peme(response) do
      decoded = Poison.decode! response.body
      if Enum.count(Map.keys(decoded)) > 2 do
        {:ok, decoded}
      else
        {:error, decoded["message"]}
      end
    rescue
      _ ->
      {:error, response.body}
  end

  def request_loa_acu(params, acu_details) do
    # with {:ok, loa} <- request_loa_acu_payorlink(params) do
      # card = get_card_by_number(params["card_no"])
      type = Enum.join([acu_details["acu_type"], " - ", acu_details["acu_coverage"]])

    payor_pays =
      if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) == Decimal.to_float(Decimal.new(0)) do
        Decimal.new(acu_details["package_facility_rate"])
      else
        if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) >
        Decimal.to_float(Decimal.new(acu_details["package_facility_rate"]))
        do
          Decimal.new(acu_details["package_facility_rate"])
        else
          Decimal.new(acu_details["limit_amount"])
        end
      end

    member_pays =
      if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) == Decimal.to_float(Decimal.new(0)) do
        Decimal.new(0)
      else
        if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) >
        Decimal.to_float(Decimal.new(acu_details["package_facility_rate"]))
        do
          Decimal.new(0)
        else
          Decimal.sub(Decimal.new(acu_details["package_facility_rate"]), Decimal.new(acu_details["limit_amount"]))
        end
      end

      # insert loa
      {:ok, loa} =
        params
        |> has_admission_date()
        |> has_discharge_date()
        |> Map.put("payorlink_authorization_id", acu_details["authorization_id"])
        |> Map.put("acu_type", type)
        |> Map.put("coverage", "ACU")
        # |> Map.put("card_id",  card.id)
        |> Map.put("created_by_id",  params["user_id"])
        |> Map.put("verification_type", params["verification_type"])
        |> Map.put("total_amount", acu_details["package_facility_rate"])
        |> Map.put("payor_pays", payor_pays)
        |> Map.put("member_pays", member_pays)
        |> Map.put("member_card_no", params["card_no"])
        |> Map.delete("member_id")
        |> insert_acu_loa()

      if params["photo"] do
        update_loa_photo(loa, params)
      end

      # insert loa packages
      params
      |> Map.merge(acu_details["package"])
      |> Map.put("payorlink_benefit_package_id", acu_details["benefit_package_id"])
      |> Map.put("description", acu_details["package"]["name"])
      |> Map.put("benefit_code", acu_details["benefit_code"])
      |> Map.put("loa_id", loa.id)
      |> Map.put("benefit_provider_access", acu_details["benefit_provider_access"])
      |> insert_loa_package()

      # insert loa procedures
      insert_loa_procedures(loa.id, acu_details["package_facility_rate"], acu_details["payor_procedure"])
      {:ok, loa}
    # end
  end

  def request_loa_acu_update(params, acu_details) do
    # with {:ok, loa} <- request_loa_acu_payorlink(params) do
      # card = get_card_by_number(params["card_no"])
      type = Enum.join([acu_details["acu_type"], " - ", acu_details["acu_coverage"]])

    payor_pays =
      if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) == Decimal.to_float(Decimal.new(0)) do
        Decimal.new(acu_details["package_facility_rate"])
      else
        if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) >
        Decimal.to_float(Decimal.new(acu_details["package_facility_rate"]))
        do
          Decimal.new(acu_details["package_facility_rate"])
        else
          Decimal.new(acu_details["limit_amount"])
        end
      end

    member_pays =
      if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) == Decimal.to_float(Decimal.new(0)) do
        Decimal.new(0)
      else
        if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) >
        Decimal.to_float(Decimal.new(acu_details["package_facility_rate"]))
        do
          Decimal.new(0)
        else
          Decimal.sub(Decimal.new(acu_details["package_facility_rate"]), Decimal.new(acu_details["limit_amount"]))
        end
      end

      # insert loa
      params =
        params
        |> has_admission_date()
        |> has_discharge_date()
        |> Map.put("payorlink_authorization_id", acu_details["authorization_id"])
        |> Map.put("acu_type", type)
        |> Map.put("coverage", "ACU")
        # |> Map.put("card_id",  card.id)
        |> Map.put("created_by_id",  params["user_id"])
        |> Map.put("verification_type", params["verification_type"])
        |> Map.put("total_amount", acu_details["package_facility_rate"])
        |> Map.put("payor_pays", payor_pays)
        |> Map.put("member_pays", member_pays)
        |> Map.put("member_card_no", acu_details["member_card_no"])
        |> Map.put("member_first_name", acu_details["member_first_name"])
        |> Map.put("member_middle_name", acu_details["member_middle_name"])
        |> Map.put("member_last_name", acu_details["member_last_name"])
        |> Map.put("member_suffix", acu_details["member_suffix"])
        |> Map.put("member_age", acu_details["member_age"])
        |> Map.put("member_status", acu_details["member_status"])
        |> Map.put("member_birth_date", acu_details["member_birth_date"])
        |> Map.put("member_gender", acu_details["member_gender"])
        |> Map.put("payorlink_member_id", acu_details["member_id"])

        {:ok, loa} = insert_acu_loa(params)

      # insert loa packages
      params
      |> Map.merge(acu_details["package"])
      |> Map.put("payorlink_benefit_package_id", acu_details["benefit_package_id"])
      |> Map.put("description", acu_details["package"]["name"])
      |> Map.put("benefit_code", acu_details["benefit_code"])
      |> Map.put("loa_id", loa.id)
      |> Map.put("benefit_provider_access", acu_details["benefit_provider_access"])
      |> Map.put("amount", acu_details["package_facility_rate"])
      |> insert_loa_package()

      # insert loa procedures
      insert_loa_procedures(loa.id, acu_details["package_facility_rate"], acu_details["payor_procedure"])
      {:ok, loa}
    # end
  end


  def request_loa_acu_update_security(params, loa, acu_details) do
    # with {:ok, loa} <- request_loa_acu_payorlink(params) do
      # card = get_card_by_number(params["card_no"])
    params = if Map.has_key?(acu_details, "benefit_packages") do
      params
    else
      type = Enum.join([acu_details["acu_type"], " - ", acu_details["acu_coverage"]])

      payor_pays =
        if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) == Decimal.to_float(Decimal.new(0)) do
          Decimal.new(acu_details["package_facility_rate"])
        else
          if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) >
          Decimal.to_float(Decimal.new(acu_details["package_facility_rate"]))
          do
            Decimal.new(acu_details["package_facility_rate"])
          else
            Decimal.new(acu_details["limit_amount"])
          end
        end

      member_pays =
        if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) == Decimal.to_float(Decimal.new(0)) do
          Decimal.new(0)
        else
          if Decimal.to_float(Decimal.new(acu_details["limit_amount"])) >
          Decimal.to_float(Decimal.new(acu_details["package_facility_rate"]))
          do
            Decimal.new(0)
          else
            Decimal.sub(Decimal.new(acu_details["package_facility_rate"]), Decimal.new(acu_details["limit_amount"]))
          end
        end

      params
      |> Map.put("total_amount", acu_details["package_facility_rate"])
      |> Map.put("payor_pays", payor_pays)
      |> Map.put("member_pays", member_pays)
      |> Map.put("acu_type", type)
    end

    request_date = ((:erlang.universaltime |> :calendar.datetime_to_gregorian_seconds) + 28800)
    request_date =
      request_date
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

      # insert loa
      params =
        params
        |> has_admission_date()
        |> has_discharge_date()
        |> Map.put("payorlink_authorization_id", acu_details["authorization_id"])
        # |> Map.put("acu_type", type)
        |> Map.put("coverage", "ACU")
        # |> Map.put("card_id",  card.id)
        |> Map.put("created_by_id",  params["user_id"])
        |> Map.put("verification_type", params["verification_type"])
        # |> Map.put("total_amount", acu_details["package_facility_rate"])
        # |> Map.put("payor_pays", payor_pays)
        # |> Map.put("member_pays", member_pays)
        |> Map.put("member_card_no", loa.member_card_no)
        |> Map.put("member_first_name", loa.member_first_name)
        |> Map.put("member_middle_name", loa.member_middle_name)
        |> Map.put("member_last_name", loa.member_last_name)
        |> Map.put("member_suffix", loa.member_suffix)
        |> Map.put("member_age", loa.member_age)
        |> Map.put("member_status", loa.member_status)
        |> Map.put("member_birth_date", loa.member_birth_date)
        |> Map.put("member_gender", loa.member_gender)
        |> Map.put("payorlink_member_id", loa.payorlink_member_id)
        |> Map.put("loa_number", acu_details["loa_number"])
        |> Map.put("request_date", request_date)

      {:ok, loa} =
        update_loa_acu(loa, params)

      if params["photo"] do
        update_loa_photo(loa, params)
      end

      if not Map.has_key?(acu_details, "benefit_packages") do
        # insert loa packages
        params
        |> Map.merge(acu_details["package"])
        |> Map.put("payorlink_benefit_package_id", acu_details["benefit_package_id"])
        |> Map.put("amount", acu_details["package_facility_rate"])
        |> Map.put("description", acu_details["package"]["name"])
        |> Map.put("benefit_code", acu_details["benefit_code"])
        |> Map.put("loa_id", loa.id)
        |> Map.put("benefit_provider_access", acu_details["benefit_provider_access"])
        |> insert_loa_package()

        # insert loa procedures
        insert_loa_procedures(loa.id, acu_details["package_facility_rate"], acu_details["payor_procedure"])
      else
        for bp <- acu_details["benefit_packages"] do
          type = Enum.join([bp["acu_type"], " - ", bp["acu_coverage"]])
          # insert loa packages
          {:ok, loa_package} = params
          |> Map.merge(bp["package"])
          |> Map.put("payorlink_benefit_package_id", bp["benefit_package_id"])
          |> Map.put("amount", bp["package_facility_rate"])
          |> Map.put("description", bp["package"]["name"])
          |> Map.put("benefit_code", bp["benefit_code"])
          |> Map.put("loa_id", loa.id)
          |> Map.put("benefit_provider_access", bp["benefit_provider_access"])
          |> Map.put("loa_benefit_acu_type", type)
          |> Map.put("loa_limit_amount", bp["limit_amount"])
          |> insert_loa_package()

          payor_procedure =
            Enum.map(bp["payor_procedure"], &(Map.put(&1, "package_id", loa_package.id)))
          # insert loa procedures
          insert_loa_procedures(loa.id, bp["package_facility_rate"], payor_procedure)
        end
      end
      {:ok, loa}
    # end
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

  def get_card_by_number(number), do: Repo.get_by(Card, number: number)

  def request_verified_loa_acu(conn, params) do
    loa = get_loa_by_id(params["loa_id"])
    params =
      params
      |> Map.put("coverage_code", "ACU")
      |> Map.put("origin", "providerlink")
      |> Map.put("card_no", loa.member_card_no)

    with {:ok, response} <- verify_loa_acu_payorlink(conn, params) do
      params =
        params
        |> has_admission_date()
        |> has_discharge_date()
        |> Map.put("valid_until", loa.member_expiry_date)
        |> Map.put("status", "Availed")
        |> Map.put("issue_date", response["request_datetime"])
        # |> Map.put("request_date", Ecto.DateTime.utc())
        #|> Map.put("loa_number", response["number"])
        |> Map.put("control_number", response["control_number"])
        |> Map.put("is_cart", false)
        |> Map.drop(["payor_pays", "member_pays", "total_amount"])

      {:ok, loa} = update_loa_acu(loa, params)

      if Map.has_key?(params, "paylink_user_id") && not is_nil(params["paylink_user_id"]) do
        if update_acu_loa_paylink_params(conn, loa) do
            user = UserContext.get_user_by_paylink_user_id(params["paylink_user_id"])
            client_ip =
              conn.remote_ip
              |> Tuple.to_list
              |> Enum.join(".")
            paylink_params = %{
              facility_code: params["facility_code"],
              client_ip: client_ip,
              user: Enum.join([user.agent.first_name, user.agent.last_name], " ")
            }
            update_paylink_dates(conn, loa, paylink_params, acu_details(get_loa_by_id(loa.id)))
            update_payorlink_loa_number(conn, loa)
        else
          {:error, "Failed to approve LOA in Paylink"}
        end
      else
        {:ok, loa}
      end
    end
  end

  def request_update_loa_acu(conn, loa, params) do
    request_date = ((:erlang.universaltime |> :calendar.datetime_to_gregorian_seconds) + 28800)
    request_date =
      request_date
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!
      |> Ecto.DateTime.to_date()

    params =
      params
      |> Map.put("coverage_code", "ACU")
      |> Map.put("origin", "providerlink")
      |> Map.put("card_no", loa.member_card_no)
      |> Map.put("valid_until", loa.member_expiry_date)
      |> Map.put("amount", params["package_facility_rate"])
      |> Map.put("admission_date", request_date)

    params = if is_nil(PG.current_resource(conn)) do
      params
      |> Map.put("facility_code", loa.provider.code)
    else
      params
      |> Map.put("facility_code", PG.current_resource(conn).agent.provider.code)
    end

    request_date = ((:erlang.universaltime |> :calendar.datetime_to_gregorian_seconds) + 28800)
    request_date =
      request_date
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

    with {:ok, response} <- request_loa_acu_payorlink(conn, params) do
      params =
        params
        |> has_admission_date()
        |> has_discharge_date()
        # |> Map.put("valid_until", member.expiry_date)
        |> Map.put("status", response["status"])
        |> Map.put("issue_date", response["request_datetime"])
        |> Map.put("request_date", request_date)
        |> Map.put("loa_number", response["number"])
        |> Map.put("control_number", response["control_number"])

      {:ok, loa} = update_loa_acu(loa, params)

      if Map.has_key?(params, "paylink_user_id") do
        if update_acu_loa_paylink_params(conn, loa) do
          user = UserContext.get_user_by_paylink_user_id(params["paylink_user_id"])
          client_ip =
            conn.remote_ip
            |> Tuple.to_list
            |> Enum.join(".")
          paylink_params = %{
            facility_code: params["facility_code"],
            client_ip: client_ip,
            user: Enum.join([user.agent.first_name, user.agent.last_name], " ")
          }
          update_paylink_dates(conn, loa, paylink_params, acu_details(get_loa_by_id(loa.id)))
          update_payorlink_loa_number(conn, loa)
        else
          {:error, "Failed to approve LOA in Paylink"}
        end
      else
        {:ok, loa}
      end
    end
  end

  def request_update_loa_acu_2(conn, loa, params) do
    request_date = ((:erlang.universaltime |> :calendar.datetime_to_gregorian_seconds) + 28800)
    request_date =
      request_date
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!
      |> Ecto.DateTime.to_date()

    params =
      params
      |> Map.put("coverage_code", "ACU")
      |> Map.put("origin", "providerlink")
      |> Map.put("card_no", loa.member_card_no)
      |> Map.put("facility_code", conn.assigns.current_user.agent.provider.code)
      |> Map.put("valid_until", loa.member_expiry_date)
      |> Map.put("amount", params["package_facility_rate"])
      |> Map.put("admission_date", request_date)

    with {:ok, response} <- request_loa_acu_payorlink(conn, params) do
      params =
        params
        |> has_admission_date()
        |> has_discharge_date()
        # |> Map.put("valid_until", member.expiry_date)
        |> Map.put("status", response["status"])
        |> Map.put("issue_date", response["request_datetime"])
        |> Map.put("request_date", Ecto.DateTime.utc())
        |> Map.put("loa_number", response["number"])
        |> Map.put("control_number", response["control_number"])
        |> Map.delete("acu_type")

        update_loa_acu(loa, params)
    end
  end

  def request_update_loa_acu_3(conn, loa, params) do
    paylink_user_id = conn.assigns.current_user.paylink_user_id
    if update_acu_loa_paylink_params(conn, loa) do
      user = UserContext.get_user_by_paylink_user_id(paylink_user_id)
      client_ip =
        conn.remote_ip
        |> Tuple.to_list
        |> Enum.join(".")
      paylink_params = %{
        facility_code: conn.assigns.current_user.agent.provider.code,
        client_ip: client_ip,
        user: Enum.join([user.agent.first_name, user.agent.last_name], " ")
      }
      update_paylink_dates(conn, loa, paylink_params, acu_details(get_loa_by_id(loa.id)))
      # update_payorlink_loa_number(conn, loa)
      {:ok, loa}
    else
      {:error, "Failed to approve LOA in Paylink"}
    end
  end

  defp update_paylink_dates(conn, loa, params, paylink_response) do
    with {:ok, paylink_response} <- create_acu_loa_paylink_params(conn, loa, params, paylink_response) do
      {:ok, loa}
    else
      {:error, message} ->
        {:error, message}
      _ ->
        {:error_updating_paylink}
    end
  end

  def update_payorlink_loa_number(conn, loa) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/#{loa.payorlink_authorization_id}/update_loa_no"
        params = %{loa_no: loa.loa_number, authorization_id: loa.payorlink_authorization_id}
        case UtilityContext.connect_to_api_put_with_token(token, url, params, "Maxicar") do
          {:ok, response} ->
              return_loa_number(response.body)
            _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  defp return_loa_number(response) do
    decoded = Poison.decode!(response)
    if decoded["message"] == "success" do
      {:ok, decoded["message"]}
    else
      {:error, decoded["message"]}
    end
  rescue
    _ ->
    {:error, "Error updating LOA number in payorlink."}
  end

  defp request_loa_acu_payorlink(conn, params) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/request/acu"
        case UtilityContext.connect_to_api_post_with_token(token, url, params, "Maxicar") do
          {:ok, response} ->
            return(response)
            _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  defp verify_loa_acu_payorlink(conn, params) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/verify/acu"
        case UtilityContext.connect_to_api_post_with_token(token, url, params, "Maxicar") do
          {:ok, response} ->
             return(response)
            _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  defp request_loa_peme_payorlink(conn, params) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/request/peme"
        case UtilityContext.connect_to_api_put_with_token(token, url, params, "Maxicar") do
          {:ok, response} ->
            return(response)
            _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  def update_loa_acu(loa, params) do
    loa
    |> Loa.acu_changeset(params)
    |> Repo.update()
  end

  def insert_acu_loa(params) do
    %Loa{}
    |> Loa.acu_changeset(params)
    |> Repo.insert()
  end

  def insert_loa_package(params) do
    %LoaPackage{}
    |> LoaPackage.changeset(params)
    |> Repo.insert()
  end

  def insert_loa_procedures(loa_id, amount, nil), do: nil
  def insert_loa_procedures(loa_id, amount, []), do: nil
  def insert_loa_procedures(loa_id, amount, params) do
    Enum.each(params, fn(param) ->
      params = %{
        payorlink_procedure_id: param["id"],
        procedure_code: param["code"],
        procedure_description: param["description"],
        amount: amount,
        loa_id: loa_id,
        package_id: param["package_id"]
      }
      insert_loa_procedure(params)
    end)
    {:ok}
  end

  defp convert_atom_to_text(key) do
    key
    |> Atom.to_string
    |> String.capitalize
    |> String.replace("_", " ")
  end

  defp required_msg(field) do
    "#{field} is required"
  end

  defp invalid_msg(field) do
    "#{field} is invalid"
  end

  def insert_pin(loa) do
    pin = "#{Enum.random(1000..9999)}"
    utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds
    pin_expiry = (utc + 5 * 60)
    pin_expiry =
      pin_expiry
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

    loa
    |> Loa.changeset_pin(%{pin: pin,
                pin_expires_at: pin_expiry})
    |> Repo.update()
  end

  def validate_pin(loa_id, pin) do
    # for refactoring
    loa = get_loa_by_id(loa_id)
    if is_nil(loa) do
      {:loa_not_found}
    else
      if String.length(pin) != 4 do
        {:invalid_pin_length}
      else
        validate_pin_expires(loa, pin)
      end
    end
  end

  defp validate_pin_expires(loa, pin) do
    if is_nil(loa.pin_expires_at) or loa.pin_expires_at == "" do
      {:pin_not_requested}
    else
      pin_expiry =
        loa.pin_expires_at
        |> Ecto.DateTime.cast!()
        |> Ecto.DateTime.compare(Ecto.DateTime.utc)

      cond do
        pin_expiry == :gt ->
          loa = Loa
                 |> where([l], l.pin == ^pin and l.id == ^loa.id)
                 |> Repo.all()
          if loa == [] do
            {:invalid_pin}
          else
            {:ok}
          end
        pin_expiry == :lt ->
          {:expired}
        true ->
          {:expired}
      end
    end
  end

  def verify_otp(loa) do
    loa
    |> Loa.changeset_otp(%{otp: true, status: "Availed"})
    |> Repo.update()
  end

  def verify_otp(loa, params) do
    loa
    |> Loa.peme_changeset(%{otp: true, status: "Availed", availment_date: Ecto.Date.cast!(params["availment_date"])})
    |> Repo.update()
  end

  def update_verification_code(loa, verification_type) do
    Repo.update(Changeset.change loa, verification_type: verification_type, otp: true)
  end

  def update_loa_photo(loa, loa_params) do
    loa
    |> Loa.changeset_photo(loa_params)
    |> Repo.update()
  end

  def insert_file(params, loa_id) do
    params = Map.put(params, "loa_id", loa_id)

    Enum.each(params["files"], fn(file) ->
      {:ok, loa_file} =
        %File{}
        |> File.changeset_loa(%{loa_id: loa_id, name: file.filename})
        |> Repo.insert()

      upload_file(loa_file, %{type: file})
    end)

    {:success}
  end

  def create_peme_claim(params) do
  claim =
    %{
      # loa_id: params["loa_id"],
      number: params["number"],
      is_claimed?: params["is_claimed?"],
       approved_datetime: Ecto.DateTime.cast!(params["approved_datetime"]),
        step: params["step"],
        valid_until: Ecto.Date.cast!(params["valid_until"]),
        migrated: params["migrated"],
        origin: params["origin"],
        # admission_datetime: Ecto.DateTime.cast!(params["admission_datetime"]),
        # discharge_datetime: Ecto.DateTime.cast!(x["discharge_datetime"]),
        status: params["status"],
        version: params["version"],
        transaction_no: params["transaction_no"],
        batch_no: params["batch_no"],
        payorlink_claim_id: params["payorlink_claim_id"],
        inserted_at: Ecto.DateTime.utc(),
        updated_at: Ecto.DateTime.utc(),
        package: params["package"],
        diagnosis: params["diagnosis"],
        procedure: params["procedure"]
      }

  end

  defp insert_peme_claim(claim) do
    %Claim{}
    |> Claim.changeset_peme_claim(claim)
    |> Repo.insert()
  end

  def verify_loa_payorlink(params, loa_id) do
    Loa
    |> Repo.get(loa_id)
    |> verify_otp()
  end

  def verify_loa_providerlink(params, loa_id) do
    Loa
    |> Repo.get(loa_id)
    |> verify_otp(params)
  end

  defp upload_file(file, params) do
    file
    |> File.changeset_file(params)
    |> Repo.update()
  end

  def acu_details(loa) do
    acu_type = String.split(loa.acu_type, "-")
    %{
      "acu_coverage" => String.trim(Enum.at(acu_type, 1)),
      "acu_type" => Enum.at(acu_type, 0),
      "benefit_package_id" => List.first(loa.loa_packages).payorlink_benefit_package_id,
      "benefit_code" => List.first(loa.loa_packages).benefit_code,
      "package" => %{
        "code" => List.first(loa.loa_packages).code,
        "name" => List.first(loa.loa_packages).description
      },
      "package_facility_rate" => loa.total_amount,
      "payor_procedure" => procedure_details(loa.loa_procedures),
      "benefit_provider_access" => List.first(loa.loa_packages).benefit_provider_access,
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

  def get_loa_by_payorlinkone_loe_no(loe_no, provider_id) do
    Loa
    |> Repo.get_by([payorlinkone_loe_no: loe_no, provider_id: provider_id])
    |> Repo.preload(
      [
        :payor,
        :files,
        :provider,
        :loa_packages,
        :loa_procedures,
        [member: :payor],
        card: [member: [:payor]],
        loa_diagnosis: [loa_procedure: :loa_diagnosis],
        loa_doctor: [:doctor]
    ])
  end

  def create_acu_loa_paylink_params(conn, loa, params, payor_response) do
    case UtilityContext.paylink_sign_in(conn, "paylinkAPI") do
      {:ok, token} ->
        params = acu_loa_paylink_1st_params(loa, params, payor_response)
        url = "api/PayLinkLOA/CreateACULOA"
        case UtilityContext.connect_to_paylink_api_post(url, token, params, "paylinkAPI") do
          {:ok, response} ->
            return_paylink(response)
          _ ->
            {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  def update_acu_loa_paylink_params(conn, loa) do
    case UtilityContext.paylink_sign_in(conn, "paylinkAPI") do
      {:ok, token} ->
        params = acu_loa_paylink_2nd_params(loa)
        url = "api/PayLinkLOA/DMLApproveLoa"
        case UtilityContext.connect_to_paylink_api_post(url, token, params, "paylinkAPI") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            if decoded do
              {:ok, decoded}
            else
              {:error, decoded["ErrorMessage"]}
            end
          _ ->
            {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  def insert_loe_n_claim_no(loa, params) do
    Repo.update(
      Changeset.change loa,
      payorlinkone_loe_no: params["Eligibility"]["AuthorizationCode"],
      payorlinkone_claim_no: "#{params["Eligibility"]["PayorLinkClaimNo"]}"
      # loa_number: params["LOAInfo"]["OrigLOANo"]
    )
  end

  defp return_paylink(response) do
    decoded = Poison.decode!(response.body)
    if Enum.count(decoded["Eligibility"]) > 1 do
      {:ok, [decoded]}
    else
      {:error, decoded["ErrorMessage"]}
    end
  rescue
    _ ->
    {:error, Poison.decode!(response.body)["ErrorMessage"]}
  end

  defp acu_loa_paylink_1st_params(loa, params, payor_response) do
    %{
      "AssessedAmnt" => assessed_amount(payor_response["package_facility_rate"]),
      "AuthorizationCode" => authorization_code(loa),
      "AvailmentDate" => admission_date_val(loa),
      "CPTList" => [
        %{
          "BenefitID" => payor_response["package"]["code"],
          "CptCode" => payor_response["package"]["code"], #Package code
          "CptDesc" => payor_response["package"]["description"], #Package desc
          "EstimatePrice" => "#{payor_response["package_facility_rate"]}",
          "IcdCode" => "Z00.0",
          "LimitCode" => "C"
         }
      ],
      "CardNo" => loa.member_card_no,
      "ClaimType" => "P",
      "Coverage" => "A",
      "CreatedBy" => "#{params.user}-PROVIDERLINK2",
      "DischargeDate" => discharge_date_val(loa),
      "Email" => loa.member_email,
      "GeneratedFrom" => "PROVIDERLINK2",
      "ICDCode" => [
        %{
          "EstimatePrice" => "#{payor_response["package_facility_rate"]}",
          "ICDCode" => "Z00.0",
          "ICDDesc" => "GENERAL EXAMINATION AND INVESTIGATION OF PERSONS WITHOUT COMPLAINT AND REPORTED DIAGNOSIS: General medical examination"
         }
      ],
      "package_name" => payor_response["package"]["name"],
      "package_code" => payor_response["package"]["code"],
      "IpAddress" => "#{params.client_ip}",
      "Mobile" => loa.member_mobile,
      "OtherPhy" => "",
      "OtherPhyType" => "",
      "PatientName" => Enum.join([loa.member_first_name, loa.member_middle_name, loa.member_last_name], " "),
      "ProviderCode" => params.facility_code,
      "ProviderInstruction" => "",
      "RefType" => "",
      "RejectCode" => "",
      "Remarks" => "",
      "RequestedBy" => "#{params.user}-PROVIDERLINK2",
      "SpecialApproval" => "",
      "LOANo" => loa.loa_number,
      "LOAStatus" => "A"
    }
  end

  defp assessed_amount(amount) do
    String.to_integer("#{amount}")
  end

  defp authorization_code(loa) do
    if is_nil(loa.payorlinkone_loe_no) do
      ""
    else
      loa.payorlinkone_loe_no
    end
  end

  defp admission_date_val(loa) do
    if is_nil(loa.admission_date) do
      Ecto.DateTime.to_iso8601(Ecto.DateTime.utc())
    else
      Ecto.DateTime.to_iso8601(loa.admission_date)
    end
  end

  defp discharge_date_val(loa) do
    if is_nil(loa.discharge_date) do
      Ecto.DateTime.to_iso8601(Ecto.DateTime.utc())
    else
      Ecto.DateTime.to_iso8601(loa.discharge_date)
    end
  end

  defp acu_loa_paylink_2nd_params(loa) do
    %{
      "ClaimNo" => loa.payorlinkone_claim_no,
      "ApprovedBy" => "",
      "Remarks" => "",
      "ProviderInstruction" => ""
     }
  end

  def get_loas_by_member_id(card_id) do
    Loa
    |> where([l], l.card_id == ^card_id and is_nil(l.status))
    |> Repo.all()
    |> Repo.preload([card: :member])
  end

  def get_loas_by_card_no(card_no) do
    Loa
    |> where([l], l.member_card_no == ^card_no)
    |> Repo.all()
    |> Repo.preload([card: :member])
  end

  def request_op_consult(conn, params) do
    params =
      params
      |> Map.put_new("provider_id", conn.assigns.current_user.agent.provider.payorlink_facility_id)
      |> Map.put_new("datetime",
          UtilityContext.transform_datetime_consult(Ecto.DateTime.to_string(Ecto.DateTime.from_erl(:erlang.localtime))))
      |> Map.put_new("origin", "provider_link")

      datetime = validate_datetime(params["datetime"])

    with {:ok} <- validate_opconsult_params(params),
         {true, _member_id} <- UtilityContext.valid_member_uuid?(params["member_id"]),
         {true, _provider_id} <- UtilityContext.valid_provider_uuid?(params["provider_id"]),
         {true, _ds_id} <- UtilityContext.valid_doctor_specialization_uuid?(params["doctor_specialization_id"]),
         {:ok, ecto_datetime} <- UtilityContext.transform_datetime(datetime),
         {:ok, loa} <- insert_op_consult(conn, params, ecto_datetime)
    do
      {:ok, loa}
    else
      {:invalid_id, message} ->
        {:error, message}
      {:invalid_datetime_format} ->
        {:error, "Invalid Consult Date"}
      {:changeset_error, changeset} ->
        {:error, changeset_errors_to_string(changeset.errors)}
      {:error, message} ->
        {:error, message}
      _ ->
        {:error, "Not Found"}
    end
  end

  defp changeset_errors_to_string(errors) do
    for {field, {message, _opts}} <- errors do
      "#{field} #{message}"
    end
    |> Enum.join(", ")
  end

  def validate_opconsult_params(params) do
    types = %{
      datetime: :string,
      diagnosis_id: :string,
      member_id: :string,
      provider_id: :string,
      card_number: :string
    }

    changeset =
      {%{}, types}
      |> Changeset.cast(params, Map.keys(types))
      |> Changeset.validate_required([
        :datetime,
        :member_id,
        :provider_id,
        :card_number,
        :diagnosis_id
      ], message: "is required")
      |> Changeset.validate_length(:diagnosis_id, min: 1,
                                        message: "at least one is required")
    if changeset.valid? do
      {:ok}
    else
      {:changeset_error, changeset}
    end
  end

  def insert_op_consult(conn, params, ecto_datetime) do
    payor = PayorContext.get_payor_by_code("Maxicar")

    loa = get_loa_by_id(params["loa_id"])

    params =
      params
      |> Map.put("conn", conn)
      |> Map.put("transaction_no", loa.transaction_id)

    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
       payorlink_member_request_consult = Enum.join([payor.endpoint, "loa/request/op-consult"], "")
        headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
        body = request_op_consult_params(params)
        case HTTPoison.post(payorlink_member_request_consult, body, headers, []) do
          {:ok, response} ->
            get_response(response, ecto_datetime, params)
          _ ->
            {:error}
        end
      {:unable_to_login} ->
        {:unable_to_login}
      _ ->
        {:unable_to_login}
    end
  end

  defp get_response(response, ecto_datetime, params) do
    decoded_resp = Poison.decode!(response.body)
    if decoded_resp != "Internal server error" do
      if Map.has_key?(decoded_resp, "message") do
        {:error, decoded_resp["message"]}
      else
        return_response(ecto_datetime, params, response)
      end
    else
      {:error, "Internal server error"}
    end
  end

  defp validate_datetime(date) do
    {date_2, time} = String.split_at(date, 11)
    [time, day]  = String.split(time)
    time = String.split(time, "")
    if List.first(time) == "0" do
      time =
        time
        |> Enum.drop(1)
        |> Enum.join()
      Enum.join([date_2, time, " #{day}"])
    else
      date
    end
  rescue
    _ ->
    date
  end

  defp request_op_consult_params(params) do
    Poison.encode!(%{
      "member_id": params["member_id"],
      "card_number": params["card_number"],
      "facility_id": params["provider_id"],
      "datetime": validate_datetime(params["datetime"]),
      "diagnosis_id": params["diagnosis_id"],
      "practitioner_specialization_id": params["doctor_specialization_id"],
      "consultation_type": params["consultation_type"],
      "chief_complaint": params["chief_complaint"],
      "origin": "providerlink",
      "transaction_no": params["transaction_no"]
    })
  end

  defp return_response(ecto_datetime, params, response) do
    decoded = Poison.decode!(response.body)
    if Enum.count(Map.keys(decoded)) > 2 do
      insert_loa_api_response(decoded, ecto_datetime, params)
    else
      cond do
        decoded["message"] == "Doctor Not Found" ->
          {:doctor_not_found}
        decoded["message"] == "Member Not Found" ->
          {:member_not_found}
        true ->
          {:error, decoded["message"]}
      end
    end
  end

  defp insert_loa_api_response(decoded, ecto_datetime, params) do
    cond do
      MemberContext.get_member_by_payorlink_id(params["member_id"]) == nil ->
        {:missing, "Member not validated"}
      is_nil(params["doctor_specialization_id"]) ->
        {:missing, "Doctor not linked to payorlink"}
      true ->
        member = MemberContext.get_member_by_payorlink_id(params["member_id"])
        doctor = DoctorContext.get_doctor_by_payorlink_id(params["doctor_specialization_id"])
        provider = DoctorContext.get_provider_by_payorlink_id(params["provider_id"])
        params = Map.put(params, "ecto_datetime", ecto_datetime)
        insert_loa_consult(decoded, member, params, provider)
    end
  end

  defp insert_loa_consult(decoded, member, params, nil) do
    {:missing, "Provider not linked to payorlink"}
  end

  defp insert_loa_consult(decoded, member, params, provider) do
    params = op_consult_params(decoded, member, params, provider)
    with {:ok, loa} <- insert_loa_consult(params) do
      {:ok, loa}
    else
      _ ->
        {:error, :not_found}
    end
  end

  defp op_consult_params(decoded, member, params, provider) do
    user_id = params["conn"].assigns.current_user.id
    valid_until =
      ((:erlang.universaltime |> :calendar.datetime_to_gregorian_seconds) + 172_800)
    valid_until =
      valid_until
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!
    %{
      "card_id" => CardContext.get_card(params["card_number"]).id,
      "payorlink_authorization_id" => decoded["id"],
      "payor_pays" => decoded["amount"]["payor_pays"],
      "member_pays" => decoded["amount"]["member_pays"],
      "total_amount" => Decimal.add(Decimal.new(decoded["amount"]["member_pays"]), Decimal.new(decoded["amount"]["payor_pays"])),
      "provider_id" => ProviderContext.get_provider_by_payorlink_facility_id(decoded["facility"]["id"]).id,
      "chief_complaint" => decoded["chief_complaint"],
      "consultation_type" => params["consultation_type"],
      "consultation_date" => Ecto.DateTime.from_erl(:erlang.localtime),
      "admission_date" => Ecto.DateTime.cast!(decoded["admission_datetime"]),
      "request_date" => Ecto.DateTime.cast!(decoded["request_datetime"]),
      "loa_number" => decoded["number"],
      "status" => decoded["status"],
      "coverage" => "OP Consult",
      "validated" => true,
      "origin" => params["origin"],
      "valid_until" => valid_until,
      "created_by_id" =>  user_id,
      "updated_by_id" =>  user_id,
      "loa_id" => params["loa_id"],
      "control_number" => decoded["control_number"],
      "issue_date" => Ecto.DateTime.from_erl(:erlang.localtime)
    }
  end

  def insert_loa_consult(params) do
    loa = get_loa_by_id(params["loa_id"])
    loa
    |> Loa.opconsult_changeset(params)
    |> Repo.update()
  end

  def get_loas_by_member(member_id) do
    Loa
    |> where([l], l.member_id == ^member_id and is_nil(l.status))
    |> Repo.all()
    |> Repo.preload([member: :card])
  end

  def request_loa_peme(conn, loa, params, peme_details) do
    member = MemberContext.get_member(params["member_id"])
      # update loa
      loa_params =
        params
        |> Map.put("payorlink_authorization_id", peme_details["authorization_id"])
        |> Map.put("coverage", "PEME")
        |> Map.put("member_id",  params["member_id"])
        |> Map.put("created_by_id",  params["user_id"])
        |> Map.put("total_amount", peme_details["package_facility_rate"])
        |> Map.put("member_pays", Decimal.new(0))
        |> Map.put("payor_pays", peme_details["package_facility_rate"])
        |> Map.delete("member_id")

        {:ok, loa} =
          loa
          |> update_loa_acu(loa_params)

      # insert loa packages
      loa_params =
        params
        |> Map.merge(peme_details["package"])
        |> Map.put("payorlink_benefit_package_id", peme_details["benefit_package_id"])
        |> Map.put("description", peme_details["package"]["name"])
        |> Map.put("benefit_code", peme_details["benefit_code"])
        |> Map.put("loa_id", loa.id)

      insert_loa_package(loa_params)

      # insert loa procedures
      insert_loa_procedures(loa.id, peme_details["package_facility_rate"], peme_details["payor_procedure"])

      {:ok, loa}

      params =
        params
        |> Map.put("origin", "providerlink")
        |> Map.put("member_id", loa.payorlink_member_id)
        |> Map.put("facility_code", conn.assigns.current_user.agent.provider.code)
        |> Map.put("authorization_id", peme_details["authorization_id"])
        |> Map.put("coverage_code", "PEME")

    with {:ok, response} <- request_loa_peme_payorlink(conn, params) do
      params =
        params
        # |> has_admission_date()
        # |> has_discharge_date()
        # |> Map.put("valid_until", member.expiry_date)
        |> Map.put("status", response["status"])
        |> Map.put("issue_date", response["request_datetime"])
        |> Map.put("request_date", Ecto.DateTime.utc())
        |> Map.drop(["member_id"])
        |> Map.put("is_peme", true)
        |> Map.put("otp", true)
        |> Map.put("provider_id", conn.assigns.current_user.agent.provider.id)
        |> Map.put("loa_number", response["number"])

      update_loa_acu(loa, params)
    end
  end

  def create_peme_loa_accountlink(conn, peme_params) do
    with {:ok, loa} <- insert_peme_loa_accountlink(conn, peme_params) do
       {:ok, loa}
    else
      _ ->
        {:error}
    end
  end

  def insert_peme_loa_accountlink(conn, decoded) do
    {_, admission_datetime} = decoded["admission_date"] <> " 00:00:00"
                         |> Ecto.DateTime.cast()
    {_, discharge_datetime} = decoded["discharge_date"] <> " 00:00:00"
                         |> Ecto.DateTime.cast()
    provider_id = get_provider_by_facility_id(decoded["facility_id"])
    with nil <- get_member_by_payorlink_member_id(decoded["id"]) do
        payor = PayorContext.get_payor_by_code("Maxicar")

        loa_params = %{
        "member_first_name" => decoded["first_name"],
        "member_middle_name" => decoded["middle_name"],
        "member_last_name" => decoded["last_name"],
        "member_suffix" => decoded["suffix"],
        "member_birth_date" => decoded["birthdate"],
        "member_age" => get_age(Ecto.Date.cast!(decoded["birthdate"])),
        "member_card_no" => decoded["card_no"],
        "payorlink_member_id" => decoded["id"],
        "member_evoucher_number" => decoded["evoucher"],
        "member_evoucher_qr_code" => "",
        "member_male?" => decoded["male"],
        "member_female?" => decoded["female"],
        "member_status" => "Active",
        "member_email" => decoded["email"],
        "member_mobile" => decoded["mobile"],
        "member_type" => decoded["type"],
        "member_account_code" => decoded["account_code"],
        "payorlink_authorization_id" => decoded["authorization_id"],
        "member_account_name" => decoded["account_name"],
        "member_gender" => decoded["gender"],
        "coverage" => "PEME",
        "created_by_id" => decoded["created_by_id"],
        "updated_by_id" => decoded["created_by_id"],
        "payor_id" => payor.id,
        "issue_date" => Ecto.DateTime.utc(),
        "request_date" => Ecto.DateTime.utc(),
        "status" => "Approved",
        "is_peme" => true,
        "provider_id" => provider_id,
        "total_amount" => decoded["package_facility_rate"],
        "member_pays" => Decimal.new(0),
        "payor_pays" => decoded["package_facility_rate"],
        "origin" => "Accountlink",
        "loa_number" => decoded["number"],
        "admission_date" => admission_datetime,
        "discharge_date" => discharge_datetime
        }

        loa = insert_peme_loa(loa_params)

        loa_packages =
          decoded
          |> Map.put("payorlink_benefit_package_id", decoded["benefit_package_id"])
          |> Map.put("description", decoded["package_name"])
          |> Map.put("benefit_code", decoded["benefit_code"])
          |> Map.put("code", decoded["package_code"])
          |> Map.put("loa_id", loa.id)

        insert_loa_package(loa_packages)
        insert_loa_procedures(loa.id, decoded["package_facility_rate"], decoded["payor_procedure"])

        {:ok, loa}

    else
    {:invalid, message} ->
      {:invalid, message}

      loa = %Loa{} ->
        {:ok, loa}

        _ ->
          {:error}
    end
  end

  def get_provider_by_facility_id(id) do
    provider =
      Provider
      |> Repo.get_by([payorlink_facility_id: id])

    if not is_nil(provider), do: provider.id, else: nil
  end

  def reschedule_loa(conn, params) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/reschedule?id=#{params.loa_id}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            return_response(decoded)
            _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  defp return_response(decoded) do
    valid_until =
      ((:erlang.universaltime |> :calendar.datetime_to_gregorian_seconds) + 172_800)
    valid_until =
      valid_until
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

    valid_until = Ecto.Date.cast!(valid_until)

    old_loa = get_loa_by_payorlink_id(decoded["old_authorization_id"])
    new_loa_params = %{
      card_id: old_loa.card_id,
      coverage: old_loa.coverage,
      status: old_loa.status,
      inserted_at: old_loa.inserted_at,
      updated_at: old_loa.updated_at,
      loa_number: old_loa.loa_number,
      provider_id: old_loa.provider_id,
      consultation_date: old_loa.consultation_date,
      member_pays: old_loa.member_pays,
      payor_pays: old_loa.payor_pays,
      total_amount: old_loa.total_amount,
      created_by_id: old_loa.created_by_id,
      updated_by_id: old_loa.updated_by_id,
      verification_type: old_loa.verification_type,
      issue_date:  Ecto.DateTime.from_erl(:erlang.localtime),
      valid_until: valid_until,
      admission_date: Ecto.DateTime.from_erl(:erlang.localtime),
      discharge_date: old_loa.discharge_date,
      request_date: old_loa.request_date,
      acu_type: old_loa.acu_type,
      payorlink_authorization_id: decoded["new_authorization_id"],
      origin: old_loa.origin,
      otp: old_loa.otp,
      pin: old_loa.pin,
      pin_expires_at: old_loa.pin_expires_at,
      photo: old_loa.photo,
      photo_type: old_loa.photo_type,
      payorlinkone_loe_no: old_loa.payorlinkone_loe_no,
      payorlinkone_claim_no: old_loa.payorlinkone_claim_no,
      member_id: old_loa.member_id,
      is_peme: old_loa.is_peme,
      consultation_type: old_loa.consultation_type,
      chief_complaint: old_loa.chief_complaint,
      chief_complaint_others: old_loa.chief_complaint_others,
      transaction_id: old_loa.transaction_id
    }

    {:ok, new_loa} = %Loa{}
    |> Loa.copy_loa_changeset(new_loa_params)
    |> Repo.insert()

    old_loa_doctor = get_loa_doctor_by_loa_id(old_loa.id)
    new_loa_doctor_params = %{
      loa_id: new_loa.id,
      doctor_id: old_loa_doctor.doctor_id
    }

    %LoaDoctor{}
    |> LoaDoctor.create_changeset(new_loa_doctor_params)
    |> Repo.insert()

    old_loa_diagnosis = get_loa_diagnosis_by_loa_id(old_loa.id)
    new_loa_diagnosis_params = %{
      diagnosis_code: old_loa_diagnosis.diagnosis_code,
      diagnosis_description: old_loa_diagnosis.diagnosis_description,
      payorlink_diagnosis_id: old_loa_diagnosis.payorlink_diagnosis_id,
      loa_id: new_loa.id
    }

    %LoaDiagnosis{}
    |> LoaDiagnosis.create_changeset(new_loa_diagnosis_params)
    |> Repo.insert()

    old_loa
    |> Loa.changeset_status(%{status: "Cancelled"})
    |> Repo.update()

    {:ok, new_loa}
  end

  def get_loa_doctor_by_loa_id(loa_id) do
    LoaDoctor
    |> Repo.get_by([loa_id: loa_id])
  end

  def get_loa_diagnosis_by_loa_id(loa_id) do
    LoaDiagnosis
    |> Repo.get_by([loa_id: loa_id])
  end

  def get_all_specializations do
    Specialization
    |> Repo.all
  end

  def delete_loa_by_id(id) do
    id
    |> get_loa_id()
    |> Repo.delete()
  end

  def update_payorlink_loa_status(conn, loa) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/#{loa.payorlink_authorization_id}/update_otp_status"
        params = %{loa_no: loa.loa_number, batch_no: loa.payorlinkone_batch_no}
        case UtilityContext.connect_to_api_put_with_token(token, url, params, "Maxicar") do
          {:ok, response} ->
              return_loa_status(response.body)
          _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  def update_peme_payorlink_loa_status(conn, loa, params) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/#{loa.payorlink_authorization_id}/update_peme_status"
        params = %{loa_no: loa.loa_number, availment_date: params["availment_date"]}
        case UtilityContext.connect_to_api_put_with_token(token, url, params, "Maxicar") do
          {:ok, response} ->
            create_peme_claim(Poison.decode!(response.body))
            |> Map.put_new(:loa_id, loa.id)
            |> Map.put_new(:created_by_id, conn.assigns.current_user.id)
            |> Map.put_new(:updated_by_id, conn.assigns.current_user.id)
            |> insert_peme_claim()
          _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  defp return_loa_status(response) do
    decoded = Poison.decode!(response)
    if decoded["message"] == "success" do
      {:ok, decoded["message"]}
    else
      {:error, decoded["message"]}
    end
  rescue
    _ ->
    {:error, "Error updating LOA status in payorlink."}
  end

  def upload_soa_file(id, file) do
    raise file
  end

  def save_discharge_date(loa_id, date) do
    loa = get_loa_by_id(loa_id)

    if not is_nil(date) and date != "" do
      date = Ecto.DateTime.cast!("#{date} 00:00:00")

      loa
      |> Loa.changeset_discharge_date(%{discharge_date: date})
      |> Repo.update()
    end
  end

  # def update_cart_and_batch(loa_id) do
  #   loa = get_loa_by_id(loa_id)

  #   Loa
  #   |>
  # end

  def update_all_loa(loa_ids) do
    loa_ids = Enum.reject(loa_ids, &(&1 == ""))
    is_cart = Loa
              |> where([l], l.id in ^loa_ids)
              |> Repo.update_all(set: [is_cart: true])
    {:ok, is_cart}
  end

  def dummy_data do
    Enum.map(1..7, fn(_) ->
      member = struct(Member, %{
        gender: "Male",
        birth_date: Ecto.Date.cast!("2001-12-25")
      })
      card = struct(Card, %{
        number: "#{Enum.random(1_000_000_000_000_000..9_999_999_999_999_999)}",
        member: member
      })
      loa = struct(Loa, %{
        id: Ecto.UUID.generate(),
        status: "Approved",
        loa_number: "#{Enum.random(10000..99999)}",
        member: member,
        card: card,
        total_amount: Decimal.new(1000),
        is_batch: false,
        is_cart: false,
        inserted_at: DateTime.utc_now()
      })
      Repo.preload(loa, [card: :member])
    end)
  end

  def list_all_cart_loa() do
    Loa
    |> where([l], l.is_cart == true and l.is_batch == false)
    |> Repo.all()
    |> Repo.preload(:payor)
  end

  def update_loa_cart(params) do
    loa = get_loa_by_id(params["id"])
    if not is_nil(loa) do
      update_is_cart(loa, true)
    else
      {:not_found}
    end
  end

  def update_loa_batch(params) do
    loa = get_loa_by_id(params["loa_id"])
    if not is_nil(loa) && loa.is_cart == true do
      update_is_batch(loa, true)
    else
      {:not_found}
    end
  end

  defp update_is_cart(loa, status) do
    params = %{"is_cart" => status}
    loa
    |> Loa.changeset_cart(params)
    |> Repo.update()
  end


  defp update_is_batch(loa, status) do
    params = %{"is_batch" => status}
    loa
    |> Loa.changeset_batch(params)
    |> Repo.update()
  end

  def remove_loa_cart(id) do
    loa = get_loa_by_id(id)
    if not is_nil(loa) && loa.is_cart == true do
      update_is_cart(loa, false)
    else
      {:not_found}
    end
  end

  # START OF PEME INTEGRATION FOR IN LOA TABLE

  def insert_peme_loa(params) do
    %Loa{}
    |> Loa.peme_changeset(params)
    |> Repo.insert!()
  end

  def get_member_by_payorlink_member_id(payorlink_member_id) do
    Loa
    |> Repo.get_by(payorlink_member_id: payorlink_member_id)
  end

  def get_member_by_payorlink_authorization_id(payorlink_authorization_id) do
    Loa
    |> Repo.get_by(payorlink_authorization_id: payorlink_authorization_id)
  end

  def get_member_by_card_number(card_no) do
    Loa
    |> Repo.get_by(member_card_no: card_no)
  end

  def approve_payorlink_loa_status(conn, loa) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "loa/#{loa.payorlink_authorization_id}/approve_loa_status"
        params = %{loa_no: loa.loa_number}
        case UtilityContext.connect_to_api_put_with_token(token, url, params, "Maxicar") do
          {:ok, response} ->
            {:ok, decoded = Poison.decode!(response.body)}
          _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  def update_status(%Loa{} = loa, params) do
    loa
    |> Loa.changeset_status(params)
    |> Repo.update()
  end

  def list_all_cart_loa_ids() do
    loa =
      Loa
      |> where([l], l.is_cart == true and l.is_batch == false)
      |> select([l], l.id)
      |> Repo.all()
  end

  def get_loas_by_search(value) do
    Loa
    |> where([l], (ilike(fragment("text(?)", l.loa_number), ^"%#{value}%") or ilike(fragment("text(?)", l.total_amount), ^"%#{value}%") or ilike(fragment("text(?)", l.inserted_at), ^"%#{value}%")))
    |> where([l], l.is_cart == true and l.is_batch == false)
    |> Repo.all()
    |> Repo.preload([
      [card: [member: [:payor, :card]]],
      :member
    ])
  end

  def loa_batch_op_consult_checker(loa_ids) do
    consult_ids =
      Loa
      |> where([l], l.id in ^loa_ids)
      |> where([l], l.coverage == "OP Consult")
      |> select([l], l.id)
      |> Repo.all()
    if Enum.count(loa_ids) == Enum.count(consult_ids) do
      true
    else
      false
    end
  end

  def loa_batch_hb_checker(loa_ids) do
    coverage_loa_ids =
      Loa
      |> where([l], l.id in ^loa_ids)
      |> where([l], l.coverage == "OP Consult"
               or l.coverage == "ACU"
               or l.coverage == "PEME"
               or l.coverage == "OP Laboratory"
               or l.coverage == "Inpatient"
      )
      |> select([l], l.id)
      |> Repo.all()
    if Enum.count(loa_ids) == Enum.count(coverage_loa_ids) do
      true
    else
      false
    end
  end

  def remove_is_batch(id) do
    Loa
    |> Repo.get(id)
    |> Ecto.Changeset.change(%{is_batch: false})
    |> Repo.update()
  end

#From Member Context

 def validate_member_by_details(conn, facility_code, full_name, birth_date, coverage) do
    with {:ok, member} <-
      get_payorlink_member_by_details(
        conn,
        facility_code,
        full_name,
        birth_date,
        coverage
      )
    do
      {:ok, [member]}
    else
      {:multiple, member} ->
         {:ok, member}
      {:member_not_found} ->
        {:member_not_found}
      {:invalid, message} ->
        {:invalid, message}
      [{:invalid, message}] ->
        {:invalid, message}
      {:unable_to_login} ->
        {:invalid, "Unable to login in PayorLink API"}
      _ ->
        {:error, "Not found"}
    end
  end

  defp get_payorlink_member_by_details(conn, facility_code, full_name, birth_date, coverage) do
    with {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
         {:ok, response} <- get_member_in_payorlink(token, full_name, birth_date),
         {:ok, decoded} <- decode_response(response.body)
    do
      valid_response = validate_response(decoded)

      cond do
        valid_response == {:invalid_response} ->
          validate_message(decoded["error"]["message"])
        Enum.count(decoded) == 1 ->
          single_member(decoded, token, coverage, facility_code)
        true ->
          multiple_member(decoded, token, coverage, facility_code)
      end
    else
      {:error} ->
        {:invalid, "Timeout Error"}
      {:internal} ->
        {:invalid, "Payorlink Internal Server Error"}
      {:invalid, message} ->
        {:invalid, message}
      {:unable_to_login} ->
        {:unable_to_login}
    end
  rescue
    _ ->
      {:invalid, "Payorlink Internal Server Error"}
  end

  defp single_member(decoded, token, coverage, facility_code) do
    decoded = Enum.at(decoded, 0)
    cond do
      downcase(decoded["status"]) != "active" ->
        {:invalid, "Member status must be Active to avail ACU."}
      decoded["attempts"] >= 3 ->
        {:invalid, "Member is Blocked. Please contact Maxicare."}
      true ->
        member = %{
          number_of_dependents: Enum.count(decoded["dependents"]),
          principal: decoded["first_name_principal"],
          type: downcase(decoded["type"]),
          relationship: decoded["relationship"],
          last_facility: string_upcase(decoded["latest_facility"]),
          latest_consult: decoded["latest_consult"],
          attempts: decoded["attempts"],
          member_card_no: decoded["card_no"],
          random_facility1: string_upcase(decoded["random_facility1"]),
          random_facility2: string_upcase(decoded["random_facility2"])
        }

        with {:valid, _} <- validate_loa_coverage(token, decoded["card_no"], facility_code, coverage) do
          {:ok, [member]}
        else
          {:invalid, message} ->
            validate_message(message)
        end
    end
  end

  defp multiple_member(decoded, token, coverage, facility_code) do
    members =
      for decoded <- decoded do
        member = %{
          first_name: decoded["first_name"],
          middle_name: decoded["middle_name"],
          last_name: decoded["last_name"],
          extension: decoded["suffix"],
          birth_date: decoded["birthdate"],
          type: downcase(decoded["type"]),
          account_name: decoded["account_name"],
          member_card_no: decoded["card_no"],
          attempts: decoded["attempts"]
        }
      end

    {:multiple, members}
  end

 defp validate_message(message) do
    message =
      cond do
        message == "Member not found" ->
          "Please enter valid member name/birthdate to avail ACU."
        message == "Please enter card number" ->
          "Member has no Card Number."
        message == "Facility code not found." ->
          "Agent's provider not found in PayorLink"
        true ->
          message
      end

    {:invalid, message}
  end

  defp downcase(string) do
    String.downcase("#{string}")
  end

  def validate_loa_coverage(token, card_no, facility_code, coverage) do
    loa = URI.encode("loa/validate/coverage?card_no=#{card_no}&facility_code=#{facility_code}&coverage_name=#{coverage}")
    body = %{"card_no": card_no, "facility_code": facility_code, "coverage_name": coverage}

    case UtilityContext.connect_to_api_post_with_token(token, loa, body, "Maxicar") do
        {:ok, response} ->
          decoded = Poison.decode!(response.body)

          cond do
            not is_nil(decoded["error"]["message"]) ->
              {:invalid, decoded["error"]["message"]}
            not is_nil(["message"]) ->
                {:valid, decoded["multiple"]}
            true ->
              {:invalid, "PayorLink Internal Server Error"}
          end
        _ ->
         {:invalid, "PayorLink Internal Server Error"}
      end
    rescue
      _ ->
      {:invalid, "PayorLink Internal Server Error"}
  end

  defp get_member_in_payorlink(token, full_name, birth_date) do
    payorlink_practitioner = "member/validate/details"
    body = %{"params": %{"full_name": full_name, "birth_date": birth_date}}

    UtilityContext.connect_to_api_post_with_token(token, payorlink_practitioner, body, "Maxicar")
  end

  defp validate_response(response) do
    List.first(response)
    rescue
      _ ->
        {:invalid_response}
  end

  def payorlink_get_member(conn, card_no) do
    with {:ok, response} <- UtilityContext.connect_to_api_get(conn, "Maxicar", "member/security?card_no=#{card_no}"),
         {:ok, decoded} <- decode_response(response.body)
    do
      validate_decoded_security(!is_nil(decoded["error"]["message"]), decoded)
    else
      {:error} ->
        {:error}
      {:internal} ->
        {:internal}
      {:error_connecting_api} ->
        {:error}
      {:unable_to_login} ->
        {:unable_to_login}
      {:payor_does_not_exists} ->
        {:payor_does_not_exists}
      {:invalid, message} ->
        {:invalid, message}
      _ ->
        {:internal}
    end
  rescue
    _ ->
     {:internal}
  end

  defp validate_decoded_security(true, decoded), do: {:invalid, decoded["error"]["message"]}
  defp validate_decoded_security(false, decoded), do: validate_decoded_security2(decoded, decoded["id"])

  defp validate_decoded_security2(_, nil), do: {:invalid, "The Card number you have entered is invalid"}
  defp validate_decoded_security2(decoded, _), do: member_return(decoded)

  defp member_return(decoded) do
    principal = get_principal(decoded["principal_id"], decoded["first_name_principal"])

      payor = PayorContext.get_payor_by_code("Maxicar")
      member = %{
        first_name: decoded["first_name"],
        middle_name: decoded["middle_name"],
        last_name: decoded["last_name"],
        birth_date: decoded["birthdate"],
        gender: decoded["gender"],
        extension: decoded["suffix"],
        number_of_dependents: Enum.count(decoded["dependents"]),
        email_address: decoded["email"],
        email_address2: decoded["email2"],
        mobile: decoded["mobile"],
        mobile2: decoded["mobile2"],
        principal: principal,
        type: String.downcase(decoded["type"]),
        payorlink_member_id: decoded["id"],
        account_code: decoded["account_code"],
        account_name: decoded["account_name"],
        evoucher_number: decoded["evoucher_number"],
        payor_id: payor.id,
        relationship: decoded["relationship"],
        last_facility: string_upcase(decoded["latest_facility"]),
        card_number: decoded["card_no"],
        latest_consult: decoded["latest_consult"],
        attempts: decoded["attempts"],
        attempt_expiry: decoded["attempt_expiry"],
        member_card_no: decoded["card_no"],
        loa_id: "",
        member_expiry_date: decoded["expiry_date"],
        member_email: decoded["email"],
        member_mobile: decoded["mobile"],
        patient_name: Enum.join([decoded["first_name"], decoded["middle_name"], decoded["last_name"]], " "),
        remarks: "valid",
        member_first_name: decoded["first_name"],
        member_middle_name: decoded["middle_name"],
        member_last_name: decoded["last_name"],
        member_suffix: decoded["extension"],
        member_birth_date: decoded["birthdate"],
        member_age: ProviderLinkWeb.LoaView.get_age(decoded["birthdate"]),
        member_gender: decoded["gender"],
        loa_number: decoded["number"],
        random_facility1: string_upcase(decoded["random_facility1"]),
        random_facility2: string_upcase(decoded["random_facility2"])
      }
    {:ok, member}
  end

  defp get_principal(nil, _), do: nil
  defp get_principal(_, principal), do: principal

  def loa_doctor_checker(loa_ids, batch_id) do
    batch = BatchContext.get_batch(batch_id)

    loa_doctors = Enum.map(loa_ids, fn(loa_id) ->
      loa_doctor = get_loa_doctor_by_loa_id(loa_id)
      if not is_nil(loa_doctor) do
        if not is_nil(loa_doctor.doctor_id) do
          loa_doctor.doctor_id
        else
          ""
        end
      else
        ""
      end
    end)

    if batch.type == "practitioner" do
      pf_batch = Enum.map(loa_doctors, fn(loa_d_id) ->
        batch.doctor_id == loa_d_id
      end)

      if Enum.all?(pf_batch) do
        {:ok, loa_ids}
      else
        {:not_equal_doctor_id}
      end
    else
      {:ok, loa_ids}
    end
  end

  def loa_batch_existing_op_consult_checker(loa_ids, batch) do
    if batch.type == "practitioner" do
      consult_ids =
        Loa
        |> where([l], l.id in ^loa_ids)
        |> where([l], l.coverage == "OP Consult")
        |> select([l], l.id)
        |> Repo.all()
        if Enum.count(loa_ids) == Enum.count(consult_ids) do
          true
        else
          false
        end
    else
      true
    end
  end

  def validate_number(_, no, _, _, _) when is_nil(no) or no == "",  do:
    {:invalid, "Card Number is required"}
  def validate_number(_, _, bd, _, _) when is_nil(bd) or bd == "",  do:
    {:invalid, "Card Number is required"}

  defp validate_card_number(nil, _), do: {:invalid, "Card Number is required"}
  defp validate_card_number("", _), do: {:invalid, "Card Number is required"}
  defp validate_card_number(_, 16), do: {:valid}
  defp validate_card_number(_, _), do: {:invalid, "Card Number should be 16-digit"}

  def validate_number(conn, number, bdate, current_provider, coverage) do
    with {:valid} <- validate_card_number(number, String.length(number)),
         {:valid} <- get_payorlink_member_card(conn, number, bdate),
         {:eligible} <- payorlink_loa_validate(conn, number, current_provider, coverage)
    do
      {:valid}
    else
      {:invalid, message} ->
        {:invalid, message}

      ### for get_payorlink_member_card return
      {:internal} ->
        {:internal}

      {:member_not_active} ->
        {:member_not_active}

      ### for payorlink_loa_validate return
      {:unable_to_login} ->
        {:unable_to_login}

      {:payor_does_not_exists} ->
        {:payor_does_not_exists}

      {:internal_get_error} ->
        {:internal_get_error}

      {:error_message, message} ->
        {:error_message, message}

      ### for validate_card_no_bdate return
      {:card_no_bdate_not_matched, message} ->
        {:card_no_bdate_not_matched, message}

      ##########################################

      _ ->
        {:error}
    end
  end

  def get_payorlink_member_card(conn, number, bdate) do
    with {:ok, response} <- UtilityContext.connect_to_api_post(conn, "Maxicar", "member/validate/card", %{"card_number": number, "birth_date": bdate}),
         {:ok, decoded} <- decode_response(response.body)
    do
      validate_decoded_member(!is_nil(decoded["error"]["message"]), decoded)
    else
      {:internal} ->
        {:internal}
      {:error} ->
        {:error}
      {:error_connecting_api} ->
        {:error}
      {:unable_to_login} ->
        {:unable_to_login}
      {:payor_does_not_exists} ->
        {:payor_does_not_exists}
      {:invalid, message} ->
        {:invalid, message}
      _ ->
        {:internal}
    end
  end

  defp decode_response("Internal server error"), do: {:internal}
  defp decode_response("Page not found"), do: {:internal}
  defp decode_response("[]"), do: {:error}
  defp decode_response(body) do
    decoded = Poison.decode!(body)
    validate_decoded(String.valid?(decoded), decoded)
  rescue
    _ ->
      {:internal}
  end

  defp validate_decoded(true, message), do: message
  defp validate_decoded(false, decoded), do: {:ok, decoded}

  defp validate_decoded_member(true, decoded), do: {:invalid, decoded["error"]["message"]}
  defp validate_decoded_member(false, decoded), do: validate_decoded_member2(decoded["id"], decoded)

  defp validate_decoded_member2(nil, _), do: {:invalid, "The Card number you have entered is invalid"}
  defp validate_decoded_member2(_, decoded), do: member_return(decoded)

  def payorlink_loa_validate(conn, card_no, current_provider, coverage) do
    with {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
         {:ok, response} <-
          UtilityContext.connect_to_api_post_with_token(
            token,
            "loa/validate/coverage",
            %{"card_no": card_no, "facility_code": current_provider, "coverage_name": coverage},
            "Maxicar"
          ),
         {:ok, decoded} <- decode_response(response.body),
         {:eligible} <- payorlink_loa_validate_return(decoded["message"], decoded["error"]["message"], decoded)
    do
      {:eligible}
    else
      nil ->
        {:payor_does_not_exists}
      {:internal} ->
        {:internal_get_error}
      {:error} ->
        {:error_message, "PayorLink connection timeout"}
      {:error_connecting_api} ->
        {:error_message, "PayorLink connection timeout"}
      {:error_message, message} ->
        {:error_message, message}
    end
  rescue
    _ ->
      {:internal_get_error}
  end

  defp string_upcase(nil), do: nil
  defp string_upcase(string), do: String.upcase("#{string}")

  defp payorlink_loa_validate_return(_, nil, _), do: {:eligible}
  defp payorlink_loa_validate_return(nil, message, _), do: {:error_message, message}
  defp payorlink_loa_validate_return(_, _, message), do: {:error_message, message}

  defp internal_error?(response) do
    case response.body do
      "Internal server error" ->
        {:internal}
      _ ->
        {:ok, response}
    end
  end

  defp validate_card_no_bdate(number, bdate, member) do
    if number == member.member_card_no and bdate == member.birth_date do
      {:card_no_bdate_matched}
    else
        {:card_no_bdate_not_matched, "Please enter valid card number/birthdate to avail ACU."}
    end
  end

  def add_attempt_to_payorlink_member(conn, card_no) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "members/add/attempt?card_no=#{card_no}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            decoded["message"]
            _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

 def remove_attempt_to_payorlink_member(conn, card_no) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "members/remove/attempt?card_no=#{card_no}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            decoded["message"]
            _ ->
             {:error_connecting}
        end
      _ ->
        {:error_connecting}
    end
  end

  def insert_loa_acu(member) do
    loa =
      %Loa{}
      |> Loa.acu_changeset(member)
      |> Repo.insert!()

    member =
      member
      |> Map.put(:loa_id, loa.id)
    {:ok, loa}
  end

  #PEME
  def get_accountlink_member_evoucher(conn, evoucher_number, facility_code, coverage) do
     with {:ok, response} <- UtilityContext.connect_to_api_get(conn, "Maxicar", "member/#{evoucher_number}/get_member_peme_by_evoucher/#{facility_code}") do
        case response.body do
          "Internal server error" ->
            {:internal}
          "Page not found" ->
            {:internal}
          _ ->
            accountlink_evoucher_return(conn, response.body, facility_code, coverage, evoucher_number)
        end
    else
      {:error_connecting_api} ->
        {:error}
      {:unable_to_login} ->
        {:unable_to_login}
      {:payor_does_not_exists} ->
        {:payor_does_not_exists}
    end
  end

  defp accountlink_evoucher_return(conn, response_body, facility_code, coverage, evoucher_number) do
    decoded = Poison.decode!(response_body)
    if not is_nil(decoded["error"]["message"]) do
      {:invalid, decoded["error"]["message"]}
    else
      payor = PayorContext.get_payor_by_code("Maxicar")
      member_params = %{
        first_name: decoded["first_name"],
        middle_name: decoded["middle_name"],
        last_name: decoded["last_name"],
        birth_date: decoded["birthdate"],
        gender: decoded["gender"],
        extension: decoded["suffix"],
        payorlink_member_id: decoded["id"],
        payor_id: payor.id,
        evoucher_number: "PEME-#{evoucher_number}",
        civil_status: decoded["civil_status"],
        male?: decoded["male"],
        female?: decoded["female"],
        age_from: decoded["age_from"],
        age_to: decoded["age_to"],
        status: "Active",
        email_address: decoded["email"],
        mobile: decoded["mobile"],
        type: decoded["type"],
        account_code: decoded["account_code"],
        account_name: decoded["account_name"],
        effective_date: decoded["effectivity_date"],
        expiry_date: decoded["expiry_date"],
        card_number: decoded["card_no"]
      }

      with nil <- get_member_by_payorlink_member_id(decoded["id"]) do
        payor = PayorContext.get_payor_by_code("Maxicar")

        params = %{
          "member_first_name" => decoded["first_name"],
          "member_middle_name" => decoded["middle_name"],
          "member_last_name" => decoded["last_name"],
          "member_suffix" => decoded["suffix"],
          "member_birth_date" => decoded["birthdate"],
          "member_age" => get_age(Ecto.Date.cast!(decoded["birthdate"])),
          "member_card_no" => decoded["card_no"],
          "payorlink_member_id" => decoded["id"],
          "member_evoucher_number" => "#{evoucher_number}",
          "member_evoucher_qr_code" => "",
          "member_male?" => decoded["male"],
          "member_female?" => decoded["female"],
          "member_status" => "Active",
          "member_email" => decoded["email"],
          "member_mobile" => decoded["mobile"],
          "member_type" => decoded["type"],
          "member_account_code" => decoded["account_code"],
          "member_account_name" => decoded["account_name"],
          "member_gender" => decoded["gender"],
          "coverage" => "PEME",
          "created_by_id" => conn.assigns.current_user.id,
          "updated_by_id" => conn.assigns.current_user.id,
          "payor_id" => payor.id
        }
        loa = insert_peme_loa(params)

        {:ok, loa}
      else
        {:invalid, message} ->
          {:invalid, message}
        loa = %Loa{} ->
          {:ok, loa}
        _ ->
          {:invalid, "Internal Server Error"}
      end
    end
  end

  defp get_age(date) do
    year_of_date = to_string(date)
    year_today =  Date.utc
    year_today = to_string(year_today)
    datediff1 = Timex.parse!(year_of_date, "%Y-%m-%d", :strftime)
    datediff2 = Timex.parse!(year_today, "%Y-%m-%d", :strftime)
    diff_in_years = Timex.diff(datediff2, datediff1, :years)
    diff_in_years
  end

  def get_member_by_card(member_card_no) do
    Loa
    |> where([c], c.member_card_no == ^member_card_no)
    |> Repo.one()
  end

  def update_loa_batch_no(loa, batch_no) do
    Repo.update(
      Changeset.change loa,
      payorlinkone_batch_no: batch_no
    )
  end

  def get_loa_by_payor(struct, payor) do
    from l in struct,
      join: p in Payor,
      on: l.payor_id == p.id,
      where: fragment("coalesce(?,?) ilike ?", p.name, "", ^("%#{payor}%"))
  end

  def update_acu_loa_status(loa_ids) do
    Loa
    |> where([l], l.payorlink_authorization_id in ^loa_ids)
    |> Repo.update_all(set: [status: "Stale"])
  end

  def insert_government_id(params) do
    %File{}
    |> File.changeset_loa(params)
    |> Repo.insert()
  end

  def update_government_id(file, params) do
    file
    |> File.changeset_file(params)
    |> Repo.update()
  end

  def get_valid_loas(card_no) do
    Loa
    |> where([l], l.member_card_no == ^card_no)
    |> where([l], l.status == "Approved" or l.status == "Availed")
    |> Repo.all()
  end

  def delete_local_img(file_name, extension) do
    PP.delete_local_img(file_name, extension)
  end

  def convert_base64_to_file(params) do
    if params["capture"] ==  "yes" do
      PP.convert_base64_img(params)
    else
      {:ok, %{"photo" => params["gov_photo"]}}
    end
  end

  def convert_base64_to_file2(params) do
    PP.convert_base64_img2(params)
  end

  def update_acu_schedule_status(acu_schedule_ids) do
    AcuSchedule
    |> where([as], as.payorlink_acu_schedule_id in ^acu_schedule_ids)
    |> Repo.update_all(set: [status: "Stale"])
  end

  def update_all_loa_to_availed(loa_ids) do
    {:ok, admission_datetime} = Ecto.DateTime.cast(DateTime.utc_now())
    Loa
    |> where([l], l.id in ^loa_ids)
    |> Repo.update_all(set: [otp: "true", status: "Availed", admission_date: admission_datetime])
  end

  def update_all_loa_to_forfeited(loa_ids) do
    Loa
    |> where([l], l.id in ^loa_ids)
    |> Repo.update_all(set: [status: "Forfeited"])
  end

  def delete_loa_package_not_selected(params) do
    LoaProcedure
    |> where([lp], lp.package_id != ^params["selected_package"] and lp.loa_id == ^params["loa_id"])
    |> Repo.delete_all()

    LoaPackage
    |> where([lp], lp.id != ^params["selected_package"] and lp.loa_id == ^params["loa_id"])
    |> Repo.delete_all()
  end

  def insert_facial_image(params) do
    %File{}
    |> File.changeset_loa(params)
    |> Repo.insert()
  end

  def update_facial_image(loa, params) do
    loa
    |> Loa.changeset_facial_image(params)
    |> Repo.update()
  end
end
