defmodule Data.Parsers.ProviderLinkParser do
  @moduledoc ""
  alias Data.Schemas.{
    AcuScheduleMember,
    Batch,
    AcuSchedule,
    ProviderLog
  }
  alias Data.Schemas.File, as: UploadFile
  alias Data.Repo
  alias ProviderLinkWeb.LayoutView
  import Ecto.Query

  #for kyc/bank
  def upload_image(asm, param) do
    # {:ok, image} = insert_image_acu_schedule(asm, param)
    pathsample = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/images/')
      :dev ->
        Path.expand('./uploads/images/')
      :prod ->
        Path.expand('./uploads/images/')
      _ ->
        nil
    end
    File.mkdir_p!(pathsample)
    File.write!(pathsample <> "/ACUSchedule_#{param["file_name"]}.#{param["extension"]}", Base.decode64!(param["base_64_encoded"]))
    {:ok, asm} = update_image_acu_schedule(param, asm)
    File.rm_rf(pathsample <> "/ACUSchedule_#{param["file_name"]}.#{param["extension"]}")
    {:ok, asm}
  end

  def convert_base64_img(%{
    "filename" => filename,
    "extension" => extension,
    "photo" => base64_encoded,
    "card_no" => card_no
    })
  do
    pathsample = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/images/')
      :dev ->
        Path.expand('./uploads/images/')
      :prod ->
        Path.expand('./uploads/images/')
      _ ->
        nil
    end

    [_base, base64_encoded] = String.split(base64_encoded, ",")

    File.mkdir_p!(Path.expand('./uploads/images'))
    File.write!(pathsample <> "/ACU_#{filename}.#{extension}", Base.decode64!(base64_encoded))

    path = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/images/')
      :dev ->
        Path.expand('./uploads/images/')
      :prod ->
        Path.expand('./uploads/images/')
      _ ->
        nil
    end

    file_path = "ACU_#{filename}.#{extension}"
    file_upload = %Plug.Upload{
      content_type: "image/#{extension}",
      path: "#{path}/#{file_path}",
      filename: "#{file_path}"
    }

    {:ok, %{"photo" => file_upload}}

    # File.rm_rf(pathsample <> "/ACU_#{file_name}.#{extension}")
  end

  def convert_base64_img2(%{
    "filename1" => filename,
    "extension" => extension,
    "facial_image" => base64_encoded,
    "card_no" => card_no
    })
  do
    pathsample = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/images/')
      :dev ->
        Path.expand('./uploads/images/')
      :prod ->
        Path.expand('./uploads/images/')
      _ ->
        nil
    end

    [_base, base64_encoded] = String.split(base64_encoded, ",")

    File.mkdir_p!(Path.expand('./uploads/images'))
    File.write!(pathsample <> "/ACU_#{filename}.#{extension}", Base.decode64!(base64_encoded))

    path = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/images/')
      :dev ->
        Path.expand('./uploads/images/')
      :prod ->
        Path.expand('./uploads/images/')
      _ ->
        nil
    end

    file_path = "ACU_#{filename}.#{extension}"
    file_upload = %Plug.Upload{
      content_type: "image/#{extension}",
      path: "#{path}/#{file_path}",
      filename: "#{file_path}"
    }

    {:ok, %{"facial_image" => file_upload}}

    # File.rm_rf(pathsample <> "/ACU_#{file_name}.#{extension}")
  end

  def delete_local_img(file_name, extension) do
    pathsample = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/images/')
      :dev ->
        Path.expand('./uploads/images/')
      :prod ->
        Path.expand('./uploads/images/')
      _ ->
        nil
    end

    File.rm_rf(pathsample <> "/ACU_#{file_name}.#{extension}")
  end

  def update_image_acu_schedule(params, asm) do
    path = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/images/')
      :dev ->
        Path.expand('./uploads/images/')
      :prod ->
        Path.expand('./uploads/images/')
      _ ->
        nil
    end

    file_path = "ACUSchedule_#{params["file_name"]}.#{params["extension"]}"
    file_upload = %Plug.Upload{
      content_type: "image/#{params["extension"]}",
      path: "#{path}/#{file_path}",
      filename: "#{file_path}"
    }

    image_params = %{
      "image" => file_upload
    }

    asm
    |> AcuScheduleMember.changeset_image(image_params)
    |> Repo.update()
  end

  #End KYC

  #FOR BATCH SOA
  def upload_a_file_batch(batch_id, params) do
    for param <- params do
      {:ok, file} = insert_file_batch(batch_id, param)
      pathsample = case Application.get_env(:data, :env) do
        :test ->
          Path.expand('./../../uploads/files/')
        :dev ->
          Path.expand('./uploads/files/')
        :prod ->
          Path.expand('./uploads/files/')
        _ ->
          nil
      end
      File.mkdir_p!(Path.expand('./uploads/files'))
      File.write!(pathsample <> "/BATCH_SOA_#{file.name}.#{param["extension"]}", Base.decode64!(param["base_64_encoded"]))
      {:ok, file} = update_file_batch(param, file)
      File.rm_rf(pathsample <> "/BATCH_SOA_#{file.name}.#{param["extension"]}")
    end
  end

  def insert_file_batch(batch_id, params) do
    batch = Batch
            |> Repo.get!(batch_id)
            |> Repo.preload(:files)
    data =
      %{
        name: params["name"],
        batch_id: batch_id
      }

    file = UploadFile
           |> Repo.get_by(data)

    if is_nil(file) do
      %UploadFile{}
      |> UploadFile.changeset_batch(data)
      |> Repo.insert()
    else
      file =
        file
        |> Repo.delete()

      %UploadFile{}
      |> UploadFile.changeset_batch(data)
      |> Repo.insert()
    end
  end

  def update_file_batch(params, file) do
    path = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/files/')
      :dev ->
        Path.expand('./uploads/files/')
      :prod ->
        Path.expand('./uploads/files/')
      _ ->
        nil
    end

    file_path = "BATCH_SOA_#{file.name}.#{params["extension"]}"
    file_params = %{"type" => %Plug.Upload{
      content_type: "application/#{params["extension"]}",
      path: "#{path}/#{file_path}",
      filename: "#{file_path}"
    }}

    file
    |> UploadFile.changeset_file(file_params)
    |> Repo.update()
  end

  def upload_a_file_acu_schedule(acu_schedule_id, params) do
    for param <- params do
      {:ok, file} = insert_file_acu_schedule(acu_schedule_id, param)
      pathsample = case Application.get_env(:data, :env) do
        :test ->
          Path.expand('./../../uploads/files/')
        :dev ->
          Path.expand('./uploads/files/')
        :prod ->
          Path.expand('./uploads/files/')
        _ ->
          nil
      end
      File.mkdir_p!(Path.expand('./uploads/files'))
      File.write!(pathsample <> "/ACU_SCHEDULE_BATCH_SOA_#{file.name}.#{param["extension"]}", Base.decode64!(param["base_64_encoded"]))
      {:ok, file} = update_file_acu_schedule(param, file)
      File.rm_rf(pathsample <> "/ACU_SCHEDULE_BATCH_SOA_#{file.name}.#{param["extension"]}")
    end
  end

  def insert_file_acu_schedule(acu_schedule_id, params) do
    acu_schedule = AcuSchedule
            |> Repo.get!(acu_schedule_id)
            |> Repo.preload(:files)
    data =
      %{
        name: params["name"],
        acu_schedule_id: acu_schedule_id
      }

    file = UploadFile
           |> Repo.get_by(data)

    if is_nil(file) do
      %UploadFile{}
      |> UploadFile.changeset_acu_schedule(data)
      |> Repo.insert()
    else
      file =
        file
        |> Repo.delete()

      %UploadFile{}
      |> UploadFile.changeset_acu_schedule(data)
      |> Repo.insert()
    end
  end

  def update_file_acu_schedule(params, file) do
    path = case Application.get_env(:data, :env) do
      :test ->
        Path.expand('./../../uploads/files/')
      :dev ->
        Path.expand('./uploads/files/')
      :prod ->
        Path.expand('./uploads/files/')
      _ ->
        nil
    end

    file_path = "ACU_SCHEDULE_BATCH_SOA_#{file.name}.#{params["extension"]}"
    file_params = %{"type" => %Plug.Upload{
      content_type: "application/#{params["extension"]}",
      path: "#{path}/#{file_path}",
      filename: "#{file_path}"
    }}

    file
    |> UploadFile.changeset_file(file_params)
    |> Repo.update()
  end
  #END

  def view_files(files, acu_schedule) do
    result = Enum.map(files, fn(file)->
      path = case Application.get_env(:data, :env) do
        :test ->
          Path.expand('./../../uploads/files/')
        :dev ->
          pathsample = Path.expand('./')
          path = ProviderLink.FileUploader
                |> LayoutView.file_url_for(file.type, file)
                |> String.replace("/apps/provider_link/assets/static", "")
                |> String.slice(0..-15)
          "#{pathsample}#{path}"
        :prod ->
          path = ProviderLink.FileUploader
              |> LayoutView.file_url_for(file.type, file)
              |> String.replace("/apps/provider_link/assets/static", "")
              |> String.slice(0..-15)
              File.mkdir_p!(Path.expand('./uploads/files'))
              pathsample = Path.expand('./uploads/files')
              Download.from(path, [path: "#{pathsample}/#{file.name}"])
              "#{pathsample}/#{file.name}"
        _ ->
          nil
      end

      file_name = file.type.file_name
      length = String.length(file_name)
      extension = String.slice(file_name, (length - 3)..length)

      with {:ok, result} <- File.read("#{path}") do

        pathsample = Path.expand('./uploads/files/')
        File.rm_rf("#{pathsample}/#{file.name}")

        %{
          "base_64_encoded": Base.encode64(result),
          "extension": extension,
          "name": file.name
        }
      else
        _ ->
          params = %{
            module: "ACU Schedule",
            type_id: acu_schedule.id,
            details: "Error in path: #{path}",
            remarks: "Error in API"
          }

          %ProviderLog{}
          |> ProviderLog.changeset(params)
          |> Repo.insert()

          %{
            "base_64_encoded": "Convert Failed Error in Image URL path: #{path}",
            "extension": "",
            "name": ""
          }
      end
    end)

    {:ok, result}
  end
end
