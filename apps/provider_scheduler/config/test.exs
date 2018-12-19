use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :provider_scheduler, ProviderSchedulerWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :exq,
  mode: :api,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq",
  queues: [
    {"member_activation_job_test", 50},
    {"benefit_migration_job_test", 10},
    {"product_migration_job_test", 10},
    {"account_migration_job_test", 10},
    {"member_migration_job_test", 10},
    {"create_member_job_test", 100},
    {"notification_job_test", 50}
  ],
  scheduler_enable: true,
  max_retries: 0,
  start_on_application: false

# config :exq_ui,
#   server: true
