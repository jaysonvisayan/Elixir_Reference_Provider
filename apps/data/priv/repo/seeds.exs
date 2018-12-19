alias Data.Seeders.{
  UserSeeder,
  MemberSeeder,
  CardSeeder,
  ProviderSeeder,
  DoctorSeeder,
  AgentSeeder,
  PayorSeeder,
  DoctorSpecializationSeeder,
  SpecializationSeeder,
  CommonPasswordSeeder,
  PermissionSeeder,
  ApplicationSeeder,
  RoleSeeder,
  RolePermissionSeeder,
  RoleApplicationSeeder,
  UserRoleSeeder
}

alias Ecto.UUID

# Create Users
IO.puts "Seeding users..."
user_data =
  [
    %{
      #1
      username: "masteradmin",
      password: "P@ssw0rd",
      password_confirmation: "P@ssw0rd",
      is_admin: true,
      pin: "validated",
      status: "active"
    }
  ]

[u1] = UserSeeder.seed(user_data)

# Create Common Password
IO.puts "Seeding common passwords..."
common_pass_data =
  [
    %{
      #1
      password: "P@ssw0rd"
    },
    %{
      #2
      password: "#Password1"
      },
    %{
      #3
      password: "Password@123"
    },
    %{
      #4
      password: "Sample@123"
    }
  ]

[cp1, cp2, cp3, cp4] = CommonPasswordSeeder.seed(common_pass_data)

# Create Payor
IO.puts "Seeding payors..."
payor_data =
  [
    %{
      #1
      name: "Maxicare",
      code: "Maxicar",
      endpoint: "https://payorlink-ip-ist.medilink.com.ph/api/v1/",
      username: "masteradmin",
      password: "P@ssw0rd"
    },
    %{
      #2
      name: "BPLAC",
      code: "BPLAC",
      endpoint: "https://bplac-ip-ist.medilink.com.ph/api/v1/",
      username: "masteradmin",
      password: "P@ssw0rd"
    },
    %{
      #3
      name: "SunLife Grepa",
      code: "Nipon",
      endpoint: "https://sunlife-ip-ist.medilink.com.ph/api/v1/",
      username: "masteradmin",
      password: "P@ssw0rd"
    },
    %{
      #4
      name: "PaylinkAPI",
      code: "paylinkAPI",
      endpoint: "https://api.maxicare.com.ph/paylinkapi/",
      username: "admin@mlservices.com",
      password: "P@ssw0rd1234"
    },
    %{
      #5
      name: "RekognizeAPI",
      code: "rekognizeAPI",
      endpoint: "http://203.177.13.129:5002/",
      username: "sample",
      password: "sample"
    },
    %{
      #6
      name: "BiometricsAPI",
      code: "biometricsAPI",
      endpoint: "https://api.maxicare.com.ph/BiometricsAPI/v4/",
      username: "membergateway_mobile@medilink.com.ph",
      password: "P@ssw0rd"
    },
    %{
      #7
      name: "Providerlink",
      code: "Provider",
      endpoint: "https://providerlink-ip-ist.medilink.com.ph/api/v1/",
      username: "masteradmin",
      password: "P@ssw0rd"
    }
  ]

[pa1, pa2, pa3, pa4, pa5, pa6, pa7] = PayorSeeder.seed(payor_data)

#Create Member
IO.puts "Seeding members..."
member_data =
  [
    %{
      #1
      payorlink_member_id: "0b4858fe-99f5-4024-9a4f-547943ee077c",
      first_name: "Juan",
      middle_name: "Dela",
      last_name: "Cruz",
      extension: "",
      birth_date: Ecto.Date.cast!("1997-09-21"),
      gender: "Male",
      pin: "1234",
      pin_expires_at: Ecto.DateTime.cast!("2017-10-31T13:58:46Z"),
      number_of_dependents: "0",
      mobile: "09210805751",
      email_address: "juan_delacruz@gmail.com",
      payor_id: pa1.id,
      type: "principal"
    },
    %{
      #2
      payorlink_member_id: "090bfb9b-0543-49d5-adf0-8f31b4da4361",
      first_name: "Ji Eun",
      middle_name: "Lee",
      last_name: "Garcia",
      extension: "Mr.",
      birth_date: Ecto.Date.cast!("1994-06-12"),
      gender: "Male",
      pin: "1234",
      pin_expires_at: Ecto.DateTime.cast!("2017-10-31T13:58:46Z"),
      number_of_dependents: "0",
      mobile: "09210805751",
      email_address: "leejieun_garcia@gmail.com",
      payor_id: pa1.id,
      type: "principal"
    }

  ]

[m1, m2] = MemberSeeder.seed(member_data)

#Create Cards
IO.puts "Seeding card..."
card_data =
  [
    %{
      #1
      member_id: m1.id,
      payorlink_member_id: m1.payorlink_member_id,
      number: "0123456789123456",
      expiry: Ecto.DateTime.cast!("2017-08-01T12:12:12Z")
    },
    %{
      #2
      member_id: m2.id,
      payorlink_member_id: m2.payorlink_member_id,
      number: "1234567890123456",
      expiry: Ecto.DateTime.cast!("2017-08-01T12:12:12Z")
    }

  ]

[c1, c2] = CardSeeder.seed(card_data)

# Create Providers
IO.puts "Seeding providers..."
provider_data =
  [
    %{
      #1
      name: "Makati Medical Center",
      code: "880000000006035",
      payorlink_facility_id: "ca63afd9-f8b4-4bb4-821e-e882a041d727",
      phone_no: "7656734",
      email_address: "g@medilink.com.ph",
      line_1: "Dela Rosa Street",
      line_2: "Legazpi Village",
      city: "Makati",
      province: "Metro Manila",
      region: "NCR",
      country: "Philippines",
      postal_code: "1200"
    },
    %{
      #2
      name: "Chinese General Hospital & Medical Center",
      code: "880000000006024",
      payorlink_facility_id: UUID.generate,
      phone_no: "7656734",
      email_address: "g@medilink.com.ph",
      line_1: "286 Radial Road 8",
      line_2: "Santa Cruz",
      city: "Manila",
      province: "Metro Manila",
      region: "NCR",
      country: "Philippines",
      postal_code: "1014"
    },
    %{
      #3
      name: "Medilink General Hospital XP3",
      code: "880000000015491",
      payorlink_facility_id: UUID.generate,
      phone_no: "7656734",
      email_address: "g@medilink.com.ph",
      line_1: "1234567",
      line_2: "1234568",
      city: "Makati",
      province: "Metro Manila",
      region: "NCR",
      country: "Philippines",
      postal_code: "1206"
    }
  ]
[p1, p2, p3] = ProviderSeeder.seed(provider_data)

# Create Agent
IO.puts "Seeding agents..."
agent_data =
  [
    %{
      #1
      first_name: "Master",
      last_name: "Admin",
      department: "Admin",
      role: "Admin",
      mobile: "09195556688",
      email: "mediadmin@medi.com",
      provider_id: p1.id,
      user_id: u1.id
    }
  ]
[a1] = AgentSeeder.seed(agent_data)

#Create Doctor
IO.puts "Seeding doctors..."
doctor_data =
  [
    %{
      #1
      first_name: "Joseph",
      middle_name: "Agustin",
      last_name: "Canilao",
      extension: "PHD",
      prc_number: "PRC-1100356",
      specialization: "Urology",
      status: "validated",
      affiliated: true,
      code: "121212",
      payorlink_practitioner_id: "0b1b6194-f987-4818-9d22-03bfa7405332"
    }
  ]

[d1] = DoctorSeeder.seed(doctor_data)

#Create Specialization
IO.puts "Seeding specialization..."
specialization_data = [
  #1
  %{
    name: "Dermatology",
    payorlink_specialization_id: "ded330d2-7470-41e4-9fd4-2159e888e357"
  },
  #2
  %{
    name: "General Surgery"
  },
  #3
  %{
    name: "Otolaryngology-Head and Neck Surgery"
  },
  #4
  %{
    name: "Cardiothoracic Surgery"
  },
  #5
  %{
    name: "Vascular Surgery"
  },
  #6
  %{
    name: "Radiology",
    payorlink_specialization_id: "73c32621-7bcd-471c-ac86-1e5c857e08f4"
  },
  #7
  %{
    name: "Pathology"
  },
  #8
  %{
    name: "Neurosurgery"
  },
  #9
  %{
    name: "Sonology"
  },
  #10
  %{
    name: "Pediatrics"
  },
  #11
  %{
    name: "Resident Physician"
  },
  #12
  %{
    name: "Internal Medicine"
  },
  #13
  %{
    name: "General Medicine"
  },
  #14
  %{
    name: "Family Medicine"
  },
  #15
  %{
    name: "Opthalmology"
  },
  #16
  %{
    name: "Optometry"
  },
  #17
  %{
    name: "Pulmonology"
  },
  #18
  %{
    name: "Obstetrics and Gynecology"
  },
  #19
  %{
    name: "Occupational Medicine"
  },
  #20
  %{
    name: "Psychiatry",
    payorlink_specialization_id: "84cb31f1-d088-468c-81fe-cfda295ae853"
  },
  #21
  %{
    name: "Neurology"
  },
  #22
  %{
    name: "Orthopedic Surgery"
  },
  #23
  %{
    name: "Anesthesiology"
  },
  #24
  %{
    name: "Oncology"
  }
]

[s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14,
s15, s16, s17, s18, s19, s20, s21, s22, s23, s24] = SpecializationSeeder.seed(specialization_data)

#Create Doctor Specialization
IO.puts "Seeding doctor specializations..."

ds_data =
[
  %{
    #1
    doctor_id: d1.id,
    name: "Psychiatry",
    type: "Primary",
    specialization_id: s20.id,
    payorlink_practitioner_specialization_id: "40970232-acd6-4d13-8133-9158b03887f8"
  },
  %{
    #2
    doctor_id: d1.id,
    name: "Radiology",
    type: "Secondary",
    specialization_id: s6.id,
    payorlink_practitioner_specialization_id: "8f53ae8d-ec03-4661-ac34-60c9573836d2"
  },
  %{
    #3
    doctor_id: d1.id,
    name: "Dermatology",
    type: "Secondary",
    specialization_id: s1.id,
    payorlink_practitioner_specialization_id: "c41bfa0b-74b4-4b30-9b08-d24e9997d62e"
  },
]

[ds1, ds2, ds3] = DoctorSpecializationSeeder.seed(ds_data)

#Create Application

IO.puts "Seeding Application"
app_data =
  [
    %{
      name: "ProviderLink"
    }
  ]

[ap1] = ApplicationSeeder.seed(app_data)

#Create Permission
IO.puts "Seeding permissions..."

per_data =
[
  %{
    #1
    name: "Manage Home",
    module: "Home",
    keyword: "manage_home",
    application_id: ap1.id,
    status: "sample",
    description: "sample",
  },
  %{
    #2
    name: "Access Home",
    module: "Home",
    keyword: "access_home",
    application_id: ap1.id,
    status: "sample",
    description: "sample",
  },
  #61
  %{
    name: "Manage LOAs",
    module: "LOAs",
    keyword: "manage_loas",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  },
  #62
  %{
    name: "Access LOAs",
    module: "LOAs",
    keyword: "access_loas",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  },
  #63
  %{
    name: "Manage Batch",
    module: "Batch",
    keyword: "manage_batch",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  },
  #64
  %{
    name: "Access Batch",
    module: "Batch",
    keyword: "access_batch",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  },
  #65
  %{
    name: "Manage Patients",
    module: "Patients",
    keyword: "manage_patients",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  },
  #66
  %{
    name: "Access Patients",
    module: "Patients",
    keyword: "access_patients",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  },
  #67
  %{
    name: "Manage Reports",
    module: "Reports",
    keyword: "manage_reports",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  },
  #68
  %{
    name: "Access Reports",
    module: "Reports",
    keyword: "access_reports",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  },
  #67
  %{
    name: "Manage ProviderLink ACU Schedules",
    module: "ProviderLink_Acu_Schedules",
    keyword: "manage_providerlink_acu_schedules",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  },
  #68
  %{
    name: "Access ProviderLink ACU Schedules",
    module: "ProviderLink_Acu_Schedules",
    keyword: "access_providerlink_acu_schedules",
    application_id: ap1.id,
    status: "sample",
    description: "sample"
  }
]

[per1, per2, per3, per4,
 per5, per6, per7, per8,
 per9, per10, per11, per12
] = PermissionSeeder.seed(per_data)

#Create Role
IO.puts "Seeding role..."

r_data =
[
  %{
    #1
    name: "provider_admin",
    description: "test",
    status: "test",
    created_by_id: u1.id,
    updated_by_id: u1.id,
    step: 1,
    create_full_access: "ProviderLink",
  },
]
[r1] = RoleSeeder.seed(r_data)

#Create User Role
IO.puts "Seeding user role..."

ur_data =
[
  %{
    #1
    user_id: u1.id,
    role_id: r1.id
  },
]
[ur1] = UserRoleSeeder.seed(ur_data)

#Create Role Permission
IO.puts "Seeding role permissions..."

rp_data =
[
  %{
    #1
    role_id: r1.id,
    permission_id: per1.id
  },
  %{
    #2
    role_id: r1.id,
    permission_id: per2.id
  },
  %{
    #3
    role_id: r1.id,
    permission_id: per3.id
  },
  %{
    #4
    role_id: r1.id,
    permission_id: per4.id
  },
  %{
    #5
    role_id: r1.id,
    permission_id: per5.id
  },
  %{
    #6
    role_id: r1.id,
    permission_id: per6.id
  },
  %{
    #7
    role_id: r1.id,
    permission_id: per7.id
  },
  %{
    #8
    role_id: r1.id,
    permission_id: per8.id
  },
  %{
    #9
    role_id: r1.id,
    permission_id: per9.id
  },
  %{
    #10
    role_id: r1.id,
    permission_id: per10.id
  },
  %{
    #11
    role_id: r1.id,
    permission_id: per11.id
  },
  %{
    #12
    role_id: r1.id,
    permission_id: per12.id
  },
]
[rp1, rp2, rp3, rp4,
 rp5, rp6, rp7, rp8,
 rp9, rp10, rp11, rp12
] = RolePermissionSeeder.seed(rp_data)


#Create Role Application
IO.puts "Seeding role application..."

ra_data =
[
  %{
    #1
    role_id: r1.id,
    application_id: ap1.id
  },
]
[ra1] = RoleApplicationSeeder.seed(ra_data)
