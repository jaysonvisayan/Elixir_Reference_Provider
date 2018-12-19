# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :provider_link,
  namespace: ProviderLink

# Configures the endpoint
config :provider_link, ProviderLinkWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "U83DMHbKljhea/2NBqgHqJ6SyGzBt3D+IRsHBBIvfq1A1z+PR2r/qWbSprWO1Qh+",
  render_errors: [view: ProviderLinkWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ProviderLink.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :provider_link, ProviderLink.Guardian,
  hooks: GuardianDb,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "ProviderLink",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true, # optional
  # generated using: JOSE.JWK.generate_key({:oct, 16}) |> JOSE.JWK.to_map |> elem(1)
  secret_key: %{"k" => "GjSHkTItOhesgUKveel-YA", "kty" => "oct"}

# GuardianDB
config :guardian_db, GuardianDb,
  repo: Data.Repo,
  schema_name: "guardian_tokens",
  sweep_interval: 120

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
