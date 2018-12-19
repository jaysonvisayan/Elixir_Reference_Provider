defmodule Data.Contexts.PayorContext do
  @moduledoc """
  """

  alias Data.Repo
  alias Data.Schemas.Payor

  def get_payor(id) do
    Payor
    |> Repo.get(id)
  end

  def get_payor_by_code(code) do
    Payor
    |> Repo.get_by(code: code)
  end

  def create_payor(params) do
    %Payor{}
    |> Payor.changeset(params)
    |> Repo.insert()
  end

  def update_payor(payor, params) do
    payor
    |> Payor.changeset(params)
    |> Repo.update()
  end
end
