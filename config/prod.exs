import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.

config :absolventenfeier, AbsolventenfeierWeb.Endpoint,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :sentry,
  dsn: {:system, "SENTRY_DSN"},
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  included_environments: [:prod]

config :appsignal, :config,
  otp_app: :absolventenfeier,
  name: "Absolventenfeier",
  env: Mix.env(),
  active: true

# Do not print debug messages in production
config :logger,
  backends: [:console, Sentry.LoggerBackend]
