# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :provider_worker,
  namespace: ProviderWorker

# Configures the endpoint
config :provider_worker, ProviderWorkerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UNxdImRcC8ySSfuqa3lb3jHN52dzh37h1SmrLSSBvP0sPLAAn8j0hQpLufmxg0lV",
  render_errors: [view: ProviderWorkerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ProviderWorker.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Bamboo
config :provider_worker, ProviderWorker.Mailer,
  adapter: Bamboo.SendgridAdapter,
  api_key: "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"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
