## do not use member schema
defmodule Data.Contexts.MemberContext do
 @moduledoc """
  """
  import Ecto.{
    Query,
    Changeset
  }
  alias Data.Schemas. {
    Payor,
    Card,
    Member,
    Loa,
    MemberPayor,
    AcuScheduleMember,
    File,
    AcuSchedule

  }
  alias Data.Contexts. {
    MemberContext,
    UtilityContext,
    PayorContext,
    LoaContext
  }
  alias Data.Repo
  alias Ecto.Changeset
  alias Ecto.Date
  alias Timex.Duration

  def get_all_member do
    Member
    |> Repo.all
    |> Repo.preload([:card])
  end

  def get_member(id) do
    Member
    |> Repo.get(id)
    |> Repo.preload([
      :payor,
      :loa,
      card: [[
        loa: from(
          l in Loa,
          where: l.status == "Approved",
          order_by: [desc: l.inserted_at],
          preload: :provider
        )
      ]]
    ])
  end

  def get_acu_member(id) do
    Member
    |> Repo.get(id)
    |> Repo.preload([
      :payor,
      [card: [loa: [:loa_packages, :loa_procedures, :loa_diagnosis]]]
      ])
  end

  def get_card(id) do
    Card
    |> Repo.get(id)
    |> Repo.preload([:member, :loa])
  end

  def get_card_by_number(number) do
    Card
    |> Repo.get_by(number: number)
    |> Repo.preload([
      :member,
      [[loa: from(
        l in Loa,
        where: l.status == "Approved",
        order_by: [desc: l.inserted_at],
        preload: :provider
      )]]
    ])
  end

  def get_card_by_member_id(member_id) do
    query =
      from c in Card,
      where: c.member_id == ^member_id

    query
    |> Repo.one()
    |> Repo.preload([
      loa: from(
        l in Loa,
        where: l.status == "approved",
        order_by: [desc: l.inserted_at],
        preload: :provider
      )
    ])
  end

  def get_all_card_by_member_id(member_id) do
    query =
      from c in Card,
      where: c.member_id == ^member_id

    query
    |> Repo.all()
    |> Repo.preload([
      loa: from(
        l in Loa,
        where: l.status == "approved",
        order_by: [desc: l.inserted_at],
        preload: :provider
      )
    ])
  end

#   def get_card_by_number_and_cvv(number, cvv) do
#     Card
#     |> Repo.get_by(number: number, cvv: cvv)
#     |> Repo.preload([
#       :member,
#       [[loa: from(
#         l in Loa,
#         where: l.status == "approved",
#         order_by: [desc: l.inserted_at],
#         preload: :provider
#       )]]
#     ])
#   end

  # def validate_number(conn, number, bdate, current_provider, coverage) do
  #   with {:valid} <- check_empty_number(number),
  #        {:valid} <- check_number_length(number),
  #        {:ok, card, member} <- get_payorlink_member_card(conn, number),
  #        # {:valid_cvv} <- payorlink_api_validate_cvv(number, cvv),
  #        {:card_no_bdate_matched} <- validate_card_no_bdate(number, bdate),
  #        {:eligible} <- payorlink_loa_validate(conn, card, current_provider, coverage),
  #        {:valid} <- validate_attempt_expiry(member)
  #   do
  #     {:ok, card, member}
  #   else
  #     {:invalid, message} ->
  #       {:invalid, message}
  #     {:empty_number} ->
  #       {:empty_number}

  #     {:invalid_number_length} ->
  #       {:invalid_number_length}

  #     ### for get_payorlink_member_card return
  #     {:internal} ->
  #       {:internal}

  #     {:member_not_active} ->
  #       {:member_not_active}

  #     ### for payorlink_loa_validate return
  #     {:unable_to_login} ->
  #       {:unable_to_login}

  #     {:payor_does_not_exists} ->
  #       {:payor_does_not_exists}

  #     {:internal_get_error} ->
  #       {:internal_get_error}

  #     {:error_message, message} ->
  #       {:error_message, message}

  #     ### for validate_card_no_bdate return
  #     {:card_no_bdate_not_matched, message} ->
  #       {:card_no_bdate_not_matched, message}

  #     ##########################################

  #     _ ->
  #       {:error}
  #   end
  # end

  defp check_empty_number(number) do
    if is_nil(number) or number == "" do
      {:empty_number}
    else
      {:valid}
    end
  end

  defp check_number_length(number) do
    if String.length(number) != 16 do
      {:invalid_number_length}
    else
      {:valid}
    end
  end

  def card_changeset(%Card{} = card) do
    Card.changeset(card, %{})
  end

  def changeset_mobile(%Member{} = member) do
    Member.changeset_mobile(member, %{})
  end

  # defp validate_card_no_bdate(number, bdate) do
  #   with %Card{} = card <- get_card_no_bdate(number, bdate)
  #   do
  #     {:card_no_bdate_matched}
  #   else
  #     nil ->
  #       {:card_no_bdate_not_matched, "The Card number or birth date you have entered is invalid."}
  #   end
  # end

  defp get_card_no_bdate(number, bdate) do
    Card
    |> join(:inner, [c], m in Member, m.id == c.member_id)
    |> where([c, m], c.number == ^number and m.birth_date == ^bdate)
    |> Repo.one()
  end

#   def validate_cvv(number, cvv) do
#     with {:valid} <- check_empty_cvv(cvv),
#          {:valid} <- check_cvv_length(cvv),
#          card = %Card{} <- get_card_by_number_and_cvv(number, cvv)
#     do
#       {:ok, card}
#     else
#       {:empty_cvv} ->
#         {:empty_cvv}
#       {:invalid_cvv_length} ->
#         {:invalid_cvv_length}
#       _ ->
#         {:error}
#     end
#   end

  defp check_empty_cvv(cvv) do
    if is_nil(cvv) or cvv == "" do
      {:empty_cvv}
    else
      {:valid}
    end
  end

  defp check_cvv_length(cvv) do
    if String.length(cvv) != 3 do
      {:invalid_cvv_length}
    else
      {:valid}
    end
  end

  def insert_pin(member) do
    pin = "#{Enum.random(1000..9999)}"
    utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds
    pin_expiry = (utc + 5 * 60)
    pin_expiry =
      pin_expiry
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!
    Repo.update(Changeset.change member,
                pin: pin,
                pin_expires_at: pin_expiry)
  end

 def validate_details(conn, facility_code, full_name, birth_date, coverage) do
    with {:ok, member} <- get_payorlink_member_details(conn, facility_code, full_name, birth_date, coverage)
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

  def get_payorlink_member_details(conn, facility_code, full_name, birth_date, coverage) do
    # {:member_not_found} <- MemberContext.get_member_by_details(full_name, birth_date),
    with {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
         {:ok, response} <- get_member_in_payorlink(token, full_name, birth_date)
    do
      decoded = Poison.decode!(response.body)
      valid_response = validate_response(decoded)

      cond do
        valid_response == {:invalid_response} ->
        {:invalid, decoded["error"]["message"]}
        Enum.count(decoded) == 1 ->
          single_member(decoded, token, coverage, facility_code)
        true ->
          multiple_member(decoded, token, coverage, facility_code)
      end
    else
      # {:ok, member} ->
        # existing_member(conn, member, coverage, facility_code)
      {:invalid, message} ->
        {:invalid, message}
      {:unable_to_login} ->
        {:unable_to_login}
    end
  end

  defp single_member(decoded, token, coverage, facility_code) do
    decoded = Enum.at(decoded, 0)
    if String.downcase(decoded["status"]) != "active" do
      {:invalid, "Member not eligible"}
      else
        principal =
          if not is_nil(decoded["principal_id"]) do
            decoded["first_name_principal"]
          else
            nil
          end

      payor = PayorContext.get_payor_by_code("Maxicar")
      member = %{
        first_name: decoded["first_name"],
        middle_name: decoded["middle_name"],
        last_name: decoded["last_name"],
        birth_date: decoded["birthdate"],
        gender: decoded["gender"],
        extension: decoded["suffix"],
        number_of_dependents: "#{Enum.count(decoded["dependents"])}",
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
        effective_date: UtilityContext.transform_date(decoded["effectivity_date"]),
        expiry_date: UtilityContext.transform_date(decoded["expiry_date"]),
        relationship: decoded["relationship"],
        last_facility: decoded["latest_facility"],
        status: decoded["status"],
        latest_consult: decoded["latest_consult"]
      }
      # member = insert_member!(member_params)
      #   card_params = %{
      #     payorlink_member_id: decoded["id"],
      #     number: decoded["card_no"],
      #     cvv: "123", #payorlink card cvv does not exist
      #     member_id: member.id
      #   }
      # insert_card(card_params)
      # member = member |> Repo.preload([card: :loa])
      with {:valid} <- validate_loa_coverage(token, decoded["card_no"], facility_code, coverage) do
        {:ok, [member]}
      else
        {:invalid, message} ->
          {:invalid, message}
      end
    end
  end

  defp validate_loa_coverage(token, card_no, facility_code, coverage) do
    loa = URI.encode("loa/validate/coverage?card_no=#{card_no}&facility_code=#{facility_code}&coverage_name=#{coverage}")
    case UtilityContext.connect_to_api_get_with_token(token, loa, "Maxicar") do
      {:ok, response} ->
        decoded = Poison.decode!(response.body)
        # valid_response = validate_response(decoded)

        cond do
          not is_nil(decoded["error"]["message"]) ->
            {:invalid, decoded["error"]["message"]}
          not is_nil(["message"]) ->
              {:valid}
          true ->
            {:invalid, "PayorLink Internal Server Error"}
        end
      _ ->
       raise 123
    end
  end

  defp multiple_member(decoded, token, coverage, facility_code) do
    members = for decoded <- decoded do
      principal =
        if not is_nil(decoded["principal_id"]) do
          decoded["first_name_principal"]
        else
          nil
        end

      payor = PayorContext.get_payor_by_code("Maxicar")
      member_params = %{
        first_name: decoded["first_name"],
        middle_name: decoded["middle_name"],
        last_name: decoded["last_name"],
        birth_date: decoded["birthdate"],
        gender: decoded["gender"],
        extension: decoded["suffix"],
        number_of_dependents: "#{Enum.count(decoded["dependents"])}",
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
        effective_date: UtilityContext.transform_date(decoded["effectivity_date"]),
        expiry_date: UtilityContext.transform_date(decoded["expiry_date"]),
        status: decoded["status"],
        relationship: decoded["relationship"],
        last_facility: decoded["latest_facility"]
      }
      member = insert_member!(member_params)
        card_params = %{
          payorlink_member_id: decoded["id"],
          number: decoded["card_no"],
          cvv: "123", #payorlink card cvv does not exist
          member_id: member.id
        }
      insert_card(card_params)
      member = member |> Repo.preload([card: :loa])
      with true <- not is_nil(decoded["status"]),
           true <- String.downcase(decoded["status"]) == "active",
          {:valid} <- validate_loa_coverage(token, decoded["card_no"], facility_code, coverage) do
            member
            |> Member.changeset_remarks(%{remarks: "valid"})
            |> Repo.update!()
      else
        {:invalid, message} ->
          if message == "No package facility rate setup." do
           member
            |> Member.changeset_remarks(%{remarks: "Cannot avail ACU. Reason: Facility has no package facility rate setup."})
            |> Repo.update!()
          else
            member
            |> Member.changeset_remarks(%{remarks: message})
            |> Repo.update!()
          end
        false ->
            member
            |> Member.changeset_remarks(%{remarks: "Member is not active"})
            |> Repo.update!()
      end
    end
    {:multiple, members}
  end

  # defp existing_member(conn, member, coverage, facility_code) do
  #   if Enum.count(member) == 1 do
  #     member = Enum.at(member, 0)
  #     validate_existing_single_member(conn, member, coverage, facility_code)
  #   else
  #     members = validate_existing_multiple_member(conn, member, coverage, facility_code)
  #     {:multiple, members}
  #   end
  # end

  # defp validate_existing_single_member(conn, member, coverage, facility_code) do
  #  with {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
  #        {:valid} <- validate_loa_coverage(token, member.card.number, facility_code, coverage),
  #        {:valid} <- validate_attempt_expiry(member)
  #   do
  #     {:ok, member}
  #   else
  #     {:invalid, message} ->
  #       {:invalid, message}
  #     {:unable_to_login} ->
  #       {:invalid, "Unable to login in PayorLink API"}
  #   end
  # end

  defp validate_attempt_expiry(member) do
    if is_nil(member.attempt_expiry) do
      {:valid}
    else
      {:invalid, "The member is blocked for 1 day"}
    end
  end

  # defp validate_existing_multiple_member(conn, member, coverage, facility_code) do
  #   for member <- member do
  #     if member.remarks == "Member is not active" do
  #       member
  #     else
  #       with {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
  #        false <- is_nil(member.card),
  #        {:valid} <- validate_loa_coverage(token, member.card.number, facility_code, coverage),
  #        {:valid} <- validate_attempt_expiry(member)
  #       do
  #         member
  #         |> Member.changeset_remarks(%{remarks: "valid"})
  #         |> Repo.update!()
  #       else
  #         {:invalid, message} ->
  #           if message == "No package facility rate setup." do
  #            member
  #             |> Member.changeset_remarks(%{remarks: "Cannot avail ACU. Reason: Facility has no package facility rate setup."})
  #             |> Repo.update!()
  #           else
  #             member
  #             |> Member.changeset_remarks(%{remarks: message})
  #             |> Repo.update!()
  #           end
  #         {:unable_to_login} ->
  #           member
  #           |> Member.changeset_remarks(%{remarks: "Unable to login in PayorLink API"})
  #           |> Repo.update!()
  #         true ->
  #           member
  #           |> Member.changeset_remarks(%{remarks: "Member has invalid card number"})
  #           |> Repo.update!()
  #       end
  #     end
  #   end
  # end

  defp get_member_in_payorlink(token, full_name, birth_date) do
    payorlink_practitioner = "member/validate/details"
    body = %{"params": %{"full_name": full_name, "birth_date": birth_date}}

    UtilityContext.connect_to_api_post_with_token(token, payorlink_practitioner, body, "Maxicar")
  end

  def get_member_by_details(full_name, birth_date) do
    full_name = String.downcase(full_name)
    birth_date =
      birth_date
      |> Ecto.Date.cast!()

    query =
      from m in Member,
      where: fragment("to_tsvector(concat(?, ' ', ?, ' ', ?)) @@ plainto_tsquery(?)", m.first_name, m.middle_name, m.last_name, ^"#{full_name}")
               and fragment("? = coalesce(?, ?)", m.birth_date, ^birth_date, m.birth_date)

    member =
      query
      |> Repo.all()
      |> Repo.preload([card: [:member, [loa: :provider]]])

    if Enum.empty?(member) do
      {:member_not_found}
    else
      {:ok, member}
    end
  end

  def get_all_member_by_details(full_name, birth_date) do
    full_name = String.downcase(full_name)
    birth_date =
      birth_date
      |> Ecto.Date.cast!()

    query =
      from m in Member,
      where: fragment("to_tsvector(concat(?, ' ', ?, ' ', ?)) @@ plainto_tsquery(?)", m.first_name, m.middle_name, m.last_name, ^"#{full_name}")
               and fragment("? = coalesce(?, ?)", m.birth_date, ^birth_date, m.birth_date)

    member =
      query
      |> Repo.all()
      |> Repo.preload([card: [:member, [loa: :provider]]])

    if Enum.empty?(member) do
      {:member_not_found}
    else
      {:ok, member}
    end
  end

  def get_all_member_accounts_by_details(full_name, birth_date) do
    full_name = String.downcase(full_name)

    query =
      from m in Member,
      where: fragment("LOWER(?)", fragment("CONCAT(?,?,?)", m.first_name, " ",
        fragment("CASE WHEN ? IS NULL THEN ? ELSE ? END", m.middle_name,
                 m.last_name, fragment("CONCAT(?,?,?)", m.middle_name, " ",
          m.last_name)))) == ^full_name and m.birth_date == ^birth_date,
      select: m.first_name

    member =
      query
      |> Repo.all()
      |> Repo.preload([card: :loa])

    if Enum.empty?(member) do
      {:member_not_found}
    else
      {:ok, member}
    end
  end

  def validate_pin(member_id, pin) do
    # for refactoring
    member = get_member(member_id)
    if is_nil(member) do
      {:member_not_found}
    else
      if String.length(pin) != 4 do
        {:invalid_pin_length}
      else
        validate_pin_expires(member, pin)
      end
    end
  end

  defp validate_pin_expires(member, pin) do
    if is_nil(member.pin_expires_at) or member.pin_expires_at == "" do
      {:pin_not_requested}
    else
      pin_expiry =
        member.pin_expires_at
        |> Ecto.DateTime.cast!()
        |> Ecto.DateTime.compare(Ecto.DateTime.utc)

      cond do
        pin_expiry == :gt ->
          member = Member
                   |> where([m], m.pin == ^pin and m.id == ^member.id)
                   |> Repo.all()
          if member == [] do
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

  def get_member_by_payorlink_member_id(payorlink_member_id) do
    Member
    |> Repo.get_by(payorlink_member_id: payorlink_member_id)
    |> Repo.preload([
      :acu_schedule_members,
      :loa,
      card: [[
        loa: from(
          l in Loa,
          where: l.status == "Approved",
          order_by: [desc: l.inserted_at],
          preload: :provider
        )
      ]]
    ])
  end

  def insert_member(params) do
    %Member{}
    |> Member.changeset(params)
    |> Repo.insert()
  end

  def insert_member!(params) do
    %Member{}
    |> Member.changeset(params)
    |> Repo.insert!()
  end

  def update_member(%Member{} = member, params) do
    member
    |> Member.changeset(params)
    |> Repo.update()
  end

  def update_member_attempt(%Member{} = member) do
    params = %{
      attempt_expiry: Ecto.DateTime.from_erl(:erlang.localtime)
    }

    member
    |> Member.changeset_attempt_expiry(params)
    |> Repo.update()
  end

  def insert_card!(params) do
    %Card{}
    |> Card.changeset(params)
    |> Repo.insert!()
  end

  def insert_card(params) do
    %Card{}
    |> Card.changeset(params)
    |> Repo.insert()
  end

  def get_payorlink_member_card(conn, number) do
    card =  MemberContext.get_card_by_number(number)

    if not is_nil(card) do
      member =
        get_member_by_payorlink_member_id(card.payorlink_member_id)
        {:ok, card, member}
    else
      case UtilityContext.connect_to_api_post(conn, "Maxicar", "member/validate/card", %{"card_number": number}) do
        {:ok, response} ->
          case response.body do
            "\"Internal server error\"" ->
              {:internal}
            _ ->
              payorlink_member_card_return(response.body)
          end
        {:error_connecting_api} ->
          {:error}
        {:unable_to_login} ->
          {:unable_to_login}
        {:payor_does_not_exists} ->
          {:payor_does_not_exists}
      end
    end
  end

  defp payorlink_member_card_return(response_body) do
    decoded = Poison.decode!(response_body)

    if decoded["error"]["message"] == "Member not found!" do
      {:invalid}
    else
      if decoded["status"] != "Active" or is_nil(decoded["status"]) do
        {:member_not_active}
      else
       if not is_nil(decoded["principal_id"]) do
          principal = decoded["first_name_principal"]
        else
          principal = nil
        end

        payor = PayorContext.get_payor_by_code("Maxicar")
        member_params = %{
          first_name: decoded["first_name"],
          middle_name: decoded["middle_name"],
          last_name: decoded["last_name"],
          birth_date: decoded["birthdate"],
          gender: decoded["gender"],
          extension: decoded["suffix"],
          number_of_dependents: "#{Enum.count(decoded["dependents"])}",
          email_address: decoded["email"],
          email_address2: decoded["email2"],
          mobile: decoded["mobile"],
          mobile2: decoded["mobile2"],
          principal: principal,
          type: String.downcase(decoded["type"]),
          payorlink_member_id: decoded["id"],
          payor_id: payor.id,
          evoucher_number: decoded["evoucher_number"],
          effective_date: UtilityContext.transform_date(decoded["effectivity_date"]),
          expiry_date: UtilityContext.transform_date(decoded["expiry_date"]),
          status: decoded["status"],
          relationship: decoded["relationship"],
          last_facility: decoded["latest_facility"]
        }
        member = insert_member!(member_params)
        card_params = %{
          payorlink_member_id: decoded["id"],
          number: decoded["card_no"],
          # cvv: "123", #payorlink card cvv does not exist
          member_id: member.id
        }

        card = insert_card!(card_params)

        member =
          member
          |> Repo.preload([:card, :loa])

        {:ok, card, member}
      end
    end
  end

defp payorlink_member_card_return_evoucher(conn, response_body, facility_code, coverage) do
    decoded = Poison.decode!(response_body)
    if decoded["error"]["message"] == "eVoucher Number not found!" do
      {:evoucher_not_found}
    else
      if decoded["error"]["message"] == "Member not found!" do
        {:invalid}
      else
        if decoded["status"] != "Active" or is_nil(decoded["status"]) do
          {:invalid_member}
        else
         if not is_nil(decoded["principal_id"]) do
            principal = decoded["first_name_principal"]
          else
            principal = nil
          end

          payor = PayorContext.get_payor_by_code("Maxicar")
          member_params = %{
            first_name: decoded["first_name"],
            middle_name: decoded["middle_name"],
            last_name: decoded["last_name"],
            birth_date: decoded["birthdate"],
            gender: decoded["gender"],
            extension: decoded["suffix"],
            number_of_dependents: "#{Enum.count(decoded["dependents"])}",
            email_address: decoded["email"],
            email_address2: decoded["email2"],
            mobile: decoded["mobile"],
            mobile2: decoded["mobile2"],
            principal: principal,
            type: String.downcase(decoded["type"]),
            payorlink_member_id: decoded["id"],
            payor_id: payor.id,
            evoucher_number: decoded["evoucher_number"],
            effective_date: UtilityContext.transform_date(decoded["effectivity_date"]),
            expiry_date: UtilityContext.transform_date(decoded["expiry_date"]),
            status: decoded["status"],
            relationship: decoded["relationship"],
            last_facility: decoded["latest_facility"]
          }

          with nil <- get_member_by_payorlink_member_id(decoded["id"]),
               {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
               {:eligible} <- payorlink_loa_validate_evoucher(conn, decoded["card_no"], facility_code, coverage) do

               member = insert_member!(member_params)
               card_params = %{
                 payorlink_member_id: decoded["id"],
                 number: decoded["card_no"],
                 # cvv: "123", #payorlink card cvv does not exist
                 member_id: member.id
               }

               card = insert_card!(card_params)

               {:ok, member}
          else
            {:invalid, message} ->
              {:invalid, message}
            {:error_message, message} ->
              {:error_message, message}
            member = %Member{} ->
              {:ok, member}
               end
        end
      end
    end
  end

  defp validate_response(response) do
    List.first(response)
    rescue
      _ ->
        {:invalid_response}
  end

  defp get_mdy(datetime) do
    {day, month, year} =
      datetime
      |> String.slice(0..9)
      |> String.split("/")
      |> List.to_tuple()
    {:ok, {year, month, day}}
  end

  def get_member_by_account_code(code) do
    Member
    |> Repo.get_by(account_code: code)
    |> Repo.preload([
      card: [[
        loa: from(
          l in Loa,
          where: l.status == "approved",
          order_by: [desc: l.inserted_at],
          preload: :provider
        )
      ]]
    ])
  end

  def add_attempt_expiry(member) do
    utc = :erlang.universaltime |> :calendar.datetime_to_gregorian_seconds
    attempt_expiry = (utc + 5 * 60)
    attempt_expiry =
      attempt_expiry
      |> :calendar.gregorian_seconds_to_datetime
      |> Ecto.DateTime.cast!

    member
    |> Member.changeset(%{attempt_expiry: attempt_expiry})
    |> Repo.update!()
  end

  def add_attempt(member) do
    attempts =
      cond do
        is_nil(member.attempts) ->
          1
        member.attempts == 3 ->
          3
        true ->
          member.attempts + 1
      end

    member
    |> Member.changeset(%{attempts: attempts})
    |> Repo.update!()
  end

  def insert_member_not_exist(params) do
    payor =
      "Maxicar"
      |> PayorContext.get_payor_by_code()

    params =
      params
      |> Map.put(:payor_id, payor.id)

    if params |> Map.has_key?(:payorlink_member_id) do

      with nil <- params.payorlink_member_id |> get_member_by_payorlink_member_id,
           {:ok, inserted_member = %Member{}} <- params |> insert_member,
           {:ok, card = %Card{}} <- %{
             number: params.card_number,
             payorlink_member_id: params.payorlink_member_id,
             member_id: inserted_member.id
           }
           |> insert_card()
      do
        {:ok, inserted_member
        |> Repo.preload(:card)}
      else
        member = %Member{} ->
          {:ok, member
          |> Repo.preload(:card)}
        {:error, changeset = %Ecto.Changeset{}} ->
          {:error, changeset}
      end

    else
      {:error, "Payorlink member id not exist"}
    end
  end

  defp payorlink_api_validate_cvv(conn, number, cvv) do
    with {:ok, response} <- UtilityContext.connect_to_api_post(conn, "Maxicar",
   "member/validate/cvv", %{"card_number": number, cvv_number: cvv}),
         {:ok, response} <- internal_error?(response),
         {:valid_cvv} <- payorlink_api_validate_cvv_return(response.body)

    do
      {:valid_cvv}
    else
        ### for connect_to_api_get_return
      nil ->
        {:payor_does_not_exists}

        ### for internal_error?
      {:internal} ->
        {:internal_post_error}

        ### for payorlink_api_validate_cvv_return
      {:error_message, message} ->
        {:error_message, message}

      {:error_connecting_api} ->
        {:error_connecting_api}
    end
  end

  defp payorlink_api_validate_cvv_return(response_body) do
    decoded = Poison.decode!(response_body)
    case decoded["status"] do
      "Active" ->
        {:valid_cvv}

      _ ->
        if Map.has_key?(decoded["errors"], "card_number") do
          {:error_message, List.first(decoded["errors"]["card_number"])}
        else
          {:error_message, List.first(decoded["errors"]["cvv_number"])}
        end
    end
  end

  defp payorlink_loa_validate(conn, card, current_provider, coverage) do
    with {:ok, response} <- UtilityContext.connect_to_api_get(conn, "Maxicar", URI.encode("loa/validate/coverage?card_no=#{card.number}&facility_code=#{current_provider}&coverage_name=#{coverage}")),
         {:ok, response} <- internal_error?(response),
         {:eligible} <- payorlink_loa_validate_return(response.body)

    do
      {:eligible}
    else
        ### for connect_to_api_get_return
      nil ->
        {:payor_does_not_exists}

        ### for internal_error?
      {:internal} ->
        {:internal_get_error}

        ### for payorlink_loa_validate_return
      {:error_message, message} ->
        {:error_message, message}

    end

  end

  defp payorlink_loa_validate_evoucher(conn, card_number, current_provider, coverage) do
    with {:ok, response} <- UtilityContext.connect_to_api_get(conn, "Maxicar", URI.encode("loa/validate/coverage?card_no=#{card_number}&facility_code=#{current_provider}&coverage_name=#{coverage}")),
         {:ok, response} <- internal_error?(response),
         {:eligible} <- payorlink_loa_validate_return(response.body)
    do
      {:eligible}
    else
        ### for connect_to_api_get_return
      nil ->
        {:payor_does_not_exists}

        ### for internal_error?
      {:internal} ->
        {:internal_get_error}

        ### for payorlink_loa_validate_return
      {:error_message, message} ->
        {:error_message, message}

    end

  end

  defp internal_error?(response) do
    case response.body do
      "Internal server error" ->
        {:internal}
      _ ->
        {:ok, response}
    end
  end

  defp payorlink_loa_validate_return(response_body) do
    decoded = Poison.decode!(response_body)
    case decoded["message"] do
      "Eligible" ->
        {:eligible}

      _ ->
        {:error_message, decoded["error"]["message"]}
    end
  end

  # def update_mobile_no(member_id, ""), do: {:error, nil}
  # def update_mobile_no(member_id, mobile) do
  #   member = Repo.get(Member, member_id)
  #   mobile = String.replace(mobile, "-", "")
  #   with {:ok, response} <- update_mobile_no_payorlink(member.payorlink_member_id, mobile) do
  #     Repo.update(Changeset.change member, mobile: mobile)
  #   else
  #     {:error, message} ->
  #       {:error, message}
  #   end
  # end

  # def update_mobile_no_payorlink(member_id, mobile) do
  #   case UtilityContext.payor_link_sign_in("Maxicar") do
  #     {:ok, token} ->
  #       url = "https://payorlink-ip-staging.medilink.com.ph/api/v1/member/#{member_id}/update_mobile_no"
  #       headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
  #       body = Poison.encode!(%{"mobile_no": mobile})

  #       case HTTPoison.put(url, body, headers, []) do
  #         {:ok, response} ->
  #           return(response)
  #           _ ->
  #             raise "error"
  #       end
  #     _ ->
  #       raise "error"
  #   end
  # end

  def return(response) do
    response = Poison.decode! response.body
    if Enum.count(Map.keys(response)) > 2 do
      {:ok, response}
    else
      {:error, response["error"]["message"]}
    end
  end

  # def get_all_mobile_no do
  #   url = "https://payorlink-ip-staging.medilink.com.ph/api/v1/member/principal/get_all_mobile_no"
  #   get_all_mobile_no_payorlink(url)
  # end

  # def get_all_mobile_no(member_id) do
  #   url = "https://payorlink-ip-staging.medilink.com.ph/api/v1/member/#{member_id}/get_all_mobile_no"
  #   get_all_mobile_no_payorlink(url)
  # end

  # def get_all_mobile_no_payorlink(url) do
  #   case UtilityContext.payor_link_sign_in("Maxicar") do
  #     {:ok, token} ->
  #       headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]

  #       case HTTPoison.get(url, headers, []) do
  #         {:ok, response} ->
  #           decoded = Poison.decode!(response.body)
  #           _ ->
  #             raise "error"
  #       end
  #     _ ->
  #       raise "error"
  #   end
  # end

  #EVOUCHER

  def validate_evoucher(conn, number, facility_code, coverage) do
    with {:valid} <- check_empty_number(number),
         {:valid} <- check_evoucher_length(number),
         {:ok, member} <- get_payorlink_member_evoucher(conn, number, facility_code, coverage)
    do
      {:ok, member}
    else
      {:empty_number} ->
        {:empty_number}

      {:invalid_number_length} ->
        {:invalid_number_length}

      {:internal} ->
        {:internal}

      {:invalid_member} ->
        {:invalid_member}

      {:evoucher_not_found} ->
        {:evoucher_not_found}

      {:payor_does_not_exists} ->
        {:payor_does_not_exists}

      {:internal_get_error} ->
        {:internal_get_error}

      {:error_message, message} ->
        {:error_message, message}

      {:invalid, message} ->
        {:invalid, message}

      {:unable_to_login} ->
        {:unable_to_login}

      _ ->
        {:error}
    end
  end

  defp check_evoucher_length(number) do
    if String.length(number) != 10 do
      {:invalid_number_length}
    else
      {:valid}
    end
  end

  def get_payorlink_member_evoucher(conn, evoucher_number, facility_code, coverage) do
    payor_member =  MemberContext.get_member_by_evoucher(evoucher_number)
    if not is_nil(payor_member) do
       member = get_member_by_payorlink_member_id(payor_member.payorlink_member_id)
       with {:ok, token} <- UtilityContext.payor_link_sign_in(conn, "Maxicar"),
            {:eligible} <- payorlink_loa_validate_evoucher(conn, member.card.number, facility_code, coverage) do
         {:ok, member}
       else
         {:error_message, message} ->
            {:error_message, message}
         {:invalid, message} ->
           {:invalid, message}
       end
     else
      case UtilityContext.connect_to_api_post(conn, "Maxicar", "member/validate/evoucher",
        %{"evoucher_number": evoucher_number}) do
        {:ok, response} ->
          case response.body do
            "Internal server error" ->
              {:internal}
            _ ->
              payorlink_member_card_return_evoucher(conn, response.body, facility_code, coverage)
          end
        {:error_connecting_api} ->
          {:error}
        {:unable_to_login} ->
          {:unable_to_login}
        {:payor_does_not_exists} ->
          {:payor_does_not_exists}
      end
     end
  end

  def get_member_by_evoucher(evoucher_number) do
    Member
    |> Repo.get_by(evoucher_number: evoucher_number)
    |> Repo.preload([
      card: [[
        loa: from(
          l in Loa,
          where: l.status == "approved",
          order_by: [desc: l.inserted_at],
          preload: :provider
        )
      ]]
    ])
  end

  # def validate_number_cvv_loa(conn, number, cvv, loa_id, current_provider) do
  #   with {:valid} <- check_empty_number(number),
  #        {:valid} <- check_number_length(number),
  #        {:ok, card, member} <- get_payorlink_member_card(conn, number),
  #        {:valid_cvv} <- payorlink_api_validate_cvv(number, cvv),
  #        {:valid_otp} <- if_loa_matches_card(card, loa_id)
  #   do
  #     {:ok, card, member}
  #   else
  #     {:empty_number} ->
  #       {:empty_number}

  #     {:invalid_number_length} ->
  #       {:invalid_number_length}

  #     ### for get_payorlink_member_card return
  #     {:internal} ->
  #       {:internal}

  #     {:invalid_member} ->
  #       {:invalid_member}

  #     ### for payorlink_api_validate_cvv return

  #     {:unable_to_login} ->
  #       {:unable_to_login}

  #     {:payor_does_not_exists} ->
  #       {:payor_does_not_exists}

  #     {:internal_post_error} ->
  #       {:internal_post_error}

  #     {:error_message, message} ->
  #       {:error_message, message}

  #     ### for loa_otp_card_cvv_checker
  #     {:invalid_loa_otp, message} ->
  #       {:invalid_loa_otp, message}

  #     ##########################################

  #     _ ->
  #       {:error}
  #   end
  # end

  defp if_loa_matches_card(card, loa_id) do
    with %Loa{} = loa <- get_loa_by_id_card_id(card.id, loa_id)
    do
      {:valid_otp, loa}
    else
      nil ->
        {:invalid_loa_otp, "Card number does not match"}
    end
  end

  defp get_loa_by_id_card_id(card_id, loa_id) do
    Loa
    |> Repo.get_by(
      id: loa_id,
      card_id: card_id
    )
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

      with nil <- LoaContext.get_member_by_payorlink_member_id(decoded["id"]) do
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
        loa = LoaContext.insert_peme_loa(params)

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

  defp validate_card_number(conn, card_number) do
    with {:valid} <- check_empty_number(card_number),
         {:valid} <- check_number_length(card_number),
         {:ok, card, member} <- get_payorlink_member_card(conn, card_number)
    do
      {:ok, card, member}
    else
      {:empty_number} ->
        {:empty_number, "Card No is required."}

      {:invalid_number_length} ->
        {:invalid_number_length, "Card No should be 16-digits."}

      ### for get_payorlink_member_card return
      {:internal} ->
        {:internal, "Error encountered upon connecting to PayorLink API."}

      {:invalid} ->
        {:invalid, "The Card number you have entered is invalid."}

      {:member_not_active} ->
        {:member_not_active, "The Card number you have entered is invalid."}

      ##########################################
      _ ->
        {:error, "Error encountered upon authentication."}
    end
  end

  def verify_swipe_card(conn, card_number, loa_id) do
    with {:ok, card, member} <- validate_card_number(conn, card_number),
         {:valid_otp, %Loa{} = loa} <- if_loa_matches_card(card, loa_id)
    do
      tag_loa_as_verified(loa)
    else
      {error, message} ->
        {error, message}
    end
  end

  def tag_loa_as_verified(loa) do
    loa
    |> Loa.changeset_otp(%{otp: true})
    |> Repo.update()
  end

  def verify_cvv(conn, cvv, loa_id) do
    with %Loa{} = loa <- LoaContext.get_loa_by_id(loa_id),
         {:valid_cvv} <- payorlink_api_validate_cvv(conn, loa.card.number, cvv)
    do
      tag_loa_as_verified(loa)
    else
      nil ->
        # get_loa_by_id return
        {:loa_not_exists, "Invalid LOA ID."}

        # payorlink_api_validate_cvv return
      {:payor_does_not_exists} ->
        {:payor_does_not_exists, "Payor is not registered in the database."}
      {:internal_post_error} ->
        {:internal_post_error, "Internal server error encountered"}

      {:error_message, message} ->
        {:error_message, message}

      {:error_connecting_api} ->
        {:error_connecting_api, "Error Connecting to API"}
    end
  end

  def get_member_by_payorlink_id(payorlink_id) do
    Member
    |> Repo.get_by(payorlink_member_id: payorlink_id)
    |> Repo.preload([
      card: [[
        loa: from(
          l in Loa,
          where: l.status == "Approved",
          order_by: [desc: l.inserted_at],
          preload: :provider
        )
      ]]
    ])
  end

  def insert_accountlink_member!(params) do
    %Member{}
    |> Member.changeset_accountlink(params)
    |> Repo.insert!()
  end

  def insert_accountlink_card!(params) do
    %Card{}
    |> Card.changeset(params)
    |> Repo.insert!()
  end


  def update_accountlink_member(member, params) do
    member
    |> Member.changeset_accountlink(params)
    |> Repo.update!()
  end

  def get_loa_by_card(card_no) do
    Member
    |> join(:inner, [m], c in Card, m.id == c.member_id)
    |> where([m, c], c.number == ^card_no)
    |> Repo.one()
  end

  def get_acu_schedule_by_loa_id(loa_id, batch_no) do
    batch_no = String.to_integer(batch_no)
    AcuScheduleMember
    |> where([c], c.loa_id == ^loa_id)
    |> Repo.one()
  end

  def validate_number(conn, number, provider) do
    with {:valid} <- check_empty_number(number),
         {:valid} <- check_number_length(number),
         {:ok, card, member} <- get_payorlink_member_by_card_n_facility(conn, number, provider)
    do
      {:ok, card, member}
    else
      {:empty_number} ->
        {:empty_number}

      {:invalid_number_length} ->
        {:invalid_number_length}

      {:internal} ->
        {:internal}

      {:member_not_active} ->
        {:member_not_active}

      {:unable_to_login} ->
        {:unable_to_login}

      {:payor_does_not_exists} ->
        {:payor_does_not_exists}

      {:internal_get_error} ->
        {:internal_get_error}

      {:error_message, message} ->
        {:error_message, message}

      _ ->
        {:error}
    end
  end

  def get_payorlink_member_by_card_n_facility(conn, number, provider) do
    card =  MemberContext.get_card_by_number(number)

    if not is_nil(card) do
      member =
        get_member_by_payorlink_member_id(card.payorlink_member_id)
        {:ok, card, member}
    else
      case UtilityContext.connect_to_api_get(conn, "Maxicar", "members/replicate/member?card_number=#{number}&facility_code=#{provider.code}") do
        {:ok, response} ->
          case response.body do
            "Internal server error" ->
              {:internal}
            _ ->
               response(response.body)
          end
        {:error_connecting_api} ->
          {:error}
        {:unable_to_login} ->
          {:unable_to_login}
        {:payor_does_not_exists} ->
          {:payor_does_not_exists}
      end
    end
  end

  defp response(response_body) do
    decoded = Poison.decode!(response_body)
      if Enum.count(decoded) > 5 do
        if decoded["status"] != "Active" or is_nil(decoded["status"]) do
          {:member_not_active}
        else
          if not is_nil(decoded["principal_id"]) do
            principal = decoded["first_name_principal"]
          else
            principal = nil
          end

          payor = PayorContext.get_payor_by_code("Maxicar")
          member_params = %{
            first_name: decoded["first_name"],
            middle_name: decoded["middle_name"],
            last_name: decoded["last_name"],
            birth_date: decoded["birthdate"],
            gender: decoded["gender"],
            extension: decoded["suffix"],
            number_of_dependents: "#{Enum.count(decoded["dependents"])}",
            email_address: decoded["email"],
            email_address2: decoded["email2"],
            mobile: decoded["mobile"],
            mobile2: decoded["mobile2"],
            principal: principal,
            type: String.downcase(decoded["type"]),
            payorlink_member_id: decoded["id"],
            payor_id: payor.id,
            evoucher_number: decoded["evoucher_number"],
            effective_date: UtilityContext.transform_date(decoded["effectivity_date"]),
            expiry_date: UtilityContext.transform_date(decoded["expiry_date"]),
            status: decoded["status"],
            relationship: decoded["relationship"],
            last_facility: decoded["latest_facility"]
          }

          member = insert_member!(member_params)
          card_params = %{
            payorlink_member_id: decoded["id"],
            number: decoded["card_no"],
            # cvv: "123", #payorlink card cvv does not exist
            member_id: member.id
          }

          card = insert_card!(card_params)

          {:ok, card, member}
        end
      else
        {:invalid}
      end
    rescue
      _ ->
      {:invalid}
  end

  def insert_payorlink_security(conn, member) do
    with {:ok, response} <- UtilityContext.connect_to_api_get(conn, "Maxicar", URI.encode("member/security?card_no=#{member.card.number}")),
         {:ok, response} <- internal_error?(response),
         {:ok, member} <- insert_security(response.body, member)
    do
      member
    else
        ### for connect_to_api_get_return
      nil ->
        {:payor_does_not_exists}

        ### for internal_error?
      {:internal} ->
        {:internal_get_error}

        ### for payorlink_loa_validate_return
      {:error_message, message} ->
        {:error_message, message}

    end
  end

  defp insert_security(response_body, member) do
    decoded = Poison.decode!(response_body)
    params = %{
      type: decoded["type"],
      relationship: decoded["relationship"],
      principal: decoded["principal"],
      mobile: decoded["mobile"],
      last_facility: decoded["latest_facility"],
      latest_consult: decoded["latest_consult"],
      payorlink_member_id: decoded["id"],
      email_address: decoded["email"],
      number_of_dependents: "#{decoded["dependents"]}",
      account_code: decoded["account_code"],
      account_name: decoded["account_name"]
    }

    member
    |> Ecto.Changeset.change(params)
    |> Repo.update()

  end

  def payor_api_member_document(params) do
    params = params |> Map.delete(:file)
    with {:ok, token, payor_endpoint} <- UtilityContext.payor_link_sign_in_with_address("Maxicar"),
         head <- [{"Content-type", "application/json"},{"authorization", "Bearer #{token}"}],
         url <- "#{payor_endpoint}members/document",
         body <- Poison.encode!(params),
         {:ok, response} <- HTTPoison.post(url, body, head, []),
         200 <- response.status_code
    do
      {:ok, response.body |> Poison.decode()}
    else
      {:error, response} ->
        {:error_api, response}

      400 ->
        400

      403 ->
        403

      _ ->
        "Error Api Request"
    end

  end

  def changeset_errors_to_str(errors) do
    for {field, {message, opts}} <- errors do
      "#{message}"
    end
    |> Enum.join(", ")
  end
end
## do not use member schema
