use Mix.Config

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
  load_from_system_env: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

live_view_signing_salt =
  System.get_env("LIVE_VIEW_SALT") ||
    raise """
    environment variable LIVE_VIEW_SALT is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :absolventenfeier, AbsolventenfeierWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  url: [
    host: System.get_env("HOST"),
    port: 443,
    scheme: "https"
  ],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base,
  live_view: [
    signing_salt: live_view_signing_salt
  ]

config :absolventenfeier, Absolventenfeier.Repo, ssl: true

config :absolventenfeier, Absolventenfeier.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("SMTP_SERVER"),
  hostname: System.get_env("HOST"),
  port: System.get_env("SMTP_PORT"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  tls: :always,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: false,
  retries: 1,
  no_mx_lookups: false,
  auth: :always

sentry_env =
  System.get_env("SENTRY_ENV") ||
    raise """
    environment variable SENTRY_ENV is missing.
    """

sentry_dsn =
  System.get_env("SENTRY_DSN") ||
    raise """
    environment variable SENTRY_DSN is missing.
    """

config :sentry,
  dsn: sentry_dsn,
  environment_name: String.to_atom(sentry_env),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: sentry_env
  },
  included_environments: [:prod]

# Do not print debug messages in production
config :logger,
  backends: [:console, Sentry.LoggerBackend]
