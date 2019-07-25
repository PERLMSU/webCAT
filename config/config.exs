# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :webcat,
  ecto_repos: [WebCAT.Repo]

config :terminator, repo: WebCAT.Repo

config :ecto, json_library: Jason

# Configures the endpoint
config :webcat, WebCATWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: :crypto.strong_rand_bytes(64),
  render_errors: [view: WebCATWeb.ErrorView, accepts: ~w(html)],
  pubsub: [name: WebCATWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :webcat, WebCATWeb.Auth.Guardian,
  issuer: "webcat",
  secret_key: :crypto.strong_rand_bytes(64)

config :phoenix, :json_library, Jason
config :bamboo, :json_library, Jason
config :webcat, WebCAT.Mailer, adapter: Bamboo.LocalAdapter

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :sentry,
  dsn: "https://04d54265f946462f96fb82fd3b1ee728@sentry.io/1369784",
  included_environments: [:prod],
  environment_name: Mix.env()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
