# TerminusStation
To start you will ned to configure postgresql for data storage and the api key in the application.ex for your mbta developer account
```bash
mix deps.get
cd assets && npm install && cd ..
mix ecto.drop
mix ecto.create
mix ecto.migrate
iex -S mix phx.server 
```
endpoints will be / and /departures after startup
# demo available for view at 
[TerminusStation](https://ts.rldn.net/)
# work not completed
* Improve configuration support
* handle change of day schedule polling
* understand why i typically don't see which track code the train is boarding at
* better handling of deletion from mbta
* unit tests
* documentation
