import Config

config :absolventenfeier, Absolventenfeier.Repo, url: System.get_env("DATABASE_URL")

if config_env() == :prod do
  config :absolventenfeier, AbsolventenfeierWeb.Endpoint,
    url: [
      host: System.get_env("HOST"),
      port: 443,
      scheme: "https"
    ],
    http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
    secret_key_base: System.get_env("SECRET_KEY_BASE"),
    live_view: [signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT")]

  config :absolventenfeier, Absolventenfeier.Repo,
    ssl: System.get_env("POSTGRES_SSL") != "false",
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

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
end

config :sentry,
  tags: %{
    env: System.get_env("SENTRY_ENV")
  },
  environment_name: String.to_atom(System.get_env("SENTRY_ENV", "development"))

config :appsignal, :config, push_api_key: System.get_env("APPSIGNAL_PUSH_API_KEY", "")
