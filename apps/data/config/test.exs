use Mix.Config

config :data, Data.Repo,
  adapter: Ecto.Adapters.Postgres,
  port: System.get_env("DB_PORT") || "5432",
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PASSWORD") || "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: "providerlink_test",
  types: Data.PostgrexTypes,
  pool: Ecto.Adapters.SQL.Sandbox,
  timeout: 90_000,
  pool_timeout: 90_000
