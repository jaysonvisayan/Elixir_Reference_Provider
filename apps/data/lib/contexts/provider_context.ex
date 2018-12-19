defmodule Data.Contexts.ProviderContext do
  @moduledoc """

  """

  import Ecto.Query

  alias Data.Repo
  alias Data.Schemas.Provider

  def get_all_providers do
    Provider
    |> select([p], %{"id" => p.id, "name" => p.name, "code" => p.code})
    |> Repo.all()
  end

  def get_all_providers_name do
    Provider
    |> select([p], p.name)
    |> Repo.all()
  end

  def get_provider_by_code(code) do
    Provider
    |> Repo.get_by(code: code)
  rescue
    Ecto.MultipleResultsError ->
      {:invalid, "Error. Multiple providers are using this code."}
  end

  def get_provider_by_payorlink_facility_id(id) do
    Provider
    |> Repo.get_by(payorlink_facility_id: id)
  end

  def create_provider(params) do
    %Provider{}
    |> Provider.create_changeset(params)
    |> Repo.insert()
  end

  def update_provider(%Provider{} = provider, params) do
    provider
    |> Provider.create_changeset(params)
    |> Repo.update()
  end

  def insert_provider_not_exist(params) do
    with nil <- params.code |> get_provider_by_code,
         {:ok, inserted_provider = %Provider{}} <- params |> create_provider
    do
      {:ok, inserted_provider}
    else
      provider = %Provider{} ->
        {:ok, provider}
      {:error, changeset = %Ecto.Changeset{}} ->
        {:error, changeset}
    end
  end
end
