alias Data.Seeders.{
  PayorSeeder,
  UserSeeder,
  ProviderSeeder,
  AgentSeeder
}

# Create Payor
IO.puts "Seeding payors..."
payor_data =
  [
    %{
      #1
      name: "Maxicare",
      code: "Maxicar",
      endpoint: "https://payorlink-ip-staging.medilink.com.ph/api/v1/",
      username: "masteradmin",
      password: "P@ssw0rd"
    },
    %{
      #2
      name: "PaylinkAPI",
      code: "paylinkAPI",
      endpoint: "https://api.maxicare.com.ph/paylinkapi/",
      username: "admin@mlservices.com",
      password: "P@ssw0rd1234"
    }
  ]

[pa1, pa2] = PayorSeeder.seed(payor_data)

# Create Users
IO.puts "Seeding users..."
user_data =
  [
    %{
      #1
      username: "api_user",
      password: "P@ssw0rdAp!",
      password_confirmation: "P@ssw0rdAp!",
      is_admin: false,
      pin: "validated",
      status: "active"
    }
  ]

[u1] = UserSeeder.seed(user_data)

# Create Providers
IO.puts "Seeding providers..."
provider_data =
  [
    %{
      #1
      name: "MEDILINK GENERAL HOSPITAL XP 3",
      code: "880000000015491",
      payorlink_facility_id: "462fe55e-5b44-4acf-a1d3-1edff3684409",
      phone_no: "35167894",
      email_address: "TESTJAKE@medilink.com.ph",
      line_1: "TEST STREET44",
      line_2: "",
      city: "Makati",
      province: "Metro Manila",
      region: "NCR",
      country: "Philippines",
      postal_code: "1200"
    },
  ]
[p1] = ProviderSeeder.seed(provider_data)

# Ceate Agent
IO.puts "Seeding agents..."
agent_data =
  [
    %{
      #1
      first_name: "API",
      last_name: "User",
      department: "User",
      role: "User",
      mobile: "09195556688",
      email: "mediadmin@medi.com",
      provider_id: p1.id,
      user_id: u1.id
    }
  ]
[a1] = AgentSeeder.seed(agent_data)

