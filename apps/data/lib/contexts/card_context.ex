defmodule Data.Contexts.CardContext do
  @moduledoc """
  """

  alias Data.Schemas.Card
  alias Data.Repo

  def get_card(number) do
    Card
    |> Repo.get_by(number: number)
  end

  def insert_card(params) do
    %Card{}
    |> Card.changeset(params)
    |> Repo.insert()
  end

  def update_card(%Card{} = card, params) do
    card
    |> Card.changeset(params)
    |> Repo.update()
  end
end
