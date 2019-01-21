defmodule WebCAT.Mixfile do
  use Mix.Project

  def project do
    [
      app: :webcat,
      version: "0.1.0",
      elixir: "~> 1.4",
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
      mod: {WebCAT, []},
      extra_applications: ~w(logger runtime_tools)a
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ~w(lib test/support)
  defp elixirc_paths(_), do: ~w(lib)

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:anaphora, "~> 0.1.2"},
      {:bamboo, "~> 1.0"},
      {:bodyguard, "~> 2.2"},
      {:comeonin, "~> 4.0"},
      {:cors_plug, "~> 1.5"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:ecto_sql, "~> 3.0"},
      {:distillery, "~> 2.0", runtime: false},
      {:dialyxir, git: "https://github.com/jeremyjh/dialyxir.git", only: [:dev], runtime: false},
      {:faker, "~> 0.10", exclude: :prod},
      {:ex_machina, "~> 2.2", exclude: :prod},
      {:gettext, "~> 0.16"},
      {:guardian, git: "https://github.com/bbuscarino/guardian"},
      {:jason, "~> 1.1"},
      {:pbkdf2_elixir, "~> 0.12"},
      {:phoenix, "~> 1.4.0", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.12"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:postgrex, ">= 0.0.0"},
      {:proper_case, "~> 1.0.2"},
      {:timex, "~> 3.4"},
      {:sentry, "~> 7.0"},
      {:csv, "~> 2.0.0"}
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
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
