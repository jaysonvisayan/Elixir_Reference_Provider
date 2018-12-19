defmodule ProviderWorker.Job.SubmitAcuScheduleUploadJob do
  @moduledoc """
    This module creates user
  """

  alias Data.Contexts.{
    UtilityContext,
    AcuScheduleContext
  }

  alias Data.Repo
  alias Ecto.Changeset

  alias Data.Parsers.ProviderLinkParser

  def perform(params, conn) do
    asm = AcuScheduleContext.get_acu_schedule_member(params["id"])
    ProviderLinkParser.upload_image(asm, params)
    upload_image_to_payorlink(conn, asm, params)
    verify_facial_biometrics(conn, asm, params)
  end

  defp upload_image_to_payorlink(conn, asm, params) do
    params = %{
      "member_id" => asm.loa.payorlink_member_id,
      "file_name" => params["file_name"],
      "base_64_encoded" => params["base_64_encoded"],
      "content_type" => "#{params["type"]}/#{params["extension"]}",
      "extension" => params["extension"]
    }
    url = "acu_schedule/acu_schedule_member/upload_image"
    case UtilityContext.payor_link_sign_in(%{scheme: String.to_atom(conn["scheme"])}, "Maxicar") do
      {:ok, token} ->
        with {:ok, response} <- UtilityContext.connect_to_api_put_with_token(token, url, params,  "Maxicar") do
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

  end

  defp verify_facial_biometrics(conn, asm, image) do
    is_recognized = AcuScheduleContext.verify_facial_biometrics(%{scheme: String.to_atom(conn["scheme"])}, asm, image)
    if is_recognized == true or is_recognized == false do
      Repo.update(Changeset.change asm, submit_log: "Successfully Submitted", is_recognized: is_recognized)
    else
        Repo.update(Changeset.change asm, submit_log: "Unable to connect in facial biometrics API", is_recognized: false)
    end
  end
end
