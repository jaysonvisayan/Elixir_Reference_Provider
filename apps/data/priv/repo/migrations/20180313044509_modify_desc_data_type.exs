defmodule Data.Repo.Migrations.ModifyDescDataType do
  use Ecto.Migration

  def up do
    alter table(:loa_diagnoses) do
      modify :diagnosis_description, :text
    end

    alter table(:loa_procedures) do
      modify :procedure_description, :text
    end
  end

  def down do
    alter table(:loa_diagnoses) do
      modify :diagnosis_description, :string
    end

    alter table(:loa_procedures) do
      modify :procedure_description, :string
    end
  end
end
