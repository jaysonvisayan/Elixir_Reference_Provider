defmodule ProviderLinkWeb.Api.V1.DoctorController do
  use ProviderLinkWeb, :controller

  alias Data.Contexts.{
    UtilityContext,
    DoctorContext
  }
  alias ProviderLinkWeb.MemberView
  alias ProviderLinkWeb.Api.V1.ErrorView


  def insert_update_doctor(conn, params) do
    doctor = DoctorContext.get_doctor_by_code(params["code"])
    if is_nil(doctor) do
      insert_doctor_from_payorlink(conn, params)
    else
      update_doctor_from_payorlink(conn, doctor, params)
    end
  end

  defp insert_doctor_from_payorlink(conn, params) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "practitioners/code?code=#{params["code"]}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            params =
            %{
              payorlink_practitioner_id: decoded["id"],
              first_name: decoded["first_name"],
              middle_name: decoded["middle_name"],
              last_name: decoded["last_name"],
              code: decoded["code"],
              extension: decoded["suffix"],
              prc_number: decoded["prc_no"],
              specialization: decoded["specialization"],
              status: decoded["status"],
              affiliated: decoded["affiliated"]
            }
            with {:ok, _doctor} <- DoctorContext.create_doctor(params) do
              render(conn, MemberView, "message.json", message: "Successfully inserted doctor")
            else
              _ ->
              conn
              |> put_status(400)
              |> render(ErrorView, "error.json", message: "Error inserting doctor")
            end
            _ ->
              conn
              |> put_status(400)
              |> render(ErrorView, "error.json", message: "Error connecting to PayorLink")
        end
      _ ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Error connecting to PayorLink")
    end
  end

  defp update_doctor_from_payorlink(conn, doctor, params) do
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        url = "practitioners/code?code=#{params["code"]}"
        case UtilityContext.connect_to_api_get_with_token(token, url, "Maxicar") do
          {:ok, response} ->
            decoded = Poison.decode!(response.body)
            params =
            %{
              payorlink_facility_id: decoded["id"],
              name: decoded["name"],
              code: decoded["code"],
              phone_no: decoded["phone_no"],
              email_address: decoded["email_address"],
              line_1: decoded["line_1"],
              line_2: decoded["line_2"],
              city: decoded["city"],
              province: decoded["province"],
              region: decoded["region"],
              country: decoded["country"],
              postal_code: decoded["postal_code"]
            }
            with {:ok, _doctor} <- DoctorContext.update_doctor(doctor, params) do
              render(conn, MemberView, "message.json", message: "Successfully updated doctor")
            else
              _ ->
              conn
              |> put_status(400)
              |> render(ErrorView, "error.json", message: "Error updating doctor")
            end
            _ ->
              conn
              |> put_status(400)
              |> render(ErrorView, "error.json", message: "Error connecting to PayorLink")
        end
      _ ->
        conn
        |> put_status(400)
        |> render(ErrorView, "error.json", message: "Error connecting to PayorLink")
    end
  end

end