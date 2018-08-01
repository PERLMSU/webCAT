# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :webcat,
  ecto_repos: [WebCAT.Repo]

# Configures the endpoint
config :webcat, WebCAT.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "s9GTMEgc/xgeVdIwZ3VZy3kTo/1xPo6k7NezFUo0Oe+vomSV4eJDes3GQnwJp4rh",
  render_errors: [view: WebCAT.ErrorView, accepts: ~w(json)],
  pubsub: [name: WebCAT.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"