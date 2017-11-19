# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :kami,
  ecto_repos: [Kami.Repo]

# Configures the endpoint
config :kami, KamiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sWxw6ugLoUd8xW5rsf9Uw+rWWUu2COlwJvUogW2llWEttzAZ1UyasbX94b96SSgQ",
  render_errors: [view: KamiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Kami.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :kami, Kami.Guardian,
  issuer: "kami",
  secret_key: "y97ylha5R1Rooz4DM7plkJp9XhaT8V2tdTgb7G0rC5J8Uvk8Ze/xUXxe7CVslAy5"

config :kami, Kami.Scheduler,
  timezone: "America/Chicago"

config :arc,
  storage: Arc.Storage.S3,
  virtual_host: true,
  bucket: "gannokoe"

config :ex_aws,
  access_key_id: "AKIAI46PF7DVSCSTPYBQ",
  region: "us-east-2",
  host: "s3.us-east-2.amazonaws.com"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure thesis content editor
config :thesis,
  store: Thesis.EctoStore,
  authorization: Kami.ThesisAuth,
  uploader: Thesis.RepoUploader

config :thesis, Thesis.EctoStore, repo: Kami.Repo

# If you want to allow creating dynamic pages:
config :thesis, :dynamic_pages,
  view: KamiWeb.PageView,
  templates: ["thesis.html"],
  not_found_view: Kami.ErrorView,
  not_found_template: "404.html"
