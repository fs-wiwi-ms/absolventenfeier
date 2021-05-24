defmodule Absolventenfeier.MixProject do
  use Mix.Project

  def project do
    [
      app: :absolventenfeier,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Absolventenfeier.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:mix_test_watch, "~> 1.0", only: :test},
      {:ex_machina, "~> 2.4", only: :test},
      {:mox, "~> 0.5", only: :test},
      {:phoenix, "~> 1.5.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.1"},
      {:phoenix_slime, "~> 0.13.1"},
      {:argon2_elixir, "~> 2.0"},
      {:comeonin, "~> 5.3.0"},
      {:ecto_sql, "~> 3.6.1"},
      {:postgrex, ">= 0.0.0"},
      {:sentry, "~> 8.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ecto_enum, "~> 1.3"},
      {:httpoison, "~> 1.6"},
      {:distillery, "~> 2.0"},
      {:timex, "~> 3.0"},
      {:bamboo, "~> 1.5"},
      {:bamboo_smtp, "~> 3.0"},
      {:number, "~> 1.0.1"},
      {:phoenix_live_dashboard, "~> 0.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # cleanup: ["run priv/repo/cleanup.exs"],
      # test: ["run priv/repo/block_test.exs"],
      seed: ["run -e \"Absolventenfeier.DBTasks.seed()\" --no-start"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "test.watch": ["ecto.create --quiet", "ecto.migrate", "test.watch"]
    ]
  end
end
