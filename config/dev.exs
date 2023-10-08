import Config

config :logger, level: :info

# Configure your database
config :absolventenfeier, Absolventenfeier.Repo,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :absolventenfeier, AbsolventenfeierWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r{web/views/.*(ex)$},
      ~r{lib/klausurarchiv_web/templates/.*(eex|slim|slime)$}
    ]
  ]

config :slime, :keep_lines, true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$time][$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :absolventenfeier, Absolventenfeier.Mailer, adapter: Bamboo.LocalAdapter

config :logger,
  level: :debug
