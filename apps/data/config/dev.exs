use Mix.Config

  config :data, Data.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: System.get_env("POSTGRES_USER") || "postgres",
    password: System.get_env("POSTGRES_PASSWORD") || "postgres",
    hostname: System.get_env("POSTGRES_HOST") || "localhost",
    database: "providerlink_dev",
    pool_size: 10,
    types: Data.PostgrexTypes

#Staging Db
# config :data, Data.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   username: "postgres",
#   password: "postgres",
#   database: "providerlink_ist",
#   hostname: "172.16.45.21",
#   pool_size: 10

config :arc,
  storage: Arc.Storage.Local

config :data, Data.Utilities.SMS,
  infobip_username: "Equicom",
  infobip_password: "TA031417ecsPH",
  sms_cached: "false",
  proxy: {"172.16.252.23", 3128}
