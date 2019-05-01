use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :webcat, WebCATWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :webcat, WebCAT.Repo,
  username: "webcat",
  password: "webcat",
  database: "webcat_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :terminator, Terminator.Repo,
  username: "webcat",
  password: "webcat",
  database: "webcat_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :webcat, WebCAT.Mailer, adapter: Bamboo.TestAdapter

config :pbkdf2_elixir, rounds: 1
