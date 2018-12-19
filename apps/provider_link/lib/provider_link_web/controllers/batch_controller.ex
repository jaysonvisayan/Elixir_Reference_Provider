defmodule ProviderLinkWeb.BatchController do
  use ProviderLinkWeb, :controller

  alias Data.Schemas.{
    Card,
    Batch
  }
  alias Data.Contexts.BatchContext, as: BC
  alias Data.Contexts.{
    DoctorContext,
    LoaContext
  }

  plug Guardian.Permissions.Bitwise,
    [handler: ProviderLinkWeb.FallbackController,
     one_of: [
       %{batch: [:manage_batch]},
       %{batch: [:access_batch]},
     ]] when action in [
       :index,
       :batch_details
     ]

  plug Guardian.Permissions.Bitwise,
    [handler: ProviderLinkWeb.FallbackController,
     one_of: [%{batch: [:manage_batch]}
     ]] when not action in [
       :index,
       :batch_details,
     ]

  def index(conn, _params) do
    batches = BC.list_all()
    render(conn, "index.html", batches: batches)
  end

  def new(conn, %{"type" => type}) do
    type = String.downcase(type)
    if type == "practitioner" or type == "hospital_bill" do
      changeset = Batch.changeset(%Batch{})
      doctors = DoctorContext.get_doctors()
      # doctors = DoctorContext.get_all_affiliated_doctors(conn.assigns.current_user.agent.provider.id)
      render(conn, "new.html", conn: conn, changeset: changeset, doctors: doctors, type: String.downcase(type))
    else
      conn
      |> put_flash(:error, "Page not found!")
      |> redirect(to: batch_path(conn, :index))
    end
  end

  def new(conn, params) do
    conn
    |> put_flash(:error, "Page not found!")
    |> redirect(to: batch_path(conn, :index))
  end

  def create(conn, params) do
    params = params["batch"]
    user_id = conn.assigns.current_user.id
    provider = conn.assigns.current_user.agent.provider.name

    with {:ok, batch} <- BC.create_batch(params, user_id) do
      conn
      |> put_flash(:info, "Batch Successfully Created! #{batch.number} #{provider}.")
      |> redirect(to: "/batch/#{batch.id}/batch_details")
    else
      _ ->
      conn
      |> put_flash(:error, "Error occured. Batch not created")
      |> redirect(to: "/batch")
    end
  end

  def new_loa_batch(conn, %{"type" => type}) do
    type = String.downcase(type)
    if type == "practitioner" or type == "hospital_bill" do
      changeset = Batch.changeset(%Batch{})
      doctors = DoctorContext.get_doctors()
      # doctors = DoctorContext.get_all_affiliated_doctors(conn.assigns.current_user.agent.provider.id)
      render(conn, "new_loa_batch.html", conn: conn, changeset: changeset, doctors: doctors, type: String.downcase(type))
    else
      conn
      |> put_flash(:error, "Page not found!")
      |> redirect(to: loa_path(conn, :index))
    end
  end

  def new_loa_batch(conn, params) do
    conn
    |> put_flash(:error, "Page not found!")
    |> redirect(to: loa_path(conn, :index))
  end

  def create_loa_batch(conn, params) do
    params = params["batch"]
    user_id = conn.assigns.current_user.id
    provider = conn.assigns.current_user.agent.provider.name

    loa_ids = LoaContext.list_all_cart_loa_ids()
    if not Enum.empty?(loa_ids) do
      with {:ok, batch} <- BC.create_batch(params, user_id),
           {:ok, batch_loa} <- BC.add_loa_to_batch(batch.id, loa_ids)
      do
        conn
        |> put_flash(:info, "Batch Successfully Created! #{batch.number} #{provider}.")
        |> redirect(to: "/batch/#{batch.id}/batch_details")
      else
        _ ->
          conn
          |> put_flash(:error, "Error occurred. Batch not created")
          |> redirect(to: "/batch")
      end
    else
      conn
      |> put_flash(:error, "no loas found")
      |> redirect(to: "/loas")
    end
  end

  def batch_details(conn, %{"id" => id}) do
    with %Batch{} = batch <- BC.get_batch(id) do
      loa_batch = BC.get_batch_loa_by_batch_id(id)
      render(conn, "batch_details.html", conn: conn, batch: batch, loa_batch: loa_batch)
    else
      _ ->
      conn
      |> put_flash(:error, "Invalid Batch")
      |> redirect(to: "/batch")
    end
  end

  def batch_details(conn, params) do
    conn
    |> put_flash(:error, "Page not found!")
    |> redirect(to: batch_path(conn, :index))
  end

  def delete_batch(conn, %{"id" => id}) do
    with %Batch{} = batch <- BC.get_batch(id),
         true <- Enum.empty?(batch.batch_loas)
    do
      BC.delete_batch(batch)
      conn
      |> put_flash(:info, "Batch Successfully Deleted!")
      |> redirect(to: "/batch")
    else
      false ->
        conn
        |> put_flash(:error, "Batch has already attached LOA")
        |> redirect(to: "/batch/#{id}/batch_details")
      _ ->
        conn
        |> put_flash(:error, "Invalid Batch")
        |> redirect(to: "/batch")
    end
  end

  def delete_batch(conn, params) do
    conn
    |> put_flash(:error, "Page not found!")
    |> redirect(to: batch_path(conn, :index))
  end

  def edit_soa(conn, %{"id" => id, "amount" => amount}) do
    with %Batch{} = batch <- BC.get_batch(id),
          {:ok, batch} <- BC.edit_soa(batch, Decimal.new(amount))
    do
      conn
      |> put_flash(:info, "Successfully edited soa amount!")
      |> redirect(to: "/batch/#{id}/batch_details")
    else
      nil ->
        conn
        |> put_flash(:error, "Invalid batch")
        |> redirect(to: "/batch")
      _ ->
        conn
        |> put_flash(:error, "Error updating soa amount!")
        |> redirect(to: "/batch/#{id}/batch_details")
    end
  end

  def edit_soa(conn, params) do
    conn
    |> put_flash(:error, "Page not found!")
    |> redirect(to: "/batch")
  end


  def remove_to_batch(conn, %{"id" => id, "loa_id" => loa_id}) do
    with batch = %Batch{} <- BC.get_batch(id),
         {:ok, batch} <- BC.remove_batch_to_loa(batch.id, loa_id),
         {:ok, loa} <- LoaContext.remove_is_batch(loa_id)
    do
      conn
      |> put_flash(:info, "LOA removed to batch!")
      |> redirect(to: batch_path(conn, :batch_details, id))
    else
      nil ->
        conn
        |> put_flash(:error, "Batch not found")
        |> redirect(to: batch_path(conn, :index))
      _ ->
        batch = BC.get_batch(id)
        conn
        |> put_flash(:error, "Error removing loa")
        |> redirect(to: batch_path(conn, :batch_details, batch.id))
    end
  end

  def submit_batch(conn, %{"id" => id}) do
    batch = BC.get_batch(id)
    loa_batch = BC.get_batch_loa_by_batch_id(id)

    loa_ids =
      Enum.map(loa_batch, fn(x) ->
        x.loa_id
      end)

    type =
      if batch.type == "practitioner" do
        "PF"
      else
        "HB"
      end

    params = %{
      verified_ids: loa_ids,
      forfeited_ids: [],
      soa_ref_no: batch.soa_reference_no,
      soa_amount: batch.soa_amount,
      coverage: "N/A",
      type: type
    }

    with {:valid} <- BC.update_payorlink_loa_status(conn, params),
         {:ok, batch} <- BC.submit_batch(batch)
    do
      conn
      |> redirect(to: batch_path(conn, :index))
    else
      _ ->
      conn
      |> put_flash(:error, "Error submitting batch!")
      |> redirect(to: batch_path(conn, :batch_details, id))
    end

  end

end
