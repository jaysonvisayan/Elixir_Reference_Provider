defmodule Data.Contexts.DoctorContext do
  @moduledoc """

  """

  import Ecto.Query

  alias Data.Repo
  alias Data.Schemas.{
    Doctor,
    Provider,
    DoctorProvider,
    DoctorSpecialization
  }

  def get_all_doctors do
    Doctor
    |> join(:inner, [d], ds in DoctorSpecialization, d.id == ds.doctor_id)
    |> select([d, ds], %{
      "id" => d.id,
      "first_name" => d.first_name,
      "middle_name" => d.middle_name,
      "last_name" => d.last_name,
      "extension" => d.extension,
      "prc_number" => d.prc_number,
      "specialization_name" => ds.name,
      "specialization_type" => ds.type,
      "payorlink_practitioner_specialization_id" => ds.payorlink_practitioner_specialization_id
    })
    |> Repo.all()
  end

  def get_all_affiliated_doctors(provider_id) do 
    Doctor
    |> join(:inner, [d], ds in DoctorSpecialization, d.id == ds.doctor_id)
    |> join(:inner, [d, ds], dp in DoctorProvider, d.id == dp.doctor_id)
    |> where([d, ds, dp], dp.provider_id == ^provider_id)
    |> select([d, ds, dp], %{
      "id" => d.id,
      "first_name" => d.first_name,
      "middle_name" => d.middle_name,
      "last_name" => d.last_name,
      "extension" => d.extension,
      "prc_number" => d.prc_number,
      "specialization_name" => ds.name,
      "specialization_type" => ds.type,
      "payorlink_practitioner_specialization_id" => ds.payorlink_practitioner_specialization_id
    })
    |> distinct(true)
    |> Repo.all()
    
  end

  def filter_affiliated_doctor_specialization(provider_id, specialization_name) do 
    specialization_name = String.downcase(specialization_name)
    doctors = 
      Doctor
      |> join(:inner, [d], ds in DoctorSpecialization, d.id == ds.doctor_id)
      |> join(:inner, [d, ds], dp in DoctorProvider, d.id == dp.doctor_id)
      |> where([d, ds, dp], dp.provider_id == ^provider_id and fragment("lower(?)", ds.name) == ^specialization_name)
      |> select([d, ds, dp], %{
        "id" => d.id,
        "first_name" => d.first_name,
        "middle_name" => d.middle_name,
        "last_name" => d.last_name,
        "extension" => d.extension,
        "prc_number" => d.prc_number,
        "specialization_name" => ds.name,
        "specialization_type" => ds.type,
        "payorlink_practitioner_specialization_id" => ds.payorlink_practitioner_specialization_id
      })
      |> distinct(true)
      |> Repo.all()
    
    ps = for d <- doctors do
      if specialization_name == String.downcase(d["specialization_name"]) do
        %{
          display: "#{d["prc_number"]} | #{d["first_name"]} #{d["last_name"]} | #{d["specialization_name"]}",
          value: d["payorlink_practitioner_specialization_id"]
        }
      end
    end

    |> List.flatten
    |> Enum.uniq
    |> List.delete(nil)
  end

  def filter_affiliated_doctor(provider_id) do 
    doctors = 
      Doctor
      |> join(:inner, [d], ds in DoctorSpecialization, d.id == ds.doctor_id)
      |> join(:inner, [d, ds], dp in DoctorProvider, d.id == dp.doctor_id)
      |> where([d, ds, dp], dp.provider_id == ^provider_id)
      |> select([d, ds, dp], %{
        "id" => d.id,
        "first_name" => d.first_name,
        "middle_name" => d.middle_name,
        "last_name" => d.last_name,
        "extension" => d.extension,
        "prc_number" => d.prc_number,
        "specialization_name" => ds.name,
        "specialization_type" => ds.type,
        "payorlink_practitioner_specialization_id" => ds.payorlink_practitioner_specialization_id
      })
      |> distinct(true)
      |> Repo.all()
    
    ps = for d <- doctors do
        %{
          display: "#{d["prc_number"]} | #{d["first_name"]} #{d["last_name"]} | #{d["specialization_name"]}",
          value: d["payorlink_practitioner_specialization_id"]
        }
    end
    |> List.flatten
    |> Enum.uniq
    |> List.delete(nil)
  end

  def get_doctor_by_prc_number(prc_number) do
    Doctor
    |> Repo.get_by(prc_number: prc_number)
  end

  def create_doctor(params) do
    %Doctor{}
    |> Doctor.changeset(params)
    |> Repo.insert()
  end

  def update_doctor(%Doctor{} = doctor, params) do
    doctor
    |> Doctor.changeset(params)
    |> Repo.update()
  end

  def insert_doctor_not_exist(params) do
    doctor_ids =
      params
      |> Enum.into(
        [],
        fn{status, row} ->
          if status == :ok do
            with nil <- row.prc_number |> get_doctor_by_prc_number,
                 {:ok, inserted_doctor = %Doctor{}} <- row |> create_doctor
            do
              inserted_doctor.id
            else
              doctor = %Doctor{} ->
                doctor.id
              {:error, changeset = %Ecto.Changeset{}} ->
                {:error, changeset}
            end
          else
            nil
          end
        end
      )

    {:ok, doctor_ids}
  end
  
  #DOCTOR SPECIALIZATION

  def get_doctor_specialization_by_dtn(doctor_id, type, name) do
    DoctorSpecialization
    |> Repo.get_by(doctor_id: doctor_id, type: type, name: name)
  end

  def create_doctor_specialization(params) do
    %DoctorSpecialization{}
    |> DoctorSpecialization.changeset(params)
    |> Repo.insert()
  end

  def update_doctor_specialization(%DoctorSpecialization{} = doctor_specialization, params) do
    doctor_specialization
    |> DoctorSpecialization.changeset(params)
    |> Repo.update()
  end

  def get_doctor_by_payorlink_id(payorlink_id) do
    Doctor
    |> Repo.get_by(payorlink_practitioner_id: payorlink_id)
  end

  def get_provider_by_payorlink_id(payorlink_id) do
    Provider
    |> Repo.get_by(payorlink_facility_id: payorlink_id)
  end

  def get_doctor_by_pl_doctor_specialization_id(payorlink_id) do
    DoctorSpecialization
    |> Repo.get_by(payorlink_practitioner_specialization_id: payorlink_id)
  end

  def get_doctor_by_code(code) do
    Doctor
    |> Repo.get_by(code: code)
  end

  def get_doctors do
    Doctor
    |> Repo.all()
  end

end
