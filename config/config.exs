# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :absolventenfeier,
  ecto_repos: [Absolventenfeier.Repo]

config :absolventenfeier, Absolventenfeier.Repo,
  pool_size: 10,
  log: false

# Configures the endpoint
config :absolventenfeier, AbsolventenfeierWeb.Endpoint,
  http: [:inet6, port: 4000],
  url: [host: "localhost"],
  render_errors: [view: AbsolventenfeierWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Absolventenfeier.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

host =
  System.get_env("HOST") ||
    raise """
    environment variable HOST is missing.
    """

mollie_api_key =
  System.get_env("MOLLIE_API_KEY") ||
    raise """
    environment variable MOLLIE_API_KEY is missing.
    """

config :absolventenfeier, :mollie,
  api_url: "https://api.mollie.com/v2/",
  host: host,
  api_key: mollie_api_key

from_address =
  System.get_env("SMTP_ADDRESS") ||
    raise """
    environment variable SMTP_ADDRESS is missing.
    """

config :absolventenfeier, :mailer, from_address: from_address

config :gettext, :default_locale, "de"

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
