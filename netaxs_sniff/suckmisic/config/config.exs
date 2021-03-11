# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :suckmisic,
  ecto_repos: [Suckmisic.Repo]

# Configures the endpoint
config :suckmisic, SuckmisicWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ilg8VX9KVZbInaDXF6XxqKaeOZt6MnaGWmF0ZEdeJ+FC9a/TzBlEEdxJqJgZCmsj",
  render_errors: [view: SuckmisicWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Suckmisic.PubSub,
  live_view: [signing_salt: "oAcT14Uz"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
