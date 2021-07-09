use Mix.Config

# Configure your database
config :absolventenfeier, Absolventenfeier.Repo, pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :absolventenfeier, AbsolventenfeierWeb.Endpoint,
  http: [port: 4002],
  server: false

config :absolventenfeier, Absolventenfeier.Mailer, adapter: Bamboo.TestAdapter

# Print only warnings and errors during test
config :logger, level: :warn
