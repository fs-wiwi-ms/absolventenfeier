defmodule Absolventenfeier.MixProject do
  use Mix.Project

  def project do
    [
      app: :absolventenfeier,
      version: "0.1.0",
      elixir: "~> 1.9.4",
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
      extra_applications: [:logger, :runtime_tools, :httpoison]
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
      {:phoenix, "~> 1.4.13"},
      {:phoenix_pubsub, "~> 1.1"},
      {:argon2_elixir, "~> 2.0"},
      {:comeonin, "~> 5.3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.4.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_slime, "~> 0.13.1"},
      {:ecto_enum, "~> 1.3"},
      {:poison, "~> 4.0.1"},
      {:httpoison, "~> 1.6"},
      {:distillery, "~> 2.0"},
      {:timex, "~> 3.0"},
      {:mix_test_watch, "~> 1.0", only: :test},
      {:ex_machina, "~> 2.4", only: :test},
      {:mox, "~> 0.5", only: :test}
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
