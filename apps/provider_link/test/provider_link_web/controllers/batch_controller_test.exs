defmodule ProviderLinkWeb.BatchControllerTest do
  use ProviderLinkWeb.ConnCase
  # import ProviderLinkWeb.TestHelper
  # use ProviderLinkWeb.SchemaCase

  setup do
    conn = build_conn()
    user = fixture(:user_permission, %{keyword: "manage_batch", module: "Batch"})
    conn = authenticated(conn, user)
    provider = insert(:provider, name: "Makati Medical Center")
    insert(:agent,
                   first_name: "Shane",
                   last_name: "Dela Rosa",
                   user: user,
                   provider: provider
    )
    # conn = sign_in(conn, user)
    doctor = insert(:doctor,
      first_name: "Shaira",
      last_name: "Dizon",
      prc_number: "PRC-1234567",
      status: "validated",
      affiliated: true,
      code: "040296",
      payorlink_practitioner_id: "0b1b6194-f987-4818-9d22-03bfa7405332"
    )
    {:ok, %{conn: conn, user: user, doctor: doctor}}
  end

  test "lists all batches on index", %{conn: conn} do
    conn = get conn, batch_path(conn, :index)
    assert html_response(conn, 200) =~ "Batch"
    assert html_response(conn, 200) =~ "Batch No."
    assert html_response(conn, 200) =~ "SOA Reference No."
    assert html_response(conn, 200) =~ "Batch Type"
    assert html_response(conn, 200) =~ "Physician Name"
    assert html_response(conn, 200) =~ "Date Submitted"
    assert html_response(conn, 200) =~ "Created By"
    assert html_response(conn, 200) =~ "Status"
  end

  test "renders form for creating new batch", %{conn: conn} do
    conn = get conn, batch_path(conn, :new, type: "practitioner")
    assert html_response(conn, 200) =~ "Create Batch"
    assert html_response(conn, 200) =~ "Practitioner"
    assert html_response(conn, 200) =~ "SOA Ref. No."
    assert html_response(conn, 200) =~ "Estimated Amount"
    assert html_response(conn, 200) =~ "Remarks"
  end

  test "creates batch practitioner with valid attributes", %{conn: conn, doctor: doctor} do
    params = %{
      doctor_id: doctor.id,
      soa_reference_no: "123",
      soa_amount: 123,
      type: "practitioner"
    }
    conn = post conn, batch_path(conn, :create), batch: params
    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == batch_path(conn, :batch_details, id)
  end

  test "does not create batch practitioner with invalid attributes", %{conn: conn} do
    params = %{
      type: "practitioner"
    }
    conn = post conn, batch_path(conn, :create), batch: params
    assert html_response(conn, 302) =~ "batch"
  end

  test "creates batch hospital bill with valid attributes", %{conn: conn} do
    params = %{
      soa_reference_no: "123",
      soa_amount: 123,
      affiliated: true,
      type: "hospital_bill"
    }
    conn = post conn, batch_path(conn, :create), batch: params
    assert %{id: id} = redirected_params(conn)
    assert redirected_to(conn) == batch_path(conn, :batch_details, id)
  end

  test "does not create batch hospital_bill with invalid attributes", %{conn: conn} do
    params = %{
      type: "hospital_bill"
    }
    conn = post conn, batch_path(conn, :create), batch: params
    assert html_response(conn, 302) =~ "batch"
  end

  test "shows batch details practitioner", %{conn: conn, doctor: doctor} do
    batch = insert(:batch,
      doctor_id: doctor.id,
      soa_reference_no: "123",
      soa_amount: 123,
      type: "practitioner"
    )
    insert(:file, batch: batch)

    conn = get conn, batch_path(conn, :batch_details, batch)
    assert html_response(conn, 200) =~ "Practitioner"
    assert html_response(conn, 200) =~ "#{batch.soa_amount}"
    assert html_response(conn, 200) =~ "#{batch.edited_soa_amount}"
    assert html_response(conn, 200) =~ "#{batch.status}"
    assert html_response(conn, 200) =~ "#{batch.soa_reference_no}"
  end

  test "shows batch details hospital_bill", %{conn: conn, doctor: doctor} do
    batch = insert(:batch,
      doctor_id: doctor.id,
      soa_reference_no: "123",
      soa_amount: 123,
      type: "hospital_bill"
    )
    insert(:file, batch: batch)

    conn = get conn, batch_path(conn, :batch_details, batch)
    assert html_response(conn, 200) =~ "Hospital Bill"
    assert html_response(conn, 200) =~ "#{batch.soa_amount}"
    assert html_response(conn, 200) =~ "#{batch.edited_soa_amount}"
    assert html_response(conn, 200) =~ "#{batch.status}"
    assert html_response(conn, 200) =~ "#{batch.soa_reference_no}"
  end

end
