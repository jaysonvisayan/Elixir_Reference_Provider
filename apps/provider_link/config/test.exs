use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :provider_link, ProviderLinkWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :provider_link, ProviderLink.Mailer,
  adapter: Bamboo.TestAdapter
