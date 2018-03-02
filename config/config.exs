# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :opinionated_quotes_api,
  ecto_repos: [OpinionatedQuotesApi.Repo]

# Configures the endpoint
config :opinionated_quotes_api, OpinionatedQuotesApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "e92wjxzFCVXmuoLwUzXJ2+AdAkQOz+J2U9UCCvi3yjfidR9nDKsE5HziSYHkyl51",
  render_errors: [view: OpinionatedQuotesApiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OpinionatedQuotesApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
