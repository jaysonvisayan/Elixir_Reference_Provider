defmodule Data.Contexts.UtilityContext do
  @moduledoc """

  """

  alias Ecto.UUID
  alias Data.Contexts.PayorContext
  alias Data.Schemas.Payor

  def valid_uuid?(id) do
    case UUID.cast(id) do
      {:ok, id} ->
        {true, id}
      :error ->
        {:invalid_id}
    end
  end

  def transform_datetime(datetime) do
    if is_nil(datetime) do
      {:invalid_datetime_format}
    else
      with true <- validate_datetime_format(datetime),
           {:ok, {year, month, day}} <- get_ymd(datetime),
           {:ok, {hour, min}} <- get_hms(datetime),
           {:ok, ecto_datetime} <- Ecto.DateTime.cast({{year, month, day},
             {hour, min, 0}})
    do
      {:ok, ecto_datetime}
    else
      _ ->
        {:invalid_datetime_format}
    end
    end
  end

  # convert MM/DD/YYYY to YYYY-MM-DD
  def format_date(date) do
      if date == "" do
       nil
      else
        date =
          date
          |> String.split("/")

        Ecto.Date.cast!("#{Enum.at(date, 2)}-#{Enum.at(date, 0)}-#{Enum.at(date, 1)}")
      end
  end

  # returns {year, month, day} tuple
  defp get_ymd(datetime) do
    {month, day, year} =
      datetime
      |> String.slice(0..9)
      |> String.split("/")
      |> List.to_tuple()
    {:ok, {year, month, day}}
  end

  # returns {hour, minute} tuple
  defp get_hms(datetime) do
    {date, time, period} =
      datetime
      |> String.split(" ")
      |> List.to_tuple()
    {hour, minute} =
      time
      |> String.split(":")
      |> Enum.map(&(String.to_integer(&1)))
      |> List.to_tuple()
    case period do
      "PM" ->
        if hour == 12 do
          {:ok, {hour + 1, minute}}
        else
          {:ok, {hour + 12, minute}}
        end
      "AM" ->
        {:ok, {hour, minute}}
      _ ->
        {:invalid_datetime_format}
    end
  end

  defp validate_datetime_format(string) do
    Regex.match?(~r/^(((0[13578]|1[02])[\/\.-](0[1-9]|[12]\d|3[01])[\/\.-]((19|[2-9]\d)\d{2})\s([0-9]|1[0-2]):(0[0-9]|[1-59]\d)\s(AM|am|PM|pm))|((0[13456789]|1[012])[\/\.-](0[1-9]|[12]\d|30)[\/\.-]((19|[2-9]\d)\d{2})\s([0-9]|1[0-2]):(0[0-9]|[1-59]\d)\s(AM|am|PM|pm))|((02)[\/\.-](0[1-9]|1\d|2[0-8])[\/\.-]((19|[2-9]\d)\d{2})\s([0-9]|1[0-2]):(0[0-9]|[1-59]\d)\s(AM|am|PM|pm))|((02)[\/\.-](29)[\/\.-]((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00))\s([0-9]|1[0-2]):(0[0-9]|[1-59]\d)\s(AM|am|PM|pm)))$/, string)
  end

  def payor_link_sign_in(payor_code) do
    payor = PayorContext.get_payor_by_code(payor_code)
    payorlink_sign_in_url = Enum.join([payor.endpoint, "sign_in"], "")
    headers = [{"Content-type", "application/json"}]
    body = Poison.encode!(%{"username": payor.username, "password": payor.password})

    with {:ok, response} <- HTTPoison.post(payorlink_sign_in_url,
                                           body, headers, [])
    do
      if response.status_code == 200 do
        decoded = Poison.decode!(response.body)
        {:ok, decoded["token"]}
      else
        {:unable_to_login}
      end
    else
      {:error, response} ->
        {:unable_to_login}
    end
  end

  def payor_link_sign_in(conn, payor_code) do
    payor = PayorContext.get_payor_by_code(payor_code)

    payorlink_sign_in_url = Enum.join([payor.endpoint, "sign_in"], "")
    headers = [{"Content-type", "application/json"}]
    body = Poison.encode!(%{"username": payor.username, "password": payor.password})
    option =
      if Atom.to_string(conn.scheme) == "http" do
        [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 60_000]
      else
        [recv_timeout: 60_000]
      end
    with {:ok, response} <- HTTPoison.post(payorlink_sign_in_url,
                                           body, headers, option)
    do
      if response.status_code == 200 do
        decoded = Poison.decode!(response.body)
        {:ok, decoded["token"]}
      else
        {:unable_to_login}
      end
    else
      {:error, response} ->
        {:unable_to_login}
    end
  end

  def connect_to_api_get(conn, payor_code, method) do
    with {:ok, token} <- payor_link_sign_in(conn, payor_code),
         %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
      with {:ok, response} <- HTTPoison.get(api_method, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error_connecting_api}
      end
    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:payor_does_not_exists}
    end
  end

  def connect_to_api_get_with_token(token, method, payor_code) do
    with %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]

      with {:ok, response} <- HTTPoison.get(api_method, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error_connecting_api}
      end

    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:payor_does_not_exists}
    end
  end

  def connect_to_api_post(conn, payor_code, method, params) do
    with {:ok, token} <- payor_link_sign_in(conn, payor_code),
         %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
      body = Poison.encode!(params)
      with {:ok, response} <- HTTPoison.post(api_method, body, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error, response}
          {:error_connecting_api}
      end

    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:payor_does_not_exists}
    end
  end

  def connect_to_api_post_with_token(token, method, params, payor_code) do
    with %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
      body = Poison.encode!(params)
      with {:ok, response} <- HTTPoison.post(api_method, body, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
        raise {:error, response}
          {:error_connecting_api}
      end

    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:payor_does_not_exists}
    end
  end

  def connect_to_api_put(conn, payor_code, method, params) do
    with {:ok, token} <- payor_link_sign_in(conn, payor_code),
         %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
      body = Poison.encode!(params)
      with {:ok, response} <- HTTPoison.put(api_method, body, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error, response}
          {:error_connecting_api}
      end

    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:payor_does_not_exists}
    end
  end

  def connect_to_api_put_with_token(token, method, params, payor_code) do
    with %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
      body = Poison.encode!(params)
      with {:ok, response} <- HTTPoison.put(api_method, body, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error, response}
          # {:error_connecting_api}
      end

    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:payor_does_not_exists}
    end
  end

  def connect_to_paylink_api_post(url, token, params, payor_code) do
    with %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      url = Enum.join([payor.endpoint, url])
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
      body = Poison.encode!(params)
      with {:ok, response} <- HTTPoison.post(url, body, headers, [timeout: 60_000, recv_timeout: 60_000]) do
        {:ok, response}
      else
        {:error, response} ->
          {:error, response}
        _ ->
          {:error_connecting_api}
      end
    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:payor_does_not_exists}
    end
  end

  def paylink_sign_in(conn, payor_code) do
    payor = PayorContext.get_payor_by_code(payor_code)

    paylink_sign_in_url = Enum.join([payor.endpoint, "TOKEN"], "")
    headers = [{"Content-type", "application/json"}]
    body = "grant_type=password&username=#{payor.username}&password=#{payor.password}"
    option =
      if Atom.to_string(conn.scheme) == "http" do
        [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 60_000]
      else
        [recv_timeout: 60_000]
      end
    with {:ok, response} <- HTTPoison.post(paylink_sign_in_url,
                                           body, headers, option)
    do
      if response.status_code == 200 do
        decoded = Poison.decode!(response.body)
        {:ok, decoded["access_token"]}
      else
        {:unable_to_login}
      end
    else
      {:error, response} ->
        {:unable_to_login}
    end
  end

  def transform_date(date) do
    {year, month, day} =
      date
      |> String.split("-")
      |> List.to_tuple()
    date = "#{month}/#{day}/#{year}"

    if is_nil(date) do
      {:invalid_date_format}
    else
      with true <- validate_date_format(date)
    do
      Ecto.Date.cast!({year, month, day})
    else
      _ ->
        {:invalid_date_format}
    end
    end
  end

  defp validate_date_format(string) do
    Regex.match?(~r/((0[13578]|1[02])[\/.]31[\/.](18|19|20)[0-9]{2})|((01|0[3-9]|1[1-2])[\/.](29|30)[\/.](18|19|20)[0-9]{2})|((0[1-9]|1[0-2])[\/.](0[1-9]|1[0-9]|2[0-8])[\/.](18|19|20)[0-9]{2})|((02)[\/.]29[\/.](((18|19|20)(04|08|[2468][048]|[13579][26]))|2000))/, string)
  end

  #Cancel PayLink Loa
  def update_status_paylink_sign_in(claim_no) do
    paylink_sign_in_url = 'https://api.maxicare.com.ph/paylinkapi/TOKEN'
    headers = [{"Content-type", "application/json"}]
    body = 'grant_type=password&username=admin@mlservices.com&password=P@ssw0rd1234'

    with {:ok, response} <- HTTPoison.post(paylink_sign_in_url,
                                           body, headers, [])
    do
      if response.status_code == 200 do
        decoded = Poison.decode!(response.body)
        token = decoded["access_token"]
        method = "api/PayLinkLOA/UpdateLoaStatus"
        params = %{
          "ClaimNo": claim_no,
          "RequestedBy": "username-PROVIDERLINK2",
          "UserIpAddress": "sample string 3",
          "RequestStatus": "X",
          "ProviderInstruction": "sample string 5",
          "Remarks": "sample string 6"
        }
        update_paylink_status(token, method, params)
      else
        {:unable_to_login}
      end
    else
      {:error, response} ->
        {:unable_to_login}
    end
  end

  def update_paylink_status(token, method, params) do
    api_method = Enum.join(["https://api.maxicare.com.ph/paylinkapi/", method], "")
    headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
    body = Poison.encode!(params)
    with {:ok, response} <- HTTPoison.post(api_method, body, headers, [])
    do
      decoded = Poison.decode!(response.body)
      decoded["LoaStatusUpdated"]
    else
      {:error, response} ->
      raise {:error, response}
        {:error_connecting_api}
    end
  end

  #OTP Verified PayLink Loa
  def verify_otp_paylink_sign_in(loa) do
    paylink_sign_in_url = 'https://api.maxicare.com.ph/paylinkapi/TOKEN'
    headers = [{"Content-type", "application/json"}]
    body = 'grant_type=password&username=admin@mlservices.com&password=P@ssw0rd1234'
    with {:ok, response} <- HTTPoison.post(paylink_sign_in_url,
                                           body, headers, [])
    do
      if response.status_code == 200 do
        decoded = Poison.decode!(response.body)
        token = decoded["access_token"]
        method = "api/PayLinkLOA/SmartLOAAutobatch?LOANo=#{loa.loa_number}&Source=PROVIDERLINK2&ICDCode=Z00.0"
        update_paylink_otp(token, method)
      else
        {:unable_to_login}
      end
    else
      {:error, response} ->
        {:unable_to_login}
    end
  end

  def update_paylink_otp(token, method) do
    api_method = Enum.join(["https://api.maxicare.com.ph/paylinkapi/", method], "")
    headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
    # body = Poison.encode!(params)
    with {:ok, response} <- HTTPoison.get(api_method, headers, [])
    do
      decoded = Poison.decode!(response.body)
        if Map.has_key?(decoded, "Message") do
          {:error, decoded["Message"]}
        else
          if Map.has_key?(decoded, "BatchNo") do
            if is_nil(decoded["BatchNo"]) do
              {:error, decoded["Message"]}
            else
              {:ok, decoded["BatchNo"]}
            end
          end
        end
    else
      {:error, response} ->
      raise {:error, response}
        {:error_connecting_api}
    end
  end

  # REQUEST OP CONSULT

  def valid_member_uuid?(id) do
    case UUID.cast(id) do
      {:ok, id} ->
        {true, id}
      :error ->
        {:invalid_id, "Invalid Member UUID"}
    end
  end

  def valid_provider_uuid?(id) do
    case UUID.cast(id) do
      {:ok, id} ->
        {true, id}
      :error ->
        {:invalid_id, "Invalid Provider UUID"}
    end
  end

  def valid_doctor_specialization_uuid?(id) do
    case UUID.cast(id) do
      {:ok, id} ->
        {true, id}
      :error ->
        {:invalid_id, "Invalid Doctor Specialization UUID"}
    end
  end

  def transform_datetime_consult(datetime) do
    split_datetime = String.split(datetime, " ")
    date = Enum.at(split_datetime, 0)
    time = Enum.at(split_datetime, 1)

    #SPLIT DATE
    splitted_date = String.split(date, "-")
    year = Enum.at(splitted_date, 0)
    month = Enum.at(splitted_date, 1)
    day = Enum.at(splitted_date, 2)

    #SPLIT TIME
    splitted_time = String.split(time, ":")
    hour = Enum.at(splitted_time, 0)
    minute = Enum.at(splitted_time, 1)
    second = Enum.at(splitted_time, 2)

    if String.to_integer(hour) > 12 do
      new_hour = String.to_integer(hour) - 12
      "#{month}/#{day}/#{year} #{new_hour}:#{minute} PM"
    else
      "#{month}/#{day}/#{year} #{hour}:#{minute} AM"
    end

  end

  # returns age based on given ecto date
  def age(nil), do: nil
  def age(%Ecto.Date{day: d, month: m, year: y}, as_of \\ :now) do
    do_age({y, m, d}, as_of)
  end

  defp do_age(birthday, :now) do
    {today, _time} = :calendar.now_to_datetime(:erlang.now)
    calc_diff(birthday, today)
  end

  defp do_age(birthday, date), do: calc_diff(birthday, date)

  defp calc_diff({y1, m1, d1}, {y2, m2, d2}) when m2 > m1 or (m2 == m1 and d2 >= d1) do
    y2 - y1
  end

  defp calc_diff({y1, _, _}, {y2, _, _}), do: (y2 - y1) - 1

  # Biometrics API Sign In
  def biometrics_sign_in(conn, payor_code) do
    payor = PayorContext.get_payor_by_code(payor_code)

    biometrics_sign_in_url = Enum.join([payor.endpoint, "api/Login"], "")
    headers = [{"Content-type", "application/json"}]
    body = Poison.encode!(%{"UserName": payor.username, "Password": payor.password})
    option =
      if Atom.to_string(conn.scheme) == "http" do
        [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 60_000]
      else
        [recv_timeout: 60_000]
      end

    with {:ok, response} <- HTTPoison.post(biometrics_sign_in_url,
                                           body, headers, option)
    do
      if response.status_code == 200 do
        decoded = Poison.decode!(response.body)
        {:ok, decoded["Token"]}
      else
        {:unable_to_login}
      end
    else
      {:error, response} ->
        {:unable_to_login}
    end
  end

  def request_to_api_get(conn, payor_code, method) do
    cond do
      String.downcase(payor_code) == "biometricsapi" ->
        connect_to_api_get_biometrics(conn, payor_code, method)
      String.downcase(payor_code) == "rekognizeapi" ->
        connect_to_api_get_rekognize_no_token(conn, payor_code, method)
      String.downcase(payor_code) == "maxicar" ->
        connect_to_api_get(conn, payor_code, method)
      true ->
        {:error, "Not found"}
    end
  end

  def request_to_api_put(conn, payor_code, method, params) do
    cond do
      String.downcase(payor_code) == "biometricsapi" ->
        connect_to_api_put_biometrics(conn, payor_code, method, params)
      String.downcase(payor_code) == "rekognizeapi" ->
        connect_to_api_put_rekognize_no_token(conn, payor_code, method, params)
      String.downcase(payor_code) == "maxicar" ->
        connect_to_api_put(conn, payor_code, method, params)
      true ->
        {:error, "Not found"}
    end
  end

  def request_to_api_post(conn, payor_code, method, params) do
    cond do
      String.downcase(payor_code) == "biometricsapi" ->
        connect_to_api_post_biometrics(conn, payor_code, method, params)
      String.downcase(payor_code) == "rekognizeapi" ->
        connect_to_api_post_rekognize_no_token(conn, payor_code, method, params)
      String.downcase(payor_code) == "maxicar" ->
        connect_to_api_post(conn, payor_code, method, params)
      true ->
        {:error, "Not found"}
    end
  end

  def connect_to_api_get_biometrics(conn, payor_code, method) do
    with {:ok, token} <- biometrics_sign_in(conn, payor_code),
         %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
      with {:ok, response} <- HTTPoison.get(api_method, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error_connecting_api}
      end
    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:biometrics_does_not_exists}
    end
  end

  def connect_to_api_put_biometrics(conn, payor_code, method, params) do
    with {:ok, token} <- biometrics_sign_in(conn, payor_code),
         %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
      body = Poison.encode!(params)
      with {:ok, response} <- HTTPoison.put(api_method, body, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error, response}
          {:error_connecting_api}
      end

    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:biometrics_does_not_exists}
    end
  end

  def connect_to_api_post_biometrics(conn, payor_code, method, params) do
    with {:ok, token} <- biometrics_sign_in(conn, payor_code),
         %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}, {"authorization", "Bearer #{token}"}]
      body = Poison.encode!(params)
      with {:ok, response} <- HTTPoison.post(api_method, body, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error, response}
          {:error_connecting_api}
      end

    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:biometrics_does_not_exists}
    end
  end

  #Rekognize API

  def connect_to_api_get_rekognize_no_token(conn, payor_code, method) do
    with %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}]
      with {:ok, response} <- HTTPoison.get(api_method, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error_connecting_api}
      end
    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:rekognize_does_not_exists}
    end
  end

  def connect_to_api_post_rekognize_no_token(conn, payor_code, method, params) do
    with %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}]
      body = Poison.encode!(params)

      with {:ok, response} <- HTTPoison.post(api_method, body, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error, response}
          {:error_connecting_api}
      end
    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:rekognize_does_not_exists}
    end
  end

  def connect_to_api_put_rekognize_no_token(conn, payor_code, method, params) do
    with %Payor{} = payor <- PayorContext.get_payor_by_code(payor_code)
    do
      api_method = Enum.join([payor.endpoint, method], "")
      headers = [{"Content-type", "application/json"}]
      body = Poison.encode!(params)
      with {:ok, response} <- HTTPoison.put(api_method, body, headers, [timeout: 60_000, recv_timeout: 60_000])
      do
        {:ok, response}
      else
        {:error, response} ->
          {:error, response}
          {:error_connecting_api}
      end
    else
      {:unable_to_login} ->
        {:unable_to_login}
      nil ->
        {:rekognize_does_not_exists}
    end
  end

  def get_ip(conn) do
    {:ok, ip} = :inet.getif()

    ip =
      ip
      |> Enum.at(0)
      |> Tuple.to_list()
      |> Enum.at(0)
      |> Tuple.to_list()

    "#{Enum.at(ip, 0)}.#{Enum.at(ip, 1)}.#{Enum.at(ip, 2)}.#{Enum.at(ip, 3)}"
  end

  def providerlink_sign_in(host) do
    url = "#{host.endpoint}sign_in"
    headers = [{"Content-type", "application/json"}]
    body = Poison.encode!(%{"username": host.username, "password": host.password})
    with {:ok, response} <- HTTPoison.post(url, body, headers, [])
    do
      if response.status_code == 200 do
        decoded = Poison.decode!(response.body)
        {:ok, decoded["token"]}
      else
        {:unable_to_login}
      end
    else
      {:error, response} ->
        {:unable_to_login}
    end
  end

  # def providerlink_sign_in(host) do
  #   url = "localhost:4000/api/v1/sign_in"
  #   headers = [{"Content-type", "application/json"}]
  #   body = Poison.encode!(%{"username": host.username, "password": host.password})
  #   with {:ok, response} <- HTTPoison.post(url, body, headers, [])
  #   do
  #     if response.status_code == 200 do
  #       decoded = Poison.decode!(response.body)
  #       {:ok, decoded["token"]}
  #     else
  #       {:unable_to_login}
  #     end
  #   else
  #     {:error, response} ->
  #       {:unable_to_login}
  #   end
  # end

  def partition_list([], limit, result), do: result
  def partition_list(list, limit, result) do

    temp = Enum.slice(list, 0..limit)
    result = result ++ [temp]
    temp_result = list -- temp

    partition_list(temp_result, limit, result)
  end

  def downcase(nil), do: ""
  def downcase(string), do: String.downcase("#{string}")

  def payor_link_sign_in_with_address(payor_code) do
    payor = PayorContext.get_payor_by_code(payor_code)
    payorlink_sign_in_url = Enum.join([payor.endpoint, "sign_in"], "")
    headers = [{"Content-type", "application/json"}]
    body = Poison.encode!(%{"username": payor.username, "password": payor.password})

    with {:ok, response} <- HTTPoison.post(payorlink_sign_in_url,
                                           body, headers, [])
    do
      if response.status_code == 200 do
        decoded = Poison.decode!(response.body)
        {:ok, decoded["token"], payor.endpoint}
      else
        {:unable_to_login}
      end
    else
      {:error, response} ->
        {:unable_to_login}
    end
  end
end
