defmodule Data.Parsers.AcuScheduleParser do
  @moduledoc ""

  import Ecto.Query
  alias Data.Contexts.{
    AcuScheduleContext
  }

  alias Data.Schemas.File, as: UploadFile
  alias ProviderLinkWeb.LayoutView
  alias Data.Repo

  def parse_data(data, filename, acu_schedule_id, user_id) do

    file_params = %{
      filename: filename,
      created_by_id: user_id,
      acu_schedule_id: acu_schedule_id,
      remarks: "ok"
    }

    {:ok, upload_file} = AcuScheduleContext.create_asm_upload_file(file_params)

    data = Enum.drop(data, 0)

    encode =
      Enum.map(data, fn({_, data}) ->
        validations(data, acu_schedule_id, upload_file.id, user_id, filename)
      end)
      |> Enum.uniq()
      |> List.delete({:invalid})

    card_nos =
      Enum.map(data, fn({_, data}) ->
        validations(data, acu_schedule_id, upload_file.id, user_id, filename)
      end)
      |> Enum.count()

    if card_nos >= 0 do
      {:ok, encode}
    else
      {:invalid, "File has invalid contents."}
    end

  end

  def validations(data, acu_schedule_id, upload_file_id, user_id, filename) do
    availed = data["Availed ACU? (Y or N)"]
    card_no = String.replace(data["Card Number"], "'", "")
    cond do
      is_nil(AcuScheduleContext.get_loa_by_as_card_no(acu_schedule_id, card_no)) ->
        log_params = log_params(data, upload_file_id, user_id, filename)
        {:ok, log} = insert_log(log_params, "failed", "Card Number is not included in the batch")
        {:invalid}
      availed == "Y" || availed == "Yes" ->
        log_params = log_params(data, upload_file_id, user_id, filename)
        {:ok, log} = insert_log(log_params, "success", "Successfully selected")
        card_no
      availed == "N" || availed == "No" ->
        log_params = log_params(data, upload_file_id, user_id, filename)
        {:ok, log} = insert_log(log_params, "success", "Not selected")
        {:invalid}
      true ->
        log_params = log_params(data, upload_file_id, user_id, filename)
        {:ok, log} = insert_log(log_params, "failed", "Invalid availed ACU, this must be Y/Yes or N/No only")
        {:invalid}
    end
  end

  def insert_log(params, status, remarks) do
    params
    |> Map.put(:status, status)
    |> Map.put(:remarks, remarks)
    |> AcuScheduleContext.create_asm_upload_log()
  end

  def log_params(data, upload_file_id, user_id, filename) do
    %{
      acu_schedule_member_upload_file_id: upload_file_id,
      filename: filename,
      card_no: data["Card Number"],
      full_name: data["Full Name"],
      gender: data["Gender"],
      birthdate: data["Birthdate"],
      age: data["Age"],
      package_code: data["Package Code"],
      signature: data["Signature"],
      availed: data["Availed ACU? (Y or N)"],
      created_by_id: user_id
    }
  end

end
