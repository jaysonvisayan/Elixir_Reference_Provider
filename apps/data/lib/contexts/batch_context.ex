defmodule Data.Contexts.BatchContext do
  @moduledoc """
  """

  import Ecto.{Query, Changeset}, warn: false

  alias Data.Repo
  alias Data.Schemas.{
    Batch,
    BatchLoa,
    Sequence,
    Loa,
    AcuSchedule,
    AcuScheduleMember
  }
  alias Data.Contexts.{
    LoaContext,
    UtilityContext
  }

  alias Data.Parsers.ProviderLinkParser

  def list_all do
    Batch
    |> Repo.all()
    |> Repo.preload([:created_by, :doctor])
  end

  def get_batch_by_number(number) do
    Batch
    |> Repo.get_by(number: number)
  end

  def get_batch(id) do
    Batch
    |> Repo.get(id)
    |> Repo.preload([
      :doctor,
      :files,
      created_by: [agent: :provider],
      batch_loas: [:batch, loa: [member: :card]]
      ])
  end

  def create_batch(params, user_id) do
    batch_no = batch_no()

    with nil <- get_batch_by_number(batch_no()) do
      params =
        params
        |> Map.put("number", batch_no)
        |> Map.put("created_by_id", user_id)
        |> Map.put("updated_by_id", user_id)
        |> Map.put("status", "Processing")

        %Batch{}
        |> Batch.changeset(params)
        |> Repo.insert()
    else
      _ ->
       create_batch(params, user_id)
    end
  end

  def update_batch(batch, params) do
    batch
    |> Batch.changeset(params)
    |> Repo.update()
  end

  def insert_batch_loa(params) do
    %BatchLoa{}
    |> BatchLoa.changeset(params)
    |> Repo.insert()
  end

  def create_batch_loa(params) do
    BatchLoa
    |> Repo.insert_all(params)
  end

  def delete_batch_loas(batch) do
    BatchLoa
    |> where([bl], bl.batch_id == ^batch.id)
    |> Repo.delete_all()
  end

  def delete_batch(batch) do
    batch
    |> Repo.delete()
  end

  defp batch_no do
    {year, month, _}  = Ecto.Date.to_erl(Ecto.Date.utc())
    if String.length("#{month}") == 1, do: month = "0#{month}"
    prefix = Enum.join([month, String.slice("#{year}", 2..4)])
    suffix = Enum.random(10_000..99_999)

    Enum.join([prefix, "-", "R", suffix])
  end

  # def edit_soa(batch, amount) do
  #   batch
  #   |> Ecto.Changeset.change(%{edited_soa_amount: amount})
  #   |> Repo.update()
  # end

  def list_all_batch_for_loa() do
    Batch
    # |> where([b], b.status != "Submitted")
    |> select([b], b.number)
    |> Repo.all()
  end

  def add_loa_to_batch(batch_id, loa_ids) do
    batch = get_batch(batch_id)
    if batch.status == "Submitted" do
      {:already_submitted}
    else
      batch_loa =
        Enum.map(loa_ids, fn(loa_id) ->
          params = %{
            "batch_id" => batch_id,
            "loa_id" => loa_id
          }
          insert_batch_loa(params)
          LoaContext.update_loa_batch(params)
        end)
        batch_loa =
          batch_loa
          |> Enum.reject(&(&1 == nil))
          {:ok, batch_loa}
    end
  end

  def remove_batch_to_loa(batch_id, loa_id) do
    BatchLoa
    |> Repo.get_by(batch_id: batch_id, loa_id: loa_id)
    |> Repo.delete()
  end

  def attach_soa(params) do
    with batch = %Batch{} <- get_batch_by_number(params["batch_no"]),
         {:ok, "uploads"} <- validate_uploads(params["uploads"])
    do
      ProviderLinkParser.upload_a_file_batch(batch.id, params["uploads"])
      {:ok, batch}
    else
      {:error_upload_params} ->
        {:error_upload_params}
      {:error_base_64} ->
        {:error_base_64}
      {:error, changeset} ->
        {:error, changeset}
      nil ->
        {:batch_not_found}
      _ ->
        {:server_error}
    end
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

  def update_payorlink_loa_status(conn, params) do
    url = "loa/batch/acu_schedule/update_otp_status"
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        with {:ok, response} <- UtilityContext.connect_to_api_put_with_token(token, url, params,  "Maxicar") do
          {:valid}
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

  def get_batch_loa_by_batch_id(id) do
    BatchLoa
    |> where([bl], bl.batch_id == ^id)
    |> Repo.all()
  end

  def submit_batch(batch) do
    batch
    |> Ecto.Changeset.change(%{status: "Submitted"})
    |> Repo.update()
  end

  # SEQUENCE

  defp batch_no(number) do
    {year, month, _}  = Ecto.Date.to_erl(Ecto.Date.utc())
    if String.length("#{month}") == 1, do: month = "0#{month}"
    prefix = Enum.join([month, String.slice("#{year}", 2..-1)])
    updated_number = Integer.to_string(String.to_integer(number) + 1)
    number =
      cond do
        String.length(updated_number) == 7 ->
          "00#{updated_number}"
        String.length(updated_number) == 8 ->
          "0#{updated_number}"
        true ->
          updated_number
      end
    Enum.join([prefix, "-", "P", number])
  end

  def get_sequence(type) do
    query =
      from(s in Sequence,
      order_by: [desc: s.inserted_at],
      limit: 1)

    sequence =
      query
      |> where([s], s.type == ^type)
      |> Repo.one()

    Repo.update(Ecto.Changeset.change sequence, number: "#{String.to_integer(sequence.number) + 1}")
    sequence
  end

  def get_batch_by_acu_schedule_id(id) do
    Batch
    |> join(:inner, [b], as in AcuSchedule, b.id == as.batch_id)
    |> where([b, as], as.id == ^id)
    |> distinct([b, as], b.number)
    |> select([b, as], b)
    |> Repo.one()
  end

  def create_submitted_batch(params, user_id) do
    sequence = get_sequence("batch_no")
    batch_no = batch_no(sequence.number)

    params =
      params
      |> Map.put("number", batch_no)
      |> Map.put("created_by_id", user_id)
      |> Map.put("updated_by_id", user_id)

      %Batch{}
      |> Batch.changeset(params)
      |> Repo.insert()
  end

  def create_submitted_batch_payorlink(conn, params) do
    url = "/acu_schedules/create_batch"
    case UtilityContext.payor_link_sign_in(conn, "Maxicar") do
      {:ok, token} ->
        with {:ok, response} <- UtilityContext.connect_to_paylink_api_post(url, token, params,  "Maxicar") do
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

  def rollback_sequence(type) do
    query =
      from(s in Sequence,
      order_by: [desc: s.inserted_at],
      limit: 1)

    sequence =
      query
      |> where([s], s.type == ^type)
      |> Repo.one()

    Repo.update(Ecto.Changeset.change sequence, number: "#{String.to_integer(sequence.number) - 1}")
  end
end
