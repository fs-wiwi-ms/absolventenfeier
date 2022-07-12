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
      deps: deps(),
      releases: [
        absolventenfeier: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
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
      {:appsignal_phoenix, "~> 2.0.0"},
      {:appsignal, "~> 2.0"},
      {:argon2_elixir, "~> 2.0"},
      {:bamboo_smtp, "~> 3.0"},
      {:bamboo, "~> 1.5"},
      {:comeonin, "~> 5.3.0"},
      {:ecto_enum, "~> 1.3"},
      {:ecto_sql, "~> 3.6.2"},
      {:ex_machina, "~> 2.4", only: :test},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.0"},
      {:mix_test_watch, "~> 1.0", only: :test},
      {:mox, "~> 0.5", only: :test},
      {:number, "~> 1.0.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_slime, "~> 0.13.1"},
      {:phoenix, "~> 1.6.11"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:sentry, "~> 8.0"},
      {:timex, "~> 3.0"}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      ci: ["deps.get", "test"]
    ]
  end
end
