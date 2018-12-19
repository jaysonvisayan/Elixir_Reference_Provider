# do not use member schema
defmodule ProviderLinkWeb.MemberController do
  use ProviderLinkWeb, :controller

#   alias Data.Schemas.{
#     Card,
#     Member,
#     Loa,
#     User
#   }
#   alias Data.Contexts.{
#     MemberContext,
#     LoaContext,
#     ProviderContext,
#     UserContext,
#     UtilityContext
#   }
#   alias Guardian.Plug
#   alias Data.Utilities.SMS
#   alias Data.Repo

#   def index(conn, params) do
#     with user = %User{} <- params["paylink_user_id"] |> UserContext.get_user_by_paylink_user_id
#     do
#       render(conn, "member_eligibility_no_session.html", user: user)
#     else
#       nil ->
#         conn
#         |> put_flash(:error, "You must be signed in to access that page.")
#         |> redirect(to: "/sign_in")
#     end
#   end

#   def validate_member_no_session(conn, %{"paylink_user_id" => paylink_user_id, "full_name" => full_name, "birth_date" => birth_date, "coverage" => coverage}) do
#     user =
#       paylink_user_id
#       |> UserContext.get_user_by_paylink_user_id

#     facility_code = user.agent.provider.code

#     conn
#     |> validate_member(
#       facility_code,
#       full_name,
#       birth_date,
#       coverage
#     )
#   end

#   def validate_evoucher_no_session(conn, %{"paylink_user_id" => paylink_user_id, "evoucher_number" => evoucher_number, "coverage" => coverage}) do
#     user =
#       paylink_user_id
#       |> UserContext.get_user_by_paylink_user_id

#     facility_code = user.agent.provider.code
#     coverage = "ACU"

#     conn
#     |> validate_evoucher(
#       facility_code,
#       evoucher_number,
#       coverage
#     )
#   end

#   def validate_evoucher(conn, %{"evoucher_number" => evoucher_number}) do
#     facility_code = conn.assigns.current_user.agent.provider.code
#     coverage = "ACU"

#     conn
#     |> validate_evoucher(
#       facility_code,
#       evoucher_number,
#       coverage
#     )
#   end

#   defp validate_evoucher(conn, facility_code, evoucher_number, coverage) do
#     with {:ok, member} <- MemberContext.validate_evoucher(conn, evoucher_number, facility_code, coverage) do
#         facilities = ProviderContext.get_all_providers_name
#         member = member |> Repo.preload([:card])
#         conn
#         |> render(
#           ProviderLinkWeb.MemberView,
#           "member.json",
#           member: member,
#           facilities: facilities
#         )
#     else
#       {:empty_number} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "eVoucher Number is required")
#       {:invalid_number_length} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "eVoucher Number should be completed")
#       {:internal} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "PayorLink Internal Server Error")
#       {:invalid_member} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Member is not active")
#       {:evoucher_not_found} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "eVoucher number does not exist")
#       {:unable_to_login} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Unable to login to payorlink API")
#       {:invalid, message} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
#       ### Handled all error messages for eligibility
#       {:error_message, message} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
#       {:error, response} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: response)
#       {:error} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "eVoucher Number does not exist")
#     end
#   end

#   def validate_number_no_session(conn, %{"paylink_user_id" => paylink_user_id, "number" => number, "bdate" => bdate, "coverage" => coverage}) do
#     user =
#       paylink_user_id
#       |> UserContext.get_user_by_paylink_user_id

#     facility_code = user.agent.provider.code
#     coverage = "ACU"

#     conn
#     |> validate_number(number, bdate, facility_code, coverage)

#   end

#   def validate_number(conn, %{"number" => number, "bdate" => bdate, "coverage" => coverage}) do
#     facility_code = conn.assigns.current_user.agent.provider.code

#     conn
#     |> validate_number(number, bdate, facility_code, coverage)

#   end

#   defp validate_number(conn, number, bdate, facility_code, coverage) do
#   facilities = ProviderContext.get_all_providers_name
#    validate = MemberContext.validate_number(conn, number, bdate, facility_code, coverage)
#     with {:ok, card, member} <- validate,
#           member = %Member{} <- MemberContext.insert_payorlink_security(conn, member) do
#       conn
#       |> render(
#         ProviderLinkWeb.MemberView,
#         "member.json",
#         member: member,
#         facilities: facilities
#       )
#     else
#       _ ->
#         validate_number_return(conn, validate)
#     end
#   end

#   defp validate_number_return(conn, validate) do
#     case validate do
#       {:empty_number} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Card Number is required")

#       {:invalid_number_length} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Card Number should be 16-digit")

#       {:internal} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "PayorLink Internal Server Error")

#       {:invalid_member} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Member not eligible")

#       {:member_not_active} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Member is not active")

#       {:error} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "The Card number you have entered is invalid")

#       {:invalid, message} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)

#       _ ->
#         validate_number_return2(conn, validate)
#     end
#   end

#   defp validate_number_return2(conn, validate) do
#     case validate do
#       ### for payorlink_validate_loa_return
#       {:internal_get_error} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "PayorLink Internal Server Error")

#       ### Handled all error messages for eligibility
#       {:error_message, message} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)

#       {:error, response} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: response)

#       {:unable_to_login} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Unable to Login")

#       {:payor_does_not_exists} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Payor not existing")

#       {:card_no_bdate_not_matched, message} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)

#       _ ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Internal Server Error")
#     end
#   end

#   # def validate_number_cvv_loa(conn, %{"number" => number, "cvv" => cvv, "loa_id" => loa_id}) do
#   #   validate = MemberContext.validate_number_cvv_loa(conn, number, cvv, loa_id, conn.assigns.current_user.id)
#   #   case MemberContext.validate_number_cvv_loa(conn, number, cvv, loa_id, conn.assigns.current_user.id) do
#   #     {:ok, card, member} ->
#   #       facilities = ProviderContext.get_all_providers_name
#   #       if is_nil(member.middle_name) do
#   #         conn
#   #         |> render(
#   #           ProviderLinkWeb.MemberView,
#   #           "card1.json",
#   #           card: card,
#   #           member: member,
#   #           facilities: facilities
#   #         )
#   #       else
#   #         conn
#   #         |> render(
#   #           ProviderLinkWeb.MemberView,
#   #           "card2.json",
#   #           card: card,
#   #           member: member,
#   #           facilities: facilities
#   #         )
#   #       end

#   #     {:empty_number} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Card Number is required")

#   #     {:invalid_number_length} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Card Number should be 16-digit")

#   #     {:internal} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: "PayorLink Internal Server Error")

#   #     {:invalid_member} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Member not eligible")

#   #     {:error} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Card Number does not exist")

#   #     ### for payorlink_validate_loa_return
#   #     {:internal_get_error} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: "PayorLink Internal Server Error")

#   #     ### Handled all error messages for eligibility
#   #     {:error_message, message} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)

#   #     {:error, response} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: response)

#   #     {:unable_to_login} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Unable to Login")

#   #     {:payor_does_not_exists} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Payor not existing")

#   #     {:invalid_loa_otp, message} ->
#   #       render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)

#   #   end
#   # end

#   # def validate_cvv(conn, %{"number" => number, "cvv" => cvv}) do
#   #   number = "#{number}"
#   #   cvv = "#{cvv}"
#   #   case MemberContext.validate_cvv(number, cvv) do
#   #   {:ok, card} ->
#   #     facilities = ProviderContext.get_all_providers_name
#   #     member = MemberContext.get_member(card.member_id)
#   #     if is_nil(member.middle_name) do
#   #       conn
#   #       |> render(
#   #         ProviderLinkWeb.MemberView,
#   #         "card1.json",
#   #         card: card,
#   #         member: member,
#   #         facilities: facilities
#   #       )
#   #     else
#   #       conn
#   #       |> render(
#   #         ProviderLinkWeb.MemberView,
#   #         "card2.json",
#   #         card: card,
#   #         member: member,
#   #         facilities: facilities
#   #       )
#   #     end
#   #   {:empty_cvv} ->
#   #     render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Card CVV is required")
#   #   {:invalid_cvv_length} ->
#   #     render(conn, ProviderLinkWeb.MemberView, "message.json", message: "CVV should be 3-digit")
#   #   {:error} ->
#   #     render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Card CVV do not match")
#   #   end
#   # end

#   def request(conn, params) do
#     user = Plug.current_resource(conn)
#     link = "#{params["link"]}"
#     card = MemberContext.get_card_by_member_id(params["member_id"])
#     params = %{
#       card_id: card.id,
#       coverage: link,
#       provider_id: user.agent.provider.id,
#       status: "draft"
#     }
#     loa = LoaContext.insert_card_loa(params)
#     conn
#     |> put_flash(:info, "Member validated")
#     |> redirect(to: "/loas/#{loa.id}/request/#{link}")
#   end

#   def validate_member(conn, %{"full_name" => full_name, "birth_date" => birth_date, "coverage" => coverage}) do
#     facility_code = conn.assigns.current_user.agent.provider.code

#     conn
#     |> validate_member(
#       facility_code,
#       full_name,
#       birth_date,
#       coverage
#     )
#   end

#   defp validate_member(conn, facility_code, full_name, birth_date, coverage) do
#     case LoaContext.validate_member_by_details(conn, facility_code, full_name, birth_date, coverage) do
#       {:ok, member} ->
#         facilities = ProviderContext.get_all_providers_name
#         if Enum.count(List.flatten(member)) == 1 do
#           member =
#             member
#             |> List.flatten()
#             |> List.first

#             member = MemberContext.get_member(member.id)
#             with member = %Member{} <- MemberContext.insert_payorlink_security(conn, member) do
#               conn
#               |> render(
#                 ProviderLinkWeb.Api.V1.LoaView,
#                 "member.json",
#                 member: member,
#                 facilities: facilities
#               )
#             else
#               _ ->
#                 render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Member not found")
#             end
#         else
#           conn
#           |> render(
#             ProviderLinkWeb.Api.V1.LoaView,
#             "many_member.json",
#             member: member,
#             facilities: facilities
#           )
#         end
#       {:invalid, message} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
#       _ ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Invalid Input")
#     end
#   end

#   def validate_pin(conn, %{"id" => id, "pin" => pin}) do
#     case MemberContext.validate_pin(id, pin) do
#       {:ok} ->
#         member = MemberContext.get_member(id)
#         card = MemberContext.get_card_by_member_id(member.id)
#         facilities = ProviderContext.get_all_providers_name

#         conn
#         |> render(
#           ProviderLinkWeb.MemberView,
#           "member.json",
#           member: member,
#           facilities: facilities
#         )
#       {:member_not_found} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Member Not Found!")
#       {:invalid_pin_length} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Pin should be 4-digit")
#       {:expired} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Pin already expired")
#         _ ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Invalid PIN")
#     end
#   end

#   def send_pin(conn, %{"id" => id}) do
#     member = MemberContext.get_member(id)
#       {_, member}  = MemberContext.insert_pin(member)
#       if not is_nil(member.mobile) do
#         # transform number to 639
#         member_mobile = SMS.transforms_number(member.mobile)
#         SMS.send(%{text: "Your verification code is #{member.pin}", to: member_mobile})
#       end
#       card = MemberContext.get_card_by_member_id(member.id)
#       facilities = ProviderContext.get_all_providers_name

#     conn
#     |> render(
#       ProviderLinkWeb.MemberView,
#       "member.json",
#       member: member,
#       facilities: facilities
#     )
#   end

#   def get_member_by_account_code(conn, %{"code" => code}) do
#     member = MemberContext.get_member_by_account_code(code)
#     facilities = ProviderContext.get_all_providers_name

#     conn
#     |> render(
#       ProviderLinkWeb.MemberView,
#       "member.json",
#       member: member,
#       facilities: facilities
#     )
#   end

#   def attempt_expiry(conn, %{"card_no" => card_no}) do
#     # datetime = Ecto.DateTime.utc()
#     # member = MemberContext.get_member(id)
#     # MemberContext.add_attempt(member)
#     # facilities = ProviderContext.get_all_providers_name
#     # conn
#     # |> render(
#     #   ProviderLinkWeb.MemberView,
#     #   "member.json",
#     #   member: member,
#     #   facilities: facilities
#     # )
#   end

#   def validate_evoucher(conn, _) do
#       render(conn, "peme.html")
#   end

#     # def new_create_mobile_no(conn, %{"member_id" => member_id}) do
#   #   member = MemberContext.get_member(member_id)
#   #   changeset = MemberContext.card_changeset(%Card{})
#   #   render(conn, "create_mobile_no_form.html", changeset: changeset, member: member)
#   # end

#   # def create_mobile_no(conn, %{"member_id" => member_id, "member" => member_params}) do
#   #   with {:ok, member} <- MemberContext.update_mobile_no(member_id, member_params["mobile"]) do
#   #     conn
#   #     |> put_flash(:info, "Mobile Number successfully registered")
#   #     |> redirect(to: "/loas/#{member_id}/package_info")
#   #   else
#   #     _ ->
#   #     conn
#   #     |> put_flash(:error, "Error creating mobile no")
#   #     |> redirect(to: "/members/#{member_id}/create_mobile_no")
#   #   end
#   # end

#   # def new_update_mobile_no(conn, %{"member_id" => member_id}) do
#   #   member = MemberContext.get_member(member_id)
#   #   changeset = MemberContext.card_changeset(%Card{})
#   #   render(conn, "update_mobile_no_form.html", changeset: changeset, member: member)
#   # end

#   # def update_mobile_no(conn, %{"member_id" => member_id, "member" => member_params}) do
#   #   with {:ok, member} <- MemberContext.update_mobile_no(member_id, member_params["mobile"]) do
#   #     conn
#   #     |> put_flash(:info, "Mobile Number successfully updated")
#   #     |> redirect(to: "/loas/#{member_id}/package_info")
#   #   else
#   #     {:error, message} ->
#   #       conn
#   #       |> put_flash(:error, message)
#   #       |> redirect(to: "/members/#{member_id}/update_mobile_no")
#   #     _ ->
#   #       conn
#   #       |> put_flash(:error, "Error updating mobile no")
#   #       |> redirect(to: "/members/#{member_id}/update_mobile_no")
#   #   end
#   # end

#   # def get_all_mobile_no(conn, %{"id" => member_id}) do
#   #   mobile_nos =  MemberContext.get_all_mobile_no(member_id)
#   #   json conn, Poison.encode!(mobile_nos)
#   # end

#   # def get_all_mobile_no(conn, _params) do
#   #   mobile_nos =  MemberContext.get_all_mobile_no()
#   #   json conn, Poison.encode!(mobile_nos)
#   # end

#   def scan(conn, %{"id" => id, "coverage" => coverage}) do
#     member = MemberContext.get_member(id)
#     loa = LoaContext.get_loas_by_member_id(member.card.id)
#     with true <- Enum.empty?(loa) do
#       changeset = Loa.create_changeset(%Loa{})
#       action = member_path(conn, :scan_id, member, coverage)
#       render(
#         conn,
#         "scan_id.html",
#          changeset: changeset,
#          member: member,
#          action: action
#       )
#     else
#       _ ->
#       loa = Enum.at(loa, 0)
#       conn
#       |> redirect(to: "/loas/#{member.id}/package_info/member_details/#{loa.id}")
#     end
#   end

#   def scan_no_session(conn, %{"id" => id, "paylink_user_id" => paylink_user_id}) do
#     member = MemberContext.get_member(id)
#     changeset = Loa.create_changeset(%Loa{})
#     action = member_path(conn, :scan_id_no_session, member.id, paylink_user_id)
#     render(
#       conn,
#       "scan_id.html",
#        changeset: changeset,
#        member: member,
#        action: action
#     )
#   end

#   def scan_id(conn, %{"id" => id, "loa" => params, "coverage" => coverage}) do
#     member = MemberContext.get_member(id)
#     acu_params =
#     %{
#      facility_code: conn.assigns.current_user.agent.provider.code,
#      coverage_code: coverage,
#      card_no: params["card_no"]
#     }
#     params =
#     params
#     |> Map.put("provider_id", conn.assigns.current_user.agent.provider.id)
#     |> Map.put("verification_type", "member_details")

#     case String.downcase(coverage) do
#       "acu" ->
#         params =
#           params
#           |> Map.put("user_id", conn.assigns.current_user.id)

#           redirect_to_package_info(conn, acu_params, params, "member_details")
#       "op consult" ->
#         params =
#           params
#           |> Map.put("card_id", member.card.id)
#           |> Map.put("coverage", coverage)
#           |> Map.put("created_by_id", conn.assigns.current_user.id)
#           |> Map.put("status", "Draft")
#           |> Map.put("consultation_date",  Ecto.DateTime.utc)

#         conn
#         |> redirect_to_consult_info(member, params)
#     end
#   end

#   def scan_id_no_session(conn, %{"id" => id, "loa" => params, "paylink_user_id" => paylink_user_id}) do
#     params =
#     params
#     |> Map.put("member_id", id)
#     |> Map.put("paylink_user_id", paylink_user_id)
#     |> Map.put("verification", "member_details")
#     no_session_params(conn, params)
#   end

#   def no_session_params(conn, params) do
#     member_id = params["member_id"]
#     card_no = params["card_no"]
#     paylink_user_id = params["paylink_user_id"]
#     verification_type = params["verification"]
#     client_ip =
#       conn.remote_ip
#       |> Tuple.to_list
#       |> Enum.join(".")
#     user =
#       paylink_user_id
#       |> UserContext.get_user_by_paylink_user_id
#     member = MemberContext.get_acu_member(member_id)
#     acu_params =
#     %{
#       facility_code: user.agent.provider.code,
#       coverage_code: "ACU",
#       card_no: card_no,
#       user: Enum.join([user.agent.first_name, user.agent.last_name], " "),
#       client_ip: client_ip
#     }
#     params =
#       params
#       |> Map.put("provider_id", user.agent.provider.id)
#       |> Map.put("user_id", user.id)
#       |> Map.put("verification_type", verification_type)

#     redirect_to_package_info_no_session(conn, member, acu_params, params, paylink_user_id)
#   end

#   def redirect_with_session(conn, %{"card_no" => card_no, "verification" => verification_type, "coverage" => coverage}) do
#     case String.downcase(coverage) do
#       "peme" ->
#         loa = Enum.at(LoaContext.get_loa_by_card_no(card_no), 0)
#         peme_coverage_params =
#           %{
#             facility_code: conn.assigns.current_user.agent.provider.code,
#             coverage_code: coverage,
#             card_no: loa.member_card_no
#           }
#         params =
#           %{
#             "provider_id" => conn.assigns.current_user.agent.provider.id,
#             "coverage_code" => coverage,
#             "card_no" => loa.member_card_no,
#             "member_id" => loa.payorlink_member_id,
#             "verification_type" => verification_type,
#             "user_id" => conn.assigns.current_user.id
#           }

#         redirect_to_package_info_peme(conn, loa, peme_coverage_params, params, verification_type)
#       "acu" ->
#         get_coverage_params =
#           %{
#             facility_code: conn.assigns.current_user.agent.provider.code,
#             coverage_code: coverage,
#             card_no: card_no
#           }
#         params = %{}
#         params =
#           params
#           |> Map.put("provider_id", conn.assigns.current_user.agent.provider.id)
#           |> Map.put("verification_type", verification_type)
#           # |> Map.put("member_id", id)
#         params =
#           params
#           |> Map.put("card_no", card_no)
#           |> Map.put("user_id", conn.assigns.current_user.id)
#         redirect_to_package_info(conn, get_coverage_params, params, verification_type)
#       # "op consult" ->
#       #   member = MemberContext.get_member(id)
#       #   get_coverage_params =
#       #     %{
#       #       facility_code: conn.assigns.current_user.agent.provider.code,
#       #       coverage_code: coverage,
#       #       card_no: member.card.number
#       #     }
#       #   params = %{}
#       #   params =
#       #     params
#       #     |> Map.put("card_id", member.card.id)
#       #     |> Map.put("coverage", coverage)
#       #     |> Map.put("created_by_id", conn.assigns.current_user.id)
#       #     |> Map.put("status", "Draft")
#       #     |> Map.put("consultation_date",  Ecto.DateTime.utc)

#       #   conn
#       #   |> redirect_to_consult_info(member, params)
#     end
#   end

#   def no_session_for_all(conn, params) do
#     no_session_params(conn, params)
#   end

#   defp redirect_to_package_info(conn, acu_params, params, verification_type) do
#     with {:ok, response} <- LoaContext.get_acu_details(conn, acu_params),
#          false <- Enum.empty?(response["payor_procedure"]),
#          true <- Enum.empty?(LoaContext.get_loas_by_card_no(params["card_no"])),
#          {:ok, loa} <- LoaContext.request_loa_acu(params, response)
#     do
#       conn
#       # |> redirect(to: "/loas/#{loa.id}/package_info/#{verification_type}")
#       |> redirect(to: "/loas/#{loa.id}/show")
#     else
#       {:error, message} ->
#         conn
#         |> put_flash(:error, message)
#         |> redirect(to: page_path(conn, :index))
#       true ->
#         conn
#         |> put_flash(:error, "Member is not eligible to avail ACU in this Hospital/Clinic.")
#         |> redirect(to: page_path(conn, :index))
#       false ->
#         loa = LoaContext.get_loas_by_card_no(params["card_no"])
#         loa = loa |> List.first()
#         conn
#         |> redirect(to: "/loas/#{params["card_no"]}/package_info/#{verification_type}/#{loa.id}")
#       _ ->
#         conn
#         |> put_flash(:error, "Error")
#         |> redirect(to: page_path(conn, :index))
#     end
#   end

#   defp redirect_to_package_info_no_session(conn, member, acu_params, params, paylink_user_id) do
#     loas =
#       acu_params.card_no
#       |> LoaContext.get_loa_by_card_no()
#       |> Enum.reject(&(is_nil(&1.payorlinkone_loe_no)))
#     with true <- Enum.empty?(loas),
#          {:ok, response} <- LoaContext.get_acu_details(conn, acu_params),
#          {:ok, loa} <- LoaContext.request_loa_acu(params, response),
#          {:ok, paylink_response} <- LoaContext.create_acu_loa_paylink_params(conn, loa, member, acu_params, response),
#          {:ok, loa} <- LoaContext.insert_loe_n_claim_no(loa, List.first(paylink_response))
#     do
#       conn
#       |> redirect(to: "/loas/#{loa.payorlinkone_loe_no}/package_info_no_session/member_details/#{paylink_user_id}")
#     else
#       false ->
#         check_loa_provider(conn, loas, params, paylink_user_id)
#       {:error, nil} ->
#         conn
#         |> put_flash(:error, "Error inserting data in paylink")
#         |> redirect(to: member_path(conn, :index, paylink_user_id))
#       {:error, message} ->
#         conn
#         |> put_flash(:error, message)
#         |> redirect(to: member_path(conn, :index, paylink_user_id))
#       _ ->
#         conn
#         |> put_flash(:error, "Error")
#         |> redirect(to: member_path(conn, :index, paylink_user_id))
#     end
#   end

#   defp check_loa_provider(conn, loas, params, paylink_user_id) do
#     loa = Enum.find(loas, &(&1.provider_id == params["provider_id"]))
#     if is_nil(loa) do
#       conn
#       |> put_flash(:error, "You are no longer valid to request ACU’. Reason: Member already requested in another Hospital/Clinic.")
#       |> redirect(to: "/members/eligibility/#{paylink_user_id}")
#     else
#       conn
#       |> redirect(to: "/loas/#{loa.payorlinkone_loe_no}/package_info_no_session/member_details/#{paylink_user_id}")
#     end
#   end

#   #PEME
#   def validate_accountlink_evoucher(conn, %{"evoucher" => evoucher}) do
#     facility_code = conn.assigns.current_user.agent.provider.code
#     with {:ok, loa} <- MemberContext.get_accountlink_member_evoucher(conn, evoucher, facility_code, "PEME") do
#         conn
#         |> render(
#           ProviderLinkWeb.MemberView,
#           "loa_member.json",
#           loa: loa
#         )
#     else
#       {:internal} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "PayorLink Internal Server Error")
#       {:evoucher_not_found} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "eVoucher number does not exist")
#       {:unable_to_login} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Payorlink Error")
#       {:invalid, message} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
#       ### Handled all error messages for eligibility
#       {:error_message, message} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: message)
#       {:error, response} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: response)
#       {:error} ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "eVoucher Number does not exist")
#     end
#   end

#   def validate_accountlink_member(conn, %{"id" => id}) do
#     with member = %Member{} <- MemberContext.get_member(id) do
#       changeset = Member.changeset_accountlink(member)
#       conn
#       |> render(
#         "validate_member.html",
#         conn: conn,
#         member: member,
#         changeset: changeset
#       )
#     else
#       _ ->
#       render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Member not found")
#     end
#   end

#   # def update_accountlink_member(conn, %{"id" => id, "params" => params}) do
#     # raise 123
#   # end

#   defp redirect_to_consult_info(conn, member, params) do

#     with {:ok, params} <- generate_transaction_no(conn, params),
#          {:ok, loa} <- LoaContext.create_loa(params)
#     do
#         conn
#         |> redirect(to: "/loas/#{loa.id}/request/consult")
#     else
#       {:error, message} ->
#         conn
#         |> put_flash(:error, message)
#         |> redirect(to: page_path(conn, :index))
#       {:unable_to_login} ->
#         conn
#         |> put_flash(:error, "Unable to login")
#         |> redirect(to: page_path(conn, :index))
#       {:error_connecting_api} ->
#         conn
#         |> put_flash(:error, "Error Connecting API")
#         |> redirect(to: page_path(conn, :index))
#       {:payor_does_not_exists} ->
#         conn
#         |> put_flash(:error, "Payor does not exist")
#         |> redirect(to: page_path(conn, :index))
#     end
#   end

#   def generate_transaction_no(conn, params) do
#     with {:ok, response} <- UtilityContext.connect_to_api_get(conn,
#       "Maxicar", "loa/generate/transaction_no")
#     do
#       decoded = Poison.decode!(response.body)

#       params =
#       params
#       |> Map.put("transaction_id", decoded["message"])
#       {:ok, params}
#     else
#       {:unable_to_login} ->
#         {:unable_to_login}
#       {:error_connecting_api} ->
#         {:error_connecting_api}
#       {:payor_does_not_exists} ->
#         {:payor_does_not_exists}
#     end
#   end

#   def index_no_session(conn, params) do
#     with user = %User{} <- params["paylink_user_id"] |> UserContext.get_user_by_paylink_user_id
#     do
#       member = MemberContext.get_member_by_card(params["card_no"])
#       member =
#       if is_nil(member) do
#         with {:ok, card, member} <- MemberContext.get_payorlink_member_card(conn, params["card_no"]) do
#           member
#         else
#           _ ->
#             nil
#         end
#       else
#         member
#       end

#       render(conn, "member_eligibility_iframe.html", user: user, card_number: params["card_no"], member: member)
#     else
#       nil ->
#         conn
#         |> put_flash(:error, "You must be signed in to access that page.")
#         |> redirect(to: "/sign_in")
#     end
#   end

#   def get_member(conn, %{"card_no" => card_no}) do
#     with {:ok, member} <- LoaContext.payorlink_get_member(conn, card_no) do
#       facilities = ProviderContext.get_all_providers_name
#       conn
#       |> render(
#         ProviderLinkWeb.Api.V1.LoaView,
#         "member.json",
#         member: member,
#         facilities: facilities
#       )
#     else
#       _ ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Member not found")
#     end
#   end

#   def blocked_member(conn, %{"id" => id}) do
#     with member = %Member{} <- MemberContext.get_member(id),
#          {:ok, member} <- MemberContext.update_member_attempt(member)
#     do
#       conn
#       |> render(
#         ProviderLinkWeb.MemberView,
#         "block_member.json",
#         member: member
#       )
#     else
#       _ ->
#         render(conn, ProviderLinkWeb.MemberView, "message.json", message: "Member not found")
#     end
#   end

#   # PEME

#   defp redirect_to_package_info_peme(conn, loa, peme_params, params, verification_type) do
#     with {:ok, response} <- LoaContext.get_peme_details(conn, peme_params),
#          false <- Enum.empty?(response["payor_procedure"]),
#          {:ok, loa} <- LoaContext.request_loa_peme(conn, loa, params, response)
#     do
#       conn
#       |> redirect(to: "/loas/#{loa.payorlink_member_id}/package_info/#{verification_type}/#{loa.id}")
#     else
#       {:error, message} ->
#         conn
#         |> put_flash(:error, message)
#         |> redirect(to: page_path(conn, :index))
#       true ->
#         conn
#         |> put_flash(:error, "Member is not eligible to avail PEME in this Hospital/Clinic.")
#         |> redirect(to: page_path(conn, :index))
#       _ ->
#         conn
#         |> put_flash(:error, "Error")
#         |> redirect(to: page_path(conn, :index))
#     end
#   end

end
# do not use member schema
