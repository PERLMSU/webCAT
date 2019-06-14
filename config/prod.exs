use Mix.Config

# Do not print debug messages in production
config :logger, level: :info

config :cors_plug,
  origin: ["*"],
  max_age: 86_400,
  methods: ["GET", "POST", "PATCH", "DELETE"]

import_config "prod.secret.exs"
