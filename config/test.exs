use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :terminusStation, TerminusStationWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# config :terminusStation, TerminusStation.Repo,
#  adapter: EctoMnesia.Adapter
#
# config :ecto_mnesia,
#  host: {:system, :atom, "MNESIA_HOST", Kernel.node()},
#  storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :ram_copies}
#
# config :mnesia, :dir, 'priv/testmnesia'
#
#

# Configure your database
config :terminusStation, TerminusStation.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "mog",
  password: "mog",
  database: "terminus_station_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
