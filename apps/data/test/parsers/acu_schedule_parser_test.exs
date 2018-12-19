defmodule Data.Parsers.AcuScheduleParserTest do
  use Data.SchemaCase, async: true
  alias Data.Parsers.AcuScheduleParser
  alias Ecto.UUID
  alias Data.Schemas.AcuScheduleMemberUploadLog

  setup do
    user = insert(:user)
    provider = insert(:provider)
    acu_schedule = insert(:acu_schedule, provider_id: provider.id, date_to: Ecto.Date.utc(), date_from: Ecto.Date.utc(), no_of_guaranteed: 0, guaranteed_amount: Decimal.new(1000))
    acu_schedule_member_upload_file =
      insert(:acu_schedule_member_upload_file, acu_schedule: acu_schedule, filename: "Upload_member.csv")

    {:ok, %{
      user: user,
      acu_schedule: acu_schedule,
      acu_schedule_member_upload_file: acu_schedule_member_upload_file
    }}
  end

  describe "Create Batch for Acu Schedule" do
    test "with valid parameters",
      %{acu_schedule: acu_schedule,
        user: user,
        acu_schedule_member_upload_file: acu_schedule_member_upload_file
      }
    do
      loa = insert(:loa, member_card_no: "6050831100061542", status: "approved")
      insert(:acu_schedule_member, acu_schedule: acu_schedule, loa: loa)
      data = %{
        "Age" => "21",
        "Availed ACU? (Y or N)" => "Y",
        "Birthdate" => "1989-05-01",
        "Card Number" => "6050831100061542",
        "Full Name" => "DELA CRUZ, JUAN T.",
        "Gender" => "Male",
        "Package Code" => "P00145B0-34",
        "Signature" => ""
      }

      validations = AcuScheduleParser.validations(data, acu_schedule.id, acu_schedule_member_upload_file.id, user.id, "Upload_member.csv")

      assert validations == data["Card Number"]
    end

    test "with invalid parameters(card number does not exist in any batch loa)",
      %{acu_schedule: acu_schedule,
        user: user,
        acu_schedule_member_upload_file: acu_schedule_member_upload_file
      }
    do
      data = %{
        "Age" => "21",
        "Availed ACU? (Y or N)" => "Y",
        "Birthdate" => "1989-05-01",
        "Card Number" => "6050831100061542",
        "Full Name" => "DELA CRUZ, JUAN T.",
        "Gender" => "Male",
        "Package Code" => "P00145B0-34",
        "Signature" => ""
      }

      validations = AcuScheduleParser.validations(data, acu_schedule.id, acu_schedule_member_upload_file.id, user.id, "Upload_member.csv")

      assert validations == {:invalid}
    end

    test "with invalid parameters(invalid availed parameter)",
      %{acu_schedule: acu_schedule,
        user: user,
        acu_schedule_member_upload_file: acu_schedule_member_upload_file
      }
    do
      data = %{
        "Age" => "21",
        "Availed ACU? (Y or N)" => "S",
        "Birthdate" => "1989-05-01",
        "Card Number" => "6050831100061542",
        "Full Name" => "DELA CRUZ, JUAN T.",
        "Gender" => "Male",
        "Package Code" => "P00145B0-34",
        "Signature" => ""
      }

      validations = AcuScheduleParser.validations(data, acu_schedule.id, acu_schedule_member_upload_file.id, user.id, "Upload_member.csv")

      assert validations == {:invalid}
    end

  end

  describe "Insert ACU Schedule Member Upload Log" do
    test "with valid parameters",
        %{user: user,
          acu_schedule_member_upload_file: acu_schedule_member_upload_file
        }
      do
        params = %{
          acu_schedule_member_upload_file_id: acu_schedule_member_upload_file.id,
          filename: "Upload_member.csv",
          card_no: "6050831100061542",
          full_name: "DELA CRUZ, JUAN T.",
          gender: "Male",
          birthdate: "1989-05-01",
          age: "21",
          package_code: "P00145B0-34",
          signature: "",
          availed: "Y",
          created_by_id: user.id
        }

        insert_log = AcuScheduleParser.insert_log(params, "success", "remarks")

        assert insert_log = {:ok, %AcuScheduleMemberUploadLog{}}
    end

    test "with invalid parameters",
        %{acu_schedule: acu_schedule,
          user: user,
          acu_schedule_member_upload_file: acu_schedule_member_upload_file
        }
      do
        params = %{
          acu_schedule_member_upload_file_id: acu_schedule_member_upload_file.id,
          filename: "Upload_member.csv",
          card_no: "6050831100061542",
          full_name: "DELA CRUZ, JUAN T.",
          gender: "Male",
          birthdate: "1989-05-01",
          age: 21,
          package_code: "P00145B0-34",
          signature: "",
          availed: "Y",
          created_by_id: ""
        }

        {:error, changeset} = AcuScheduleParser.insert_log(params, "failed", "remarks")

        assert changeset.errors == [age: {"is invalid", [type: :string, validation: :cast]}]
    end
  end

end
