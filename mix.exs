defmodule WebCAT.Mixfile do
  use Mix.Project

  def project do
    [
      app: :webcat,
      version: "1.0.0-dev",
      elixir: "~> 1.8",
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
  defp elixirc_paths(:test), do: ~w(lib test/support priv/repo/migrations)
  defp elixirc_paths(_), do: ~w(lib priv/repo/migrations)

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # I18n
      {:gettext, "~> 0.16"},
      # JSON
      {:jason, "~> 1.1"},
      # HTTP and Phoenix
      {:plug, "~> 1.8.2"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix, "~> 1.4.8", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.13.2"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      # Database
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.14.1"},
      # Security
      {:terminator, github: "bbuscarino/terminator", branch: "dev"},
      {:cors_plug, "~> 1.5"},
      {:comeonin, "~> 4.0"},
      {:guardian, "~> 1.0"},
      {:pbkdf2_elixir, "~> 0.12"},
      # Monitoring
      {:sentry, "~> 7.0"},
      # Time and Date
      {:timex, "~> 3.6"},
      # Email and markdown
      {:bamboo, "~> 1.0"},
      {:earmark, "~> 1.3.2"},
      # Spreadsheets
      {:xlsxir, github: "jsonkenl/xlsxir"},
      # Testing
      {:ex_machina, "~> 2.2", exclude: :prod},
      {:faker, "~> 0.10", exclude: :prod},
      {:dialyxir, github: "jeremyjh/dialyxir", only: [:dev], runtime: false},
      # Build
      {:distillery, "~> 2.0", runtime: false}
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
      "ecto.seed.integration": ["run priv/repo/seeds/integration.exs"],
      "ecto.seed.test": ["run priv/repo/seeds/base_test.exs"],
      "ecto.seed": ["run priv/repo/seeds/base.exs"],
      "ecto.setup": ~w(ecto.create ecto.migrate) ++ ["run priv/repo/migrations/auth.exs"],
      "ecto.reset": ~w(ecto.drop ecto.setup),
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
