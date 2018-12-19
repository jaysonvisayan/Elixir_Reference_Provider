use Mix.Config

config :data, Data.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER") || "${DB_USER}",
  password: System.get_env("DB_PASSWORD") || "${DB_PASSWORD}",
  database: System.get_env("DB_NAME") || "${DB_NAME}",
  hostname: System.get_env("DB_HOST") || "${DB_HOST}",
  pool_size: System.get_env("DB_POOL") || "${DB_POOL}",
  types: Data.PostgrexTypes

# config :arc,
#   storage: Arc.Storage.Local

# Set to AWS
config :data, arc_storage: :s3
config :arc,
  storage: Arc.Storage.S3,
  bucket: "${S3_BUCKET}",
  asset_host: "${S3_HOST}"

config :ex_aws,
  access_key_id: "${ACCESS_KEY}",
  secret_access_key: "${ACCESS_SECRET}",
  region: "ap-southeast-1",
  s3: [
    scheme: "https://",
    host: "s3.ap-southeast-1.amazonaws.com",
    region: "ap-southeast-1"
  ],
  recv_timeout: 60_000

config :data, Data.Utilities.SMS,
  infobip_username: "${SMS_USERNAME}",
  infobip_password: "${SMS_PASSWORD}",
  sms_cached: "${SMS_CACHED}"

