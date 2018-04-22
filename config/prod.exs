use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# KamiWeb.Endpoint.init/2 when load_from_system_env is
# true. Any dynamic configuration should be done there.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phx.digest task
# which you typically run after static files are built.
config :kami, KamiWeb.Endpoint,
  #http: [port: 80],
  force_ssl: [host: nil, rewrite_on: [:x_forwarded_proto]],
  url: [host: "gannokoe.aludel.xyz", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  https: [:inet6,
          port: 443,
          keyfile: "/etc/letsencrypt/live/gannokoe.aludel.xyz/privkey.pem",
          certfile: "/etc/letsencrypt/live/gannokoe.aludel.xyz/fullchain.pem"]

# Do not print debug messages in production
config :logger, level: :info

config :kami,
  bxp_per_post: 0.1,
  bxp_per_week_max: 4,
  bxp_per_week_patreon_bonus: 2,
  xp_per_week: 2,
  dice_lifetime: 21600,
  posts_to_show: 30

config :kami, Kami.Scheduler,
  jobs: [
    {"1 0 * * 1", {Kami.Accounts, :timer_award_xp, []}},
    {"1 0 * * 1", {Kami.Accounts, :timer_reset_bxp, []}},
  ]

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :kami, KamiWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :kami, KamiWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
# config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :kami, KamiWeb.Endpoint, server: true
#

# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "/home/jon/app_config/prod.secret.exs"
