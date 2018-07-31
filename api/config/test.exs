use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :webcat, WebCAT.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :webcat, WebCAT.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "webcat",
  password: "webcat",
  database: "webcat_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
