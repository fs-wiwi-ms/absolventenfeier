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
  log: false,
  start_apps_before_migration: [:ssl]

# Configures the endpoint
config :absolventenfeier, AbsolventenfeierWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AbsolventenfeierWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Absolventenfeier.PubSub,
  secret_key_base: "5HjSFjyGix751ubR/igyrzbfby3NsOc2Dn4DxldR4hpoqKIa3YEosx3psppajJRw"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

config :absolventenfeier, :mollie, api_url: "https://api.mollie.com/v2/"

config :gettext, :default_locale, "de"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
