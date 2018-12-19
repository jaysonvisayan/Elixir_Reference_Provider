use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :provider_worker, ProviderWorkerWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :exq,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq",
  queues: [
    {"user_migration_job_prov", 10},
    {"create_user_job_prov", 50},
    {"batch_notification_job_prov", 20}
  ],
  scheduler_enable: true,
  max_retries: 0,
  start_on_application: false
