defmodule Data.Contexts.SpecializationContext do
    @moduledoc """
    """
  
    import Ecto.Query
  
    alias Data.Repo
    alias Data.Schemas.{
        Specialization
      }
    
    def get_specialization_by_name(name) do
        Specialization
        |> Repo.get_by(name: name)
    end

    def get_specialization(id) do
        Specialization
        |> Repo.get!(id)
    end

    def create_specialization(specialization_param) do
        %Specialization{}
        |> Specialization.changeset(specialization_param)
        |> Repo.insert
    end

    def update_specialization(id, specialization_param) do
        id
        |> get_specialization()
        |> Specialization.changeset(specialization_param)
        |> Repo.update
    end
end
  